import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tasksTableName} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        due_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 1,
        sync_action TEXT NOT NULL DEFAULT 'NONE',
        user_id TEXT
      )
    ''');

    // Create index on is_synced, due_date, and user_id for fast querying
    await db.execute('''
      CREATE INDEX idx_tasks_is_synced ON ${AppConstants.tasksTableName} (is_synced)
    ''');
    await db.execute('''
      CREATE INDEX idx_tasks_due_date ON ${AppConstants.tasksTableName} (due_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_tasks_user_id ON ${AppConstants.tasksTableName} (user_id)
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${AppConstants.tasksTableName} ADD COLUMN user_id TEXT',
      );
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON ${AppConstants.tasksTableName} (user_id)
      ''');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
