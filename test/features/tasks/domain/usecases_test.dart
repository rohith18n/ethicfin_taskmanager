import 'package:ethicfin_taskmanager/features/tasks/domain/entities/task_entity.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/enums/task_priority.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/repositories/task_repository.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/sync_tasks_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/toggle_task_completion_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepository;
  final testDate = DateTime(2026, 8, 20);
  final tTask = TaskEntity(
    id: '1',
    title: 'Test Task',
    description: 'Description',
    priority: TaskPriority.high,
    dueDate: testDate,
    isCompleted: false,
    createdAt: testDate,
    updatedAt: testDate,
  );

  setUp(() {
    mockRepository = MockTaskRepository();
  });

  test('GetTasksUseCase calls repository.getTasks', () async {
    when(() => mockRepository.getTasks()).thenAnswer((_) async => [tTask]);
    final useCase = GetTasksUseCase(mockRepository);

    final result = await useCase();

    expect(result, [tTask]);
    verify(() => mockRepository.getTasks()).called(1);
  });

  test('CreateTaskUseCase calls repository.createTask', () async {
    when(() => mockRepository.createTask(tTask)).thenAnswer((_) async {});
    final useCase = CreateTaskUseCase(mockRepository);

    await useCase(tTask);

    verify(() => mockRepository.createTask(tTask)).called(1);
  });

  test('UpdateTaskUseCase calls repository.updateTask', () async {
    when(() => mockRepository.updateTask(tTask)).thenAnswer((_) async {});
    final useCase = UpdateTaskUseCase(mockRepository);

    await useCase(tTask);

    verify(() => mockRepository.updateTask(tTask)).called(1);
  });

  test('DeleteTaskUseCase calls repository.deleteTask', () async {
    when(() => mockRepository.deleteTask('1')).thenAnswer((_) async {});
    final useCase = DeleteTaskUseCase(mockRepository);

    await useCase('1');

    verify(() => mockRepository.deleteTask('1')).called(1);
  });

  test('ToggleTaskCompletionUseCase calls repository.toggleTaskCompletion', () async {
    when(() => mockRepository.toggleTaskCompletion('1')).thenAnswer((_) async {});
    final useCase = ToggleTaskCompletionUseCase(mockRepository);

    await useCase('1');

    verify(() => mockRepository.toggleTaskCompletion('1')).called(1);
  });

  test('SyncTasksUseCase calls repository.syncPendingTasks', () async {
    when(() => mockRepository.syncPendingTasks()).thenAnswer((_) async {});
    final useCase = SyncTasksUseCase(mockRepository);

    await useCase();

    verify(() => mockRepository.syncPendingTasks()).called(1);
  });
}
