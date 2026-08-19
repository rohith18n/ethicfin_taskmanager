import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/services/conflict_resolver.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final ConflictResolver conflictResolver;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    ConflictResolver? conflictResolver,
  }) : conflictResolver = conflictResolver ?? const ConflictResolver();

  @override
  Future<List<TaskEntity>> getTasks({String? userId}) async {
    // Return local tasks first for instant UI response
    final localTasks = await localDataSource.getTasks(userId: userId);

    // Trigger sync in background if connected
    if (await networkInfo.isConnected) {
      _syncInBackground(userId: userId);
    }

    return localTasks;
  }

  void _syncInBackground({String? userId}) {
    syncPendingTasks(userId: userId).catchError((e) {
      debugPrint('Background sync notice: $e');
    });
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    return await localDataSource.getTaskById(id);
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final model = TaskModel.fromEntity(task).copyWith(
          isSynced: true,
          syncAction: AppConstants.syncActionNone,
        );
        await remoteDataSource.createTask(model);
        await localDataSource.insertTask(model);
        return;
      } on ServerException catch (e) {
        debugPrint('Firestore insert failed, falling back to local sync queue: $e');
      } catch (e) {
        debugPrint('Remote insert unexpected error: $e');
      }
    }

    // Offline or remote failed: save with pending sync
    final localModel = TaskModel.fromEntity(task).copyWith(
      isSynced: false,
      syncAction: AppConstants.syncActionInsert,
    );
    await localDataSource.insertTask(localModel);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final isOnline = await networkInfo.isConnected;
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    if (isOnline) {
      try {
        final model = TaskModel.fromEntity(updatedTask).copyWith(
          isSynced: true,
          syncAction: AppConstants.syncActionNone,
        );
        await remoteDataSource.updateTask(model);
        await localDataSource.updateTask(model);
        return;
      } on ServerException catch (e) {
        debugPrint('Firestore update failed, queuing for sync: $e');
      } catch (e) {
        debugPrint('Remote update unexpected error: $e');
      }
    }

    // Offline or remote failed: save with pending update
    final localModel = TaskModel.fromEntity(updatedTask).copyWith(
      isSynced: false,
      syncAction: AppConstants.syncActionUpdate,
    );
    await localDataSource.updateTask(localModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        await remoteDataSource.deleteTask(id);
        await localDataSource.hardDeleteTask(id);
        return;
      } on ServerException catch (e) {
        debugPrint('Firestore delete failed, queuing for sync: $e');
      } catch (e) {
        debugPrint('Remote delete unexpected error: $e');
      }
    }

    // Offline or remote failed: mark for deletion locally
    await localDataSource.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = await localDataSource.getTaskById(id);
    if (task == null) return;

    final toggled = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await updateTask(toggled);
  }

  @override
  Future<void> syncPendingTasks({String? userId}) async {
    if (!await networkInfo.isConnected) return;

    try {
      final pendingTasks = await localDataSource.getPendingSyncTasks(userId: userId);

      final toInsertOrUpdate = <TaskModel>[];
      final toDelete = <String>[];

      for (final task in pendingTasks) {
        if (task.syncAction == AppConstants.syncActionDelete) {
          toDelete.add(task.id);
        } else {
          toInsertOrUpdate.add(task);
        }
      }

      // 1. Push local changes in batch
      if (toInsertOrUpdate.isNotEmpty || toDelete.isNotEmpty) {
        try {
          await remoteDataSource.syncBatch(
            toInsertOrUpdate: toInsertOrUpdate,
            toDelete: toDelete,
          );

          // Mark pushed tasks as synced in local DB
          for (final task in toInsertOrUpdate) {
            await localDataSource.markAsSynced(task.id);
          }
          for (final id in toDelete) {
            await localDataSource.hardDeleteTask(id);
          }
        } catch (e) {
          debugPrint('Batch sync failed, falling back to individual sync: $e');
          // Individual sync fallback
          for (final task in pendingTasks) {
            try {
              if (task.syncAction == AppConstants.syncActionInsert) {
                await remoteDataSource.createTask(task);
                await localDataSource.markAsSynced(task.id);
              } else if (task.syncAction == AppConstants.syncActionUpdate) {
                await remoteDataSource.updateTask(task);
                await localDataSource.markAsSynced(task.id);
              } else if (task.syncAction == AppConstants.syncActionDelete) {
                await remoteDataSource.deleteTask(task.id);
                await localDataSource.hardDeleteTask(task.id);
              }
            } catch (err) {
              debugPrint('Failed to sync individual task ${task.id}: $err');
            }
          }
        }
      }

      // 2. Pull remote tasks and merge with conflict resolution
      try {
        final remoteTasks = await remoteDataSource.getTasks(userId: userId);
        final localTasks = await localDataSource.getTasks(userId: userId);
        final localTaskMap = {for (final t in localTasks) t.id: t};

        final resolvedRemoteList = <TaskModel>[];

        for (final remoteTask in remoteTasks) {
          final localVersion = localTaskMap[remoteTask.id];

          if (localVersion != null) {
            final result = conflictResolver.resolve(
              localTask: localVersion,
              remoteTask: remoteTask,
            );

            if (result.winner == 'REMOTE') {
              resolvedRemoteList.add(TaskModel.fromEntity(result.resolvedTask));
            } else if (result.winner == 'LOCAL' && !localVersion.isSynced) {
              // Local is newer and unsynced -> push local to remote
              await remoteDataSource.updateTask(TaskModel.fromEntity(localVersion));
              await localDataSource.markAsSynced(localVersion.id);
            }
          } else {
            // New task from remote
            resolvedRemoteList.add(remoteTask);
          }
        }

        if (resolvedRemoteList.isNotEmpty) {
          await localDataSource.saveFromRemote(resolvedRemoteList);
        }
      } catch (e) {
        debugPrint('Failed to pull and resolve remote tasks: $e');
      }
    } catch (e) {
      debugPrint('Sync pending tasks error: $e');
    }
  }
}
