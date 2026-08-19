import 'package:ethicfin_taskmanager/core/network/network_info.dart';
import 'package:ethicfin_taskmanager/core/theme/theme_cubit.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/sync_tasks_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/toggle_task_completion_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:ethicfin_taskmanager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:ethicfin_taskmanager/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTasksUseCase extends Mock implements GetTasksUseCase {}
class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}
class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}
class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}
class MockToggleTaskCompletionUseCase extends Mock implements ToggleTaskCompletionUseCase {}
class MockSyncTasksUseCase extends Mock implements SyncTasksUseCase {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
    mockNetworkInfo = MockNetworkInfo();
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(() => mockNetworkInfo.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockGetTasksUseCase()).thenAnswer((_) async => []);
  });

  testWidgets('TaskMaster App smoke test', (WidgetTester tester) async {
    final taskBloc = TaskBloc(
      getTasksUseCase: mockGetTasksUseCase,
      createTaskUseCase: MockCreateTaskUseCase(),
      updateTaskUseCase: MockUpdateTaskUseCase(),
      deleteTaskUseCase: MockDeleteTaskUseCase(),
      toggleTaskCompletionUseCase: MockToggleTaskCompletionUseCase(),
      syncTasksUseCase: MockSyncTasksUseCase(),
      networkInfo: mockNetworkInfo,
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<TaskBloc>.value(value: taskBloc),
        ],
        child: const MaterialApp(
          home: TaskListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TaskMaster'), findsOneWidget);
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('No Tasks Yet'), findsOneWidget);
  });
}
