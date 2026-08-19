import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> insertTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> hardDeleteTask(String id);
  Future<List<TaskModel>> getPendingSyncTasks();
  Future<void> markAsSynced(String id);
  Future<void> saveFromRemote(List<TaskModel> remoteTasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final DatabaseHelper databaseHelper;

  TaskLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        AppConstants.tasksTableName,
        where: 'sync_action != ?',
        whereArgs: [AppConstants.syncActionDelete],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => TaskModel.fromSqflite(map)).toList();
    } catch (e) {
      throw CacheException('Failed to fetch tasks from local database: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        AppConstants.tasksTableName,
        where: 'id = ? AND sync_action != ?',
        whereArgs: [id, AppConstants.syncActionDelete],
      );
      if (results.isNotEmpty) {
        return TaskModel.fromSqflite(results.first);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to fetch task $id from local database: $e');
    }
  }

  @override
  Future<void> insertTask(TaskModel task) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        AppConstants.tasksTableName,
        task.toSqflite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to insert task locally: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        AppConstants.tasksTableName,
        task.toSqflite(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw CacheException('Failed to update task locally: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final db = await databaseHelper.database;
      final existing = await getTaskById(id);

      if (existing == null) return;

      // If the task was never synced to remote (created offline and not synced yet),
      // we can hard delete it directly.
      if (!existing.isSynced && existing.syncAction == AppConstants.syncActionInsert) {
        await hardDeleteTask(id);
      } else {
        // Mark for remote delete
        await db.update(
          AppConstants.tasksTableName,
          {
            'is_synced': 0,
            'sync_action': AppConstants.syncActionDelete,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      throw CacheException('Failed to mark task as deleted locally: $e');
    }
  }

  @override
  Future<void> hardDeleteTask(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        AppConstants.tasksTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to hard delete task: $e');
    }
  }

  @override
  Future<List<TaskModel>> getPendingSyncTasks() async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        AppConstants.tasksTableName,
        where: 'is_synced = ?',
        whereArgs: [0],
      );
      return results.map((map) => TaskModel.fromSqflite(map)).toList();
    } catch (e) {
      throw CacheException('Failed to fetch pending sync tasks: $e');
    }
  }

  @override
  Future<void> markAsSynced(String id) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        AppConstants.tasksTableName,
        {
          'is_synced': 1,
          'sync_action': AppConstants.syncActionNone,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to mark task as synced: $e');
    }
  }

  @override
  Future<void> saveFromRemote(List<TaskModel> remoteTasks) async {
    try {
      final db = await databaseHelper.database;
      await db.transaction((txn) async {
        for (final remoteTask in remoteTasks) {
          // Check if local has pending unsynced changes for this task
          final local = await txn.query(
            AppConstants.tasksTableName,
            where: 'id = ?',
            whereArgs: [remoteTask.id],
          );

          if (local.isNotEmpty) {
            final isSynced = (local.first['is_synced'] as int) == 1;
            // If local has pending unsynced edits, don't overwrite with older remote data
            if (!isSynced) {
              continue;
            }
          }

          // Insert or update remote task
          await txn.insert(
            AppConstants.tasksTableName,
            remoteTask.toSqflite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      throw CacheException('Failed to save remote tasks to local database: $e');
    }
  }
}
