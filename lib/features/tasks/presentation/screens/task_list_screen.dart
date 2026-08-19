import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
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
