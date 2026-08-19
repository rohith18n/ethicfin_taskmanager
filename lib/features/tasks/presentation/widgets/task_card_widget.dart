import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'priority_badge_widget.dart';

class TaskCardWidget extends StatelessWidget {
  final TaskEntity task;

  const TaskCardWidget({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = DateFormatter.isOverdue(task.dueDate, task.isCompleted);

    return Dismissible(
      key: Key('task_dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) {
        context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted'),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      },
      child: InkWell(
        onTap: () => context.push('/task/${task.id}', extra: task),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Circular Status & Priority Avatar
                    GestureDetector(
                      onTap: () {
                        context
                            .read<TaskBloc>()
                            .add(ToggleTaskCompletionEvent(task.id));
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted
                              ? (isDark ? AppColors.chipSelectedBg : AppColors.lightChipSelectedBg)
                              : (isDark ? AppColors.darkInputFill : AppColors.lightInputFill),
                          border: Border.all(
                            color: task.isCompleted
                                ? AppColors.primary
                                : task.priority.color,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_rounded
                                : Icons.assignment_rounded,
                            size: 24,
                            color: task.isCompleted
                                ? AppColors.primary
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Middle Column: Title & Description Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Title and Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatRelative(task.dueDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                  color: isOverdue
                                      ? AppColors.error
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Row 2: Subtitle with priority tag and sync icon
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.description_outlined,
                                  size: 15,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  task.description.isNotEmpty
                                      ? task.description
                                      : 'No description',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PriorityBadgeWidget(
                                priority: task.priority,
                                isCompact: true,
                              ),
                              if (!task.isSynced || task.syncAction != 'NONE') ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 14,
                                  color: AppColors.warning,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Thin WhatsApp style divider with left indent
              Padding(
                padding: const EdgeInsets.only(left: 76),
                child: Divider(
                  height: 1,
                  thickness: 0.7,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
