import 'package:ethicfin_taskmanager/features/tasks/domain/entities/task_entity.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/enums/task_priority.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/services/conflict_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ConflictResolver conflictResolver;

  setUp(() {
    conflictResolver = const ConflictResolver();
  });

  final baseTime = DateTime(2026, 8, 19, 10, 0, 0);

  final localTask = TaskEntity(
    id: 'task-1',
    title: 'Local Version Title',
    description: 'Edited locally',
    priority: TaskPriority.high,
    dueDate: baseTime.add(const Duration(days: 1)),
    isCompleted: false,
    createdAt: baseTime,
    updatedAt: baseTime.add(const Duration(hours: 2)), // 12:00
    isSynced: false,
  );

  final olderRemoteTask = TaskEntity(
    id: 'task-1',
    title: 'Remote Old Title',
    description: 'Remote description',
    priority: TaskPriority.medium,
    dueDate: baseTime.add(const Duration(days: 1)),
    isCompleted: false,
    createdAt: baseTime,
    updatedAt: baseTime.add(const Duration(hours: 1)), // 11:00
    isSynced: true,
  );

  final newerRemoteTask = TaskEntity(
    id: 'task-1',
    title: 'Remote Newer Title',
    description: 'Remote newer description',
    priority: TaskPriority.urgent,
    dueDate: baseTime.add(const Duration(days: 1)),
    isCompleted: true,
    createdAt: baseTime,
    updatedAt: baseTime.add(const Duration(hours: 3)), // 13:00
    isSynced: true,
  );

  test('Last-Write-Wins: Local wins when local updatedAt is newer', () {
    final result = conflictResolver.resolve(
      localTask: localTask,
      remoteTask: olderRemoteTask,
    );

    expect(result.winner, 'LOCAL');
    expect(result.wasConflict, true);
    expect(result.resolvedTask.title, 'Local Version Title');
  });

  test('Last-Write-Wins: Remote wins when remote updatedAt is newer', () {
    final result = conflictResolver.resolve(
      localTask: localTask,
      remoteTask: newerRemoteTask,
    );

    expect(result.winner, 'REMOTE');
    expect(result.wasConflict, true);
    expect(result.resolvedTask.title, 'Remote Newer Title');
    expect(result.resolvedTask.isSynced, true);
  });
}
