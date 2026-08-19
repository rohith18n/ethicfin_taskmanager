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

    Color bgColor;
    Color textColor;
    Color dotColor;

    switch (priority) {
      case TaskPriority.urgent:
        bgColor = isDark ? const Color(0xFF4C151B) : const Color(0xFFFEE2E2);
        textColor = isDark ? const Color(0xFFFF6B7D) : const Color(0xFFDC2626);
        dotColor = isDark ? const Color(0xFFFF6B7D) : const Color(0xFFDC2626);
        break;
      case TaskPriority.high:
        bgColor = isDark ? const Color(0xFF4A3408) : const Color(0xFFFEF3C7);
        textColor = isDark ? const Color(0xFFFFB020) : const Color(0xFFB45309);
        dotColor = isDark ? const Color(0xFFFFB020) : const Color(0xFFD97706);
        break;
      case TaskPriority.medium:
        bgColor = isDark ? const Color(0xFF0B3349) : const Color(0xFFE0F2FE);
        textColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);
        dotColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
        break;
      case TaskPriority.low:
        bgColor = isDark ? const Color(0xFF0C3B2E) : const Color(0xFFDCFCE7);
        textColor = isDark ? const Color(0xFF25D366) : const Color(0xFF15803D);
        dotColor = isDark ? const Color(0xFF25D366) : const Color(0xFF16A34A);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 6 : 7,
            height: isCompact ? 6 : 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            priority.displayName,
            style: TextStyle(
              color: textColor,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
