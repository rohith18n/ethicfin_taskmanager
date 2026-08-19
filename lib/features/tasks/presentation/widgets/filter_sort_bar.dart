import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/task_filter.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_sort.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class FilterSortBar extends StatelessWidget {
  const FilterSortBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips row + Sort Button
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      label: 'All (${state.totalTasksCount})',
                      isSelected: state.filter == TaskFilter.all,
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(const ChangeFilterEvent(TaskFilter.all));
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: 'Pending (${state.pendingTasksCount})',
                      isSelected: state.filter == TaskFilter.pending,
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(const ChangeFilterEvent(TaskFilter.pending));
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: 'Completed (${state.completedTasksCount})',
                      isSelected: state.filter == TaskFilter.completed,
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(const ChangeFilterEvent(TaskFilter.completed));
                      },
                    ),
                    const SizedBox(width: 8),
                    // Sort & Priority Filter Button
                    _buildSortButton(context, state),
                  ],
                ),
              ),
              // Priority Filter row if active
              if (state.priorityFilter != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Priority: ${state.priorityFilter!.displayName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(const ChangePriorityFilterEvent(null));
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.lightInputFill),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, TaskState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _showFilterSortSheet(context, state),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightInputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.tune_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Sort & More',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSortSheet(BuildContext context, TaskState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bloc = bottomSheetContext.read<TaskBloc>();
            final currentState = bloc.state;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Sort & Filter Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SORT BY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...TaskSortBy.values.map((sort) {
                      final isSelected = currentState.sortBy == sort;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          sort.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          bloc.add(ChangeSortEvent(sort));
                          Navigator.pop(bottomSheetContext);
                        },
                      );
                    }),
                    const Divider(height: 24),
                    const Text(
                      'FILTER BY PRIORITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text(
                            'All Priorities',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: currentState.priorityFilter == null,
                          selectedColor: const Color(0xFFCBD5E1),
                          backgroundColor: const Color(0xFFF1F5F9),
                          checkmarkColor: Colors.black,
                          side: BorderSide(
                            color: currentState.priorityFilter == null
                                ? Colors.black
                                : const Color(0xFF94A3B8),
                            width: currentState.priorityFilter == null ? 1.5 : 1,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              bloc.add(const ChangePriorityFilterEvent(null));
                              Navigator.pop(bottomSheetContext);
                            }
                          },
                        ),
                        ...TaskPriority.values.map((priority) {
                          final isSelected =
                              currentState.priorityFilter == priority;
                          return ChoiceChip(
                            avatar: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: priority.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            label: Text(
                              priority.displayName,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFFCBD5E1),
                            backgroundColor: const Color(0xFFF1F5F9),
                            checkmarkColor: Colors.black,
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.black
                                  : const Color(0xFF94A3B8),
                              width: isSelected ? 1.5 : 1,
                            ),
                            onSelected: (selected) {
                              bloc.add(ChangePriorityFilterEvent(
                                selected ? priority : null,
                              ));
                              Navigator.pop(bottomSheetContext);
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
