import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/priority_badge_widget.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  final TaskEntity? initialTask;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.initialTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Find task from latest bloc state, fallback to initialTask
        TaskEntity? task;
        try {
          task = state.allTasks.firstWhere((t) => t.id == taskId);
        } catch (_) {
          task = initialTask;
        }

        if (task == null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            appBar: AppBar(title: const Text('Task Details')),
            body: const Center(
              child: Text('Task not found.'),
            ),
          );
        }

        final isOverdue = DateFormatter.isOverdue(task.dueDate, task.isCompleted);

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            title: Text(
              'Task Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Task',
                onPressed: () {
                  context.push('/edit/${task!.id}', extra: task);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                tooltip: 'Delete Task',
                onPressed: () => _confirmDelete(context, task!),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? (isDark ? AppColors.chipSelectedBg : AppColors.lightChipSelectedBg)
                        : (isOverdue
                            ? (isDark ? AppColors.priorityUrgentBg : AppColors.priorityUrgentLightBg)
                            : (isDark ? AppColors.darkInputFill : AppColors.lightInputFill)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: task.isCompleted
                          ? (isDark ? Colors.transparent : AppColors.lightChipSelectedBorder)
                          : (isOverdue ? AppColors.error.withAlpha(80) : Colors.transparent),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        task.isCompleted
                            ? Icons.done_all_rounded
                            : (isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.schedule_rounded),
                        color: task.isCompleted
                            ? (isDark ? AppColors.chipSelectedText : AppColors.lightChipSelectedText)
                            : (isOverdue ? AppColors.error : AppColors.primary),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.isCompleted
                              ? 'This task has been completed'
                              : (isOverdue
                                  ? 'This task is overdue!'
                                  : 'This task is pending completion'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted
                                ? (isDark ? AppColors.chipSelectedText : AppColors.lightChipSelectedText)
                                : (isOverdue
                                    ? AppColors.error
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Priority Badge
                Row(
                  children: [
                    Text(
                      'Priority: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadgeWidget(priority: task.priority),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    task.description.isNotEmpty
                        ? task.description
                        : 'No description provided for this task.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontStyle:
                          task.description.isEmpty ? FontStyle.italic : FontStyle.normal,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Metadata Section
                Text(
                  'Task Metadata',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildMetadataRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Due Date',
                        value: DateFormatter.formatDateTime(task.dueDate),
                        trailing: Text(
                          DateFormatter.formatRelative(task.dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isOverdue ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      _buildMetadataRow(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Created Date',
                        value: DateFormatter.formatDateTime(task.createdAt),
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      _buildMetadataRow(
                        icon: Icons.update_rounded,
                        label: 'Last Updated',
                        value: DateFormatter.formatDateTime(task.updatedAt),
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      _buildMetadataRow(
                        icon: Icons.cloud_sync_rounded,
                        label: 'Sync Status',
                        value: task.isSynced && task.syncAction == 'NONE'
                            ? 'Synced with Firestore'
                            : 'Pending offline sync',
                        trailing: Icon(
                          task.isSynced && task.syncAction == 'NONE'
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_outlined,
                          size: 18,
                          color: task.isSynced && task.syncAction == 'NONE'
                              ? AppColors.synced
                              : AppColors.warning,
                        ),
                      ),
                      Divider(
                        height: 20,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      _buildMetadataRow(
                        icon: Icons.fingerprint_rounded,
                        label: 'Task ID',
                        value: task.id,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Toggle Completion Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isCompleted
                          ? (isDark ? AppColors.darkInputFill : AppColors.lightInputFill)
                          : AppColors.primary,
                      foregroundColor: task.isCompleted
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context
                          .read<TaskBloc>()
                          .add(ToggleTaskCompletionEvent(task!.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            task.isCompleted
                                ? 'Task marked as pending'
                                : 'Task marked as completed! 🎉',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      task.isCompleted
                          ? Icons.undo_rounded
                          : Icons.done_all_rounded,
                      size: 20,
                    ),
                    label: Text(
                      task.isCompleted
                          ? 'Mark as Pending'
                          : 'Mark as Completed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          trailing
        else
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              Navigator.pop(ctx);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task "${task.title}" deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
