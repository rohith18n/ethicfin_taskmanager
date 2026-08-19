import 'package:ethicfin_taskmanager/features/tasks/data/models/task_model.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/entities/task_entity.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/enums/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testDateTime = DateTime(2026, 8, 20, 10, 0, 0);

  final tTaskModel = TaskModel(
    id: 'test-id-123',
    title: 'Audit Financial Statement',
    description: 'Quarterly review of compliance and risk metrics',
    priority: TaskPriority.urgent,
    dueDate: testDateTime,
    isCompleted: false,
    createdAt: testDateTime,
    updatedAt: testDateTime,
    isSynced: true,
    syncAction: 'NONE',
  );

  test('should be a subclass of TaskEntity', () {
    expect(tTaskModel, isA<TaskEntity>());
  });

  group('JSON serialization', () {
    test('toJson returns correct Map', () {
      final json = tTaskModel.toJson();

      expect(json['id'], 'test-id-123');
      expect(json['title'], 'Audit Financial Statement');
      expect(json['priority'], 'urgent');
      expect(json['isCompleted'], false);
      expect(json['dueDate'], testDateTime.toIso8601String());
      expect(json['isSynced'], true);
    });

    test('fromJson constructs valid TaskModel', () {
      final json = {
        'id': 'test-id-123',
        'title': 'Audit Financial Statement',
        'description': 'Quarterly review of compliance and risk metrics',
        'priority': 'urgent',
        'dueDate': testDateTime.toIso8601String(),
        'isCompleted': false,
        'createdAt': testDateTime.toIso8601String(),
        'updatedAt': testDateTime.toIso8601String(),
        'isSynced': true,
        'syncAction': 'NONE',
      };

      final result = TaskModel.fromJson(json);

      expect(result, equals(tTaskModel));
      expect(result.priority, TaskPriority.urgent);
    });
  });

  group('SQLite serialization', () {
    test('toSqflite returns proper integer and string format for SQLite', () {
      final map = tTaskModel.toSqflite();

      expect(map['id'], 'test-id-123');
      expect(map['title'], 'Audit Financial Statement');
      expect(map['is_completed'], 0);
      expect(map['is_synced'], 1);
      expect(map['sync_action'], 'NONE');
      expect(map['due_date'], testDateTime.toIso8601String());
    });

    test('fromSqflite reconstructs TaskModel accurately', () {
      final map = {
        'id': 'test-id-123',
        'title': 'Audit Financial Statement',
        'description': 'Quarterly review of compliance and risk metrics',
        'priority': 'urgent',
        'due_date': testDateTime.toIso8601String(),
        'is_completed': 0,
        'created_at': testDateTime.toIso8601String(),
        'updated_at': testDateTime.toIso8601String(),
        'is_synced': 1,
        'sync_action': 'NONE',
      };

      final result = TaskModel.fromSqflite(map);

      expect(result, equals(tTaskModel));
      expect(result.isCompleted, false);
      expect(result.isSynced, true);
    });
  });

  group('Firestore serialization', () {
    test('toFirestore formats map correctly', () {
      final map = tTaskModel.toFirestore();

      expect(map['title'], 'Audit Financial Statement');
      expect(map['priority'], 'urgent');
      expect(map['isCompleted'], false);
    });

    test('fromFirestore constructs model with document ID', () {
      final map = {
        'title': 'Audit Financial Statement',
        'description': 'Quarterly review of compliance and risk metrics',
        'priority': 'urgent',
        'dueDate': testDateTime.toIso8601String(),
        'isCompleted': false,
        'createdAt': testDateTime.toIso8601String(),
        'updatedAt': testDateTime.toIso8601String(),
      };

      final result = TaskModel.fromFirestore(map, 'test-id-123');

      expect(result.id, 'test-id-123');
      expect(result.title, 'Audit Financial Statement');
      expect(result.priority, TaskPriority.urgent);
      expect(result.isSynced, true);
    });
  });
}
