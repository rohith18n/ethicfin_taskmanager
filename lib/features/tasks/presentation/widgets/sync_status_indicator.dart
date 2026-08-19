import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      buildWhen: (previous, current) =>
          previous.isOnline != current.isOnline ||
          previous.isSyncing != current.isSyncing ||
          previous.pendingSyncCount != current.pendingSyncCount,
      builder: (context, state) {
        Color badgeColor;
        IconData iconData;
        String tooltip;

        if (state.isSyncing) {
          badgeColor = AppColors.syncing;
          iconData = Icons.sync_rounded;
          tooltip = 'Syncing tasks with cloud...';
        } else if (!state.isOnline) {
          badgeColor = AppColors.offline;
          iconData = Icons.cloud_off_rounded;
          tooltip = 'Offline Mode (${state.pendingSyncCount} changes queued)';
        } else if (state.pendingSyncCount > 0) {
          badgeColor = AppColors.unsynced;
          iconData = Icons.cloud_upload_outlined;
          tooltip = '${state.pendingSyncCount} pending changes. Tap to sync.';
        } else {
          badgeColor = AppColors.synced;
          iconData = Icons.cloud_done_rounded;
          tooltip = 'All changes synced with cloud';
        }

        return Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: () {
              if (state.isOnline && !state.isSyncing) {
                context.read<TaskBloc>().add(const SyncTasksEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Syncing tasks...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else if (!state.isOnline) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'You are offline. ${state.pendingSyncCount} changes queued.',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: badgeColor.withAlpha(80),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.isSyncing)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                      ),
                    )
                  else
                    Icon(
                      iconData,
                      size: 16,
                      color: badgeColor,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    state.isSyncing
                        ? 'Syncing'
                        : !state.isOnline
                            ? 'Offline'
                            : state.pendingSyncCount > 0
                                ? '${state.pendingSyncCount} Queued'
                                : 'Synced',
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
