import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_priority.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    required super.dueDate,
    required super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
    super.isSynced = true,
    super.syncAction = 'NONE',
    super.userId,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      priority: entity.priority,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
      syncAction: entity.syncAction,
      userId: entity.userId,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: TaskPriority.fromString(json['priority'] as String?),
      dueDate: DateTime.parse(json['due_date'] as String? ?? json['dueDate'] as String),
      isCompleted: json['is_completed'] == 1 || json['isCompleted'] == true,
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? json['updatedAt'] as String),
      isSynced: json['is_synced'] == 1 || json['isSynced'] == true,
      syncAction: json['sync_action'] as String? ?? json['syncAction'] as String? ?? 'NONE',
      userId: json['user_id'] as String? ?? json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'syncAction': syncAction,
      'userId': userId,
    };
  }

  factory TaskModel.fromSqflite(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      priority: TaskPriority.fromString(map['priority'] as String),
      dueDate: DateTime.parse(map['due_date'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: (map['is_synced'] as int) == 1,
      syncAction: map['sync_action'] as String? ?? 'NONE',
      userId: map['user_id'] as String?,
    );
  }

  Map<String, dynamic> toSqflite() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'sync_action': syncAction,
      'user_id': userId,
    };
  }

  factory TaskModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priority: TaskPriority.fromString(map['priority'] as String?),
      dueDate: DateTime.parse(map['dueDate'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isSynced: true,
      syncAction: 'NONE',
      userId: map['userId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
    };
  }

  @override
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? syncAction,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncAction: syncAction ?? this.syncAction,
      userId: userId ?? this.userId,
    );
  }
}
