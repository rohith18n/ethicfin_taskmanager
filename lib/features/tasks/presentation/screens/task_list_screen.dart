import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/empty_tasks_widget.dart';
import '../widgets/error_view_widget.dart';
import '../widgets/filter_sort_bar.dart';
import '../widgets/search_input_widget.dart';
import '../widgets/sync_status_indicator.dart';
import '../widgets/task_card_widget.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        scrolledUnderElevation: 0,
        title: Text(
          'Tasks',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          const SyncStatusIndicator(),
          const SizedBox(width: 4),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return IconButton(
                tooltip: isDark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final user = authState.user;
              final initial = user?.displayName?.isNotEmpty == true
                  ? user!.displayName![0].toUpperCase()
                  : (user?.email?.isNotEmpty == true ? user!.email![0].toUpperCase() : 'U');

              return PopupMenuButton<String>(
                tooltip: 'Account',
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                offset: const Offset(0, 48),
                icon: CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                itemBuilder: (ctx) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? (user?.isAnonymous == true ? 'Guest User' : 'User'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        const Divider(height: 16),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'test_notification',
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 18,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Test Notification',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'test_notification') {
                    sl<NotificationService>().showNotification(
                      id: DateTime.now().millisecondsSinceEpoch % 100000,
                      title: '🔔 EthicFin Task Reminder',
                      body: 'Your notification system is working perfectly!',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification triggered!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (value == 'logout') {
                    context.read<AuthBloc>().add(const SignOutEvent());
                  }
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SearchInputWidget(),
          const FilterSortBar(),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.status == TaskStatus.loading &&
                    state.allTasks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.status == TaskStatus.failure &&
                    state.allTasks.isEmpty) {
                  return ErrorViewWidget(
                    message:
                        state.errorMessage ??
                        'An error occurred while loading tasks.',
                    onRetry: () {
                      context.read<TaskBloc>().add(const LoadTasksEvent());
                    },
                  );
                }

                if (state.filteredTasks.isEmpty) {
                  return EmptyTasksWidget(
                    filter: state.filter,
                    searchQuery: state.searchQuery,
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<TaskBloc>().add(const SyncTasksEvent());
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 4),
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];
                      return TaskCardWidget(task: task);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}
