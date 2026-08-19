import 'package:ethicfin_taskmanager/core/theme/theme_cubit.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/entities/task_entity.dart';
import 'package:ethicfin_taskmanager/features/tasks/domain/enums/task_priority.dart';
import 'package:ethicfin_taskmanager/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:ethicfin_taskmanager/features/tasks/presentation/bloc/task_state.dart';
import 'package:ethicfin_taskmanager/features/tasks/presentation/screens/task_form_screen.dart';
import 'package:ethicfin_taskmanager/features/tasks/presentation/widgets/priority_badge_widget.dart';
import 'package:ethicfin_taskmanager/features/tasks/presentation/widgets/task_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskBloc extends Mock implements TaskBloc {}

void main() {
  late MockTaskBloc mockTaskBloc;

  setUp(() {
    mockTaskBloc = MockTaskBloc();
    when(() => mockTaskBloc.state).thenReturn(const TaskState());
    when(() => mockTaskBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  final testTask = TaskEntity(
    id: 'widget-test-1',
    title: 'Financial Risk Assessment',
    description: 'Complete Q3 risk breakdown',
    priority: TaskPriority.urgent,
    dueDate: DateTime.now().add(const Duration(days: 2)),
    isCompleted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isSynced: true,
  );

  testWidgets('PriorityBadgeWidget renders priority label correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PriorityBadgeWidget(priority: TaskPriority.urgent),
        ),
      ),
    );

    expect(find.text('Urgent'), findsOneWidget);
  });

  testWidgets('TaskCardWidget renders title and description', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TaskBloc>.value(
          value: mockTaskBloc,
          child: Scaffold(
            body: TaskCardWidget(task: testTask),
          ),
        ),
      ),
    );

    expect(find.text('Financial Risk Assessment'), findsOneWidget);
    expect(find.text('Complete Q3 risk breakdown'), findsOneWidget);
    expect(find.text('Urgent'), findsOneWidget);
    expect(find.byIcon(Icons.assignment_rounded), findsOneWidget);
  });

  testWidgets('TaskFormScreen shows validation error when title is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
            BlocProvider<TaskBloc>.value(value: mockTaskBloc),
          ],
          child: const TaskFormScreen(),
        ),
      ),
    );

    // Tap Save button without entering title
    final saveButton = find.widgetWithText(ElevatedButton, 'Create Task');
    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a task title'), findsOneWidget);
    expect(find.text('Please enter a task description'), findsOneWidget);
  });

  testWidgets('TaskFormScreen shows validation error when description is too short', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
            BlocProvider<TaskBloc>.value(value: mockTaskBloc),
          ],
          child: const TaskFormScreen(),
        ),
      ),
    );

    // Enter valid title but short description
    await tester.enterText(find.byType(TextFormField).first, 'Valid Title');
    await tester.enterText(find.byType(TextFormField).at(1), 'abc');
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Create Task');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Description must be at least 5 characters'), findsOneWidget);
  });
}
