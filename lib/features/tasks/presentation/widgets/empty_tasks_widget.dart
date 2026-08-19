import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/task_filter.dart';

class EmptyTasksWidget extends StatelessWidget {
  final TaskFilter filter;
  final String searchQuery;

  const EmptyTasksWidget({
    super.key,
    required this.filter,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title;
    String subtitle;
    IconData icon;

    if (searchQuery.isNotEmpty) {
      title = 'No Matching Tasks';
      subtitle = 'No tasks found for "$searchQuery". Try a different search query.';
      icon = Icons.search_off_rounded;
    } else {
      switch (filter) {
        case TaskFilter.pending:
          title = 'No Pending Tasks';
          subtitle = 'Awesome! You have cleared all your pending tasks.';
          icon = Icons.check_circle_outline_rounded;
          break;
        case TaskFilter.completed:
          title = 'No Completed Tasks';
          subtitle = 'Complete your first task to see it listed here.';
          icon = Icons.assignment_turned_in_outlined;
          break;
        case TaskFilter.all:
          title = 'No Tasks Yet';
          subtitle = 'Stay organized by adding your first task.';
          icon = Icons.assignment_outlined;
          break;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withAlpha(20)
                    : AppColors.primaryLight.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            if (searchQuery.isEmpty && filter == TaskFilter.all) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/add'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create New Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
