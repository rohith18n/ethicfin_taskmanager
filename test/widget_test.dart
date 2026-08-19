import 'package:ethicfin_taskmanager/core/network/network_info.dart';
import 'package:ethicfin_taskmanager/core/theme/theme_cubit.dart';
import 'package:ethicfin_taskmanager/features/auth/domain/entities/user_entity.dart';
import 'package:ethicfin_taskmanager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ethicfin_taskmanager/features/auth/presentation/bloc/auth_state.dart';
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
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockNetworkInfo mockNetworkInfo;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
    mockNetworkInfo = MockNetworkInfo();
    mockAuthBloc = MockAuthBloc();

    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(() => mockNetworkInfo.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockGetTasksUseCase(userId: any(named: 'userId'))).thenAnswer((_) async => []);
    when(() => mockAuthBloc.state).thenReturn(const AuthState(
      status: AuthStatus.authenticated,
      user: UserEntity(id: 'test-user-1', email: 'test@example.com', displayName: 'Test User'),
    ));
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
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
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<TaskBloc>.value(value: taskBloc),
        ],
        child: const MaterialApp(
          home: TaskListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('No Tasks Yet'), findsOneWidget);
  });
}
