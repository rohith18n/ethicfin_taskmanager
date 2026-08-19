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
        vertical: isCompact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? priority.color.withAlpha(50)
            : priority.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priority.color.withAlpha(isDark ? 100 : 80),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 6 : 8,
            height: isCompact ? 6 : 8,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority.displayName,
            style: TextStyle(
              color: isDark ? Colors.white : priority.color,
              fontSize: isCompact ? 11 : 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
