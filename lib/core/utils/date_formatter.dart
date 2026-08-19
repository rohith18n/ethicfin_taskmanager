import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatRelative(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference == 0) {
      return 'Today, ${formatTime(dueDate)}';
    } else if (difference == 1) {
      return 'Tomorrow, ${formatTime(dueDate)}';
    } else if (difference == -1) {
      return 'Yesterday, ${formatTime(dueDate)}';
    } else if (difference < -1) {
      return 'Overdue by ${-difference} days';
    } else if (difference < 7) {
      return '${DateFormat('EEEE').format(dueDate)}, ${formatTime(dueDate)}';
    } else {
      return formatDateTime(dueDate);
    }
  }

  static bool isOverdue(DateTime dueDate, bool isCompleted) {
    if (isCompleted) return false;
    return dueDate.isBefore(DateTime.now());
  }
}
