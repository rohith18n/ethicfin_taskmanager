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
              // Horizontal Filter Chips Row (WhatsApp Style)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPillChip(
                      context,
                      label: 'All',
                      count: state.totalTasksCount,
                      isSelected: state.filter == TaskFilter.all,
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(const ChangeFilterEvent(TaskFilter.all));
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillChip(
                      context,
                      label: 'Pending',
                      count: state.pendingTasksCount,
                      isSelected: state.filter == TaskFilter.pending,
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(const ChangeFilterEvent(TaskFilter.pending));
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildPillChip(
                      context,
                      label: 'Completed',
                      count: state.completedTasksCount,
                      isSelected: state.filter == TaskFilter.completed,
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(const ChangeFilterEvent(TaskFilter.completed));
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildSortPill(context, state),
                  ],
                ),
              ),
              // Active Priority Filter Tag
              if (state.priorityFilter != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.chipSelectedBg
                        : AppColors.lightChipSelectedBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.transparent
                          : AppColors.lightChipSelectedBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: state.priorityFilter!.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Priority: ${state.priorityFilter!.displayName}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.chipSelectedText
                              : AppColors.lightChipSelectedText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          context
                              .read<TaskBloc>()
                              .add(const ChangePriorityFilterEvent(null));
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.chipSelectedText
                              : AppColors.lightChipSelectedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillChip(
    BuildContext context, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isSelected
        ? (isDark ? AppColors.chipSelectedBg : AppColors.lightChipSelectedBg)
        : (isDark ? AppColors.chipUnselectedBg : AppColors.lightChipUnselectedBg);

    final textColor = isSelected
        ? (isDark ? AppColors.chipSelectedText : AppColors.lightChipSelectedText)
        : (isDark ? AppColors.chipUnselectedText : AppColors.lightChipUnselectedText);

    final borderColor = isSelected
        ? (isDark ? Colors.transparent : AppColors.lightChipSelectedBorder)
        : (isDark ? Colors.transparent : AppColors.lightChipUnselectedBorder);

    final displayText = count > 0 && isSelected ? '$label $count' : label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSortPill(BuildContext context, TaskState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.chipUnselectedBg : AppColors.lightChipUnselectedBg;
    final textColor = isDark ? AppColors.chipUnselectedText : AppColors.lightChipUnselectedText;
    final borderColor = isDark ? Colors.transparent : AppColors.lightChipUnselectedBorder;

    return InkWell(
      onTap: () => _showFilterSortSheet(context, state),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Sort',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSortSheet(BuildContext context, TaskState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
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
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Sort & Filter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SORT BY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? AppColors.chipSelectedText : AppColors.primaryDark)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: isDark ? AppColors.chipSelectedText : AppColors.primaryDark,
                              )
                            : null,
                        onTap: () {
                          bloc.add(ChangeSortEvent(sort));
                          Navigator.pop(bottomSheetContext);
                        },
                      );
                    }),
                    Divider(
                      height: 24,
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    ),
                    Text(
                      'FILTER BY PRIORITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPriorityModalChip(
                          label: 'All Priorities',
                          isSelected: currentState.priorityFilter == null,
                          isDark: isDark,
                          onTap: () {
                            bloc.add(const ChangePriorityFilterEvent(null));
                            Navigator.pop(bottomSheetContext);
                          },
                        ),
                        ...TaskPriority.values.map((priority) {
                          final isSelected = currentState.priorityFilter == priority;
                          return _buildPriorityModalChip(
                            label: priority.displayName,
                            dotColor: priority.color,
                            isSelected: isSelected,
                            isDark: isDark,
                            onTap: () {
                              bloc.add(ChangePriorityFilterEvent(
                                isSelected ? null : priority,
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

  Widget _buildPriorityModalChip({
    required String label,
    Color? dotColor,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected
        ? (isDark ? AppColors.chipSelectedBg : AppColors.lightChipSelectedBg)
        : (isDark ? AppColors.chipUnselectedBg : AppColors.lightChipUnselectedBg);

    final textColor = isSelected
        ? (isDark ? AppColors.chipSelectedText : AppColors.lightChipSelectedText)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    final borderColor = isSelected
        ? (isDark ? Colors.transparent : AppColors.lightChipSelectedBorder)
        : (isDark ? Colors.transparent : AppColors.lightChipUnselectedBorder);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
