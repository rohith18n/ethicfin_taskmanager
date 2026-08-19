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
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
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
      },
      onDismissed: (direction) {
        context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
      },
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context.push('/task/${task.id}', extra: task);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Avatar / Priority Indicator
                  GestureDetector(
                    onTap: () {
                      context
                          .read<TaskBloc>()
                          .add(ToggleTaskCompletionEvent(task.id));
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
                            border: Border.all(
                              color: task.priority.color,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              task.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.assignment_rounded,
                              size: 24,
                              color: task.isCompleted
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                          ),
                        ),
                        if (task.isCompleted)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.done_all_rounded,
                                size: 14,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                      ],
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

                        // Row 2: Subtitle with checkmarks/priority tag and sync icon
                        Row(
                          children: [
                            if (task.isCompleted)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.done_all_rounded,
                                  size: 16,
                                  color: AppColors.accent, // WhatsApp blue double checks
                                ),
                              )
                            else
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
                                    : 'No additional details',
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
                            const SizedBox(width: 6),
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
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80, right: 16),
            child: Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
        ],
      ),
    );
  }
}
