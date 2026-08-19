class AppConstants {
  static const String appTitle = 'EthicFin TaskManager';
  static const String tasksTableName = 'tasks';
  static const String firestoreTasksCollection = 'tasks';
  static const String firestoreUsersCollection = 'users';
  static const String databaseName = 'ethicfin_tasks.db';
  static const int databaseVersion = 2;

  // Sync Action Constants
  static const String syncActionNone = 'NONE';
  static const String syncActionInsert = 'INSERT';
  static const String syncActionUpdate = 'UPDATE';
  static const String syncActionDelete = 'DELETE';

  // Notification Constants
  static const String notificationChannelId = 'ethicfin_tasks_channel';
  static const String notificationChannelName = 'Task Reminders & Updates';
  static const String notificationChannelDescription = 'Notifications for task due dates and updates';
}
