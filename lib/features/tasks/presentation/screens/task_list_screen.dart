import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('TaskMaster'),
          ],
        ),
        actions: [
          const SyncStatusIndicator(),
          const SizedBox(width: 8),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return IconButton(
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
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
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.status == TaskStatus.loading && state.allTasks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.status == TaskStatus.failure && state.allTasks.isEmpty) {
                  return ErrorViewWidget(
                    message: state.errorMessage ?? 'An error occurred while loading tasks.',
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
                  onRefresh: () async {
                    context.read<TaskBloc>().add(const SyncTasksEvent());
                    // Wait briefly for smooth pull animation
                    await Future.delayed(const Duration(milliseconds: 600));
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
