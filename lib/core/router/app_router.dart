import 'package:go_router/go_router.dart';
import '../../features/tasks/domain/entities/task_entity.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) {
          final task = state.extra as TaskEntity?;
          return TaskFormScreen(task: task);
        },
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) {
          final taskId = state.pathParameters['id'] ?? '';
          final task = state.extra as TaskEntity?;
          return TaskDetailScreen(
            taskId: taskId,
            initialTask: task,
          );
        },
      ),
    ],
  );
}
