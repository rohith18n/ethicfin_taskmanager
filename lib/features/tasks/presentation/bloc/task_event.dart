import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_filter.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_sort.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final String? userId;
  const LoadTasksEvent([this.userId]);

  @override
  List<Object?> get props => [userId];
}

class CreateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const CreateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String id;

  const DeleteTaskEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final String id;

  const ToggleTaskCompletionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ChangeFilterEvent extends TaskEvent {
  final TaskFilter filter;

  const ChangeFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ChangePriorityFilterEvent extends TaskEvent {
  final TaskPriority? priority;

  const ChangePriorityFilterEvent(this.priority);

  @override
  List<Object?> get props => [priority];
}

class ChangeSortEvent extends TaskEvent {
  final TaskSortBy sortBy;

  const ChangeSortEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class SyncTasksEvent extends TaskEvent {
  final String? userId;
  const SyncTasksEvent([this.userId]);

  @override
  List<Object?> get props => [userId];
}

class NetworkStatusChangedEvent extends TaskEvent {
  final bool isConnected;

  const NetworkStatusChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}
