import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/tasks/domain/entities/task_entity.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuth = authState.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final isRegistering = state.matchedLocation == '/register';

        // Still loading auth state
        if (authState.status == AuthStatus.initial) {
          return null;
        }

        // If not authenticated and not in auth screens, redirect to login
        if (!isAuth && !isLoggingIn && !isRegistering) {
          return '/login';
        }

        // If authenticated and trying to access login/register, redirect to tasks
        if (isAuth && (isLoggingIn || isRegistering)) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
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
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
