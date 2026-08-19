import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<TaskEntity>> getTasks() async {
    // Return local tasks first for instant UI response
    final localTasks = await localDataSource.getTasks();

    // Trigger sync in background if connected
    if (await networkInfo.isConnected) {
      _syncInBackground();
    }

    return localTasks;
  }

  void _syncInBackground() {
    syncPendingTasks().catchError((e) {
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
  Future<void> syncPendingTasks() async {
    if (!await networkInfo.isConnected) return;

    try {
      final pendingTasks = await localDataSource.getPendingSyncTasks();

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
        } catch (e) {
          debugPrint('Failed to sync individual task ${task.id}: $e');
        }
      }

      // Fetch remote tasks and merge
      try {
        final remoteTasks = await remoteDataSource.getTasks();
        await localDataSource.saveFromRemote(remoteTasks);
      } catch (e) {
        debugPrint('Failed to fetch remote tasks during sync: $e');
      }
    } catch (e) {
      debugPrint('Sync pending tasks error: $e');
    }
  }
}
