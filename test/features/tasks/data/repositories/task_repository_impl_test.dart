import 'package:ethicfin_taskmanager/core/constants/app_constants.dart';
import 'package:ethicfin_taskmanager/core/network/network_info.dart';
import 'package:ethicfin_taskmanager/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:ethicfin_taskmanager/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:ethicfin_taskmanager/features/tasks/data/models/task_model.dart';
import 'package:ethicfin_taskmanager/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/enums/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}
class MockTaskRemoteDataSource extends Mock implements TaskRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockTaskLocalDataSource mockLocalDataSource;
  late MockTaskRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late TaskRepositoryImpl repository;

  final testDate = DateTime(2026, 8, 20);
  final tTaskModel = TaskModel(
    id: 'repo-test-1',
    title: 'Repo Test Task',
    description: 'Testing repository sync',
    priority: TaskPriority.medium,
    dueDate: testDate,
    isCompleted: false,
    createdAt: testDate,
    updatedAt: testDate,
    isSynced: true,
    syncAction: 'NONE',
  );

  setUpAll(() {
    registerFallbackValue(tTaskModel);
  });

  setUp(() {
    mockLocalDataSource = MockTaskLocalDataSource();
    mockRemoteDataSource = MockTaskRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = TaskRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getTasks', () {
    test('returns local tasks and checks connectivity', () async {
      when(() => mockLocalDataSource.getTasks()).thenAnswer((_) async => [tTaskModel]);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getTasks();

      expect(result, [tTaskModel]);
      verify(() => mockLocalDataSource.getTasks()).called(1);
    });
  });

  group('createTask', () {
    test('saves with isSynced=true to remote and local when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.createTask(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.insertTask(any())).thenAnswer((_) async {});

      await repository.createTask(tTaskModel);

      verify(() => mockRemoteDataSource.createTask(any())).called(1);
      verify(() => mockLocalDataSource.insertTask(any(that: isA<TaskModel>().having(
            (m) => m.isSynced,
            'isSynced',
            true,
          )))).called(1);
    });

    test('saves with isSynced=false to local when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.insertTask(any())).thenAnswer((_) async {});

      await repository.createTask(tTaskModel);

      verifyZeroInteractions(mockRemoteDataSource);
      verify(() => mockLocalDataSource.insertTask(any(that: isA<TaskModel>()
          .having((m) => m.isSynced, 'isSynced', false)
          .having((m) => m.syncAction, 'syncAction', AppConstants.syncActionInsert)))).called(1);
    });
  });

  group('syncPendingTasks', () {
    test('iterates through pending tasks and uploads to remote when online', () async {
      final pendingTask = tTaskModel.copyWith(
        isSynced: false,
        syncAction: AppConstants.syncActionInsert,
      );

      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getPendingSyncTasks())
          .thenAnswer((_) async => [pendingTask]);
      when(() => mockRemoteDataSource.createTask(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.markAsSynced('repo-test-1'))
          .thenAnswer((_) async {});
      when(() => mockRemoteDataSource.getTasks()).thenAnswer((_) async => [tTaskModel]);
      when(() => mockLocalDataSource.saveFromRemote(any())).thenAnswer((_) async {});

      await repository.syncPendingTasks();

      verify(() => mockRemoteDataSource.createTask(any())).called(1);
      verify(() => mockLocalDataSource.markAsSynced('repo-test-1')).called(1);
      verify(() => mockRemoteDataSource.getTasks()).called(1);
      verify(() => mockLocalDataSource.saveFromRemote([tTaskModel])).called(1);
    });
  });
}
