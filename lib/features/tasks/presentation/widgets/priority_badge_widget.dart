import 'package:flutter/material.dart';
import '../../domain/enums/task_priority.dart';

class PriorityBadgeWidget extends StatelessWidget {
  final TaskPriority priority;
  final bool isCompact;

  const PriorityBadgeWidget({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: isDark ? priority.backgroundColor : priority.backgroundColor.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 6 : 7,
            height: isCompact ? 6 : 7,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            priority.displayName,
            style: TextStyle(
              color: priority.color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
