import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_filter.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_sort.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/sync_tasks_usecase.dart';
import '../../domain/usecases/toggle_task_completion_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final ToggleTaskCompletionUseCase toggleTaskCompletionUseCase;
  final SyncTasksUseCase syncTasksUseCase;
  final NetworkInfo networkInfo;

  StreamSubscription<bool>? _connectivitySubscription;

  TaskBloc({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskCompletionUseCase,
    required this.syncTasksUseCase,
    required this.networkInfo,
  }) : super(const TaskState()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<SearchTasksEvent>(_onSearchTasks);
    on<ChangeFilterEvent>(_onChangeFilter);
    on<ChangePriorityFilterEvent>(_onChangePriorityFilter);
    on<ChangeSortEvent>(_onChangeSort);
    on<SyncTasksEvent>(_onSyncTasks);
    on<NetworkStatusChangedEvent>(_onNetworkStatusChanged);

    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    networkInfo.isConnected.then((connected) {
      if (!isClosed) {
        try {
          add(NetworkStatusChangedEvent(connected));
        } catch (_) {}
      }
    });

    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((connected) {
      if (!isClosed) {
        try {
          add(NetworkStatusChangedEvent(connected));
        } catch (_) {}
      }
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: null));
    try {
      final tasks = await getTasksUseCase();
      final filtered = _filterAndSort(
        tasks: tasks,
        query: state.searchQuery,
        filter: state.filter,
        priority: state.priorityFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: TaskStatus.success,
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to load tasks: $e',
      ));
    }
  }

  Future<void> _onCreateTask(CreateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await createTaskUseCase(event.task);
      final tasks = await getTasksUseCase();
      final filtered = _filterAndSort(
        tasks: tasks,
        query: state.searchQuery,
        filter: state.filter,
        priority: state.priorityFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: TaskStatus.success,
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to create task: $e',
      ));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await updateTaskUseCase(event.task);
      final tasks = await getTasksUseCase();
      final filtered = _filterAndSort(
        tasks: tasks,
        query: state.searchQuery,
        filter: state.filter,
        priority: state.priorityFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: TaskStatus.success,
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to update task: $e',
      ));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await deleteTaskUseCase(event.id);
      final tasks = await getTasksUseCase();
      final filtered = _filterAndSort(
        tasks: tasks,
        query: state.searchQuery,
        filter: state.filter,
        priority: state.priorityFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: TaskStatus.success,
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to delete task: $e',
      ));
    }
  }

  Future<void> _onToggleTaskCompletion(
    ToggleTaskCompletionEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await toggleTaskCompletionUseCase(event.id);
      final tasks = await getTasksUseCase();
      final filtered = _filterAndSort(
        tasks: tasks,
        query: state.searchQuery,
        filter: state.filter,
        priority: state.priorityFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        status: TaskStatus.success,
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to update task status: $e',
      ));
    }
  }

  void _onSearchTasks(SearchTasksEvent event, Emitter<TaskState> emit) {
    final filtered = _filterAndSort(
      tasks: state.allTasks,
      query: event.query,
      filter: state.filter,
      priority: state.priorityFilter,
      sortBy: state.sortBy,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      filteredTasks: filtered,
    ));
  }

  void _onChangeFilter(ChangeFilterEvent event, Emitter<TaskState> emit) {
    final filtered = _filterAndSort(
      tasks: state.allTasks,
      query: state.searchQuery,
      filter: event.filter,
      priority: state.priorityFilter,
      sortBy: state.sortBy,
    );
    emit(state.copyWith(
      filter: event.filter,
      filteredTasks: filtered,
    ));
  }

  void _onChangePriorityFilter(ChangePriorityFilterEvent event, Emitter<TaskState> emit) {
    final filtered = _filterAndSort(
      tasks: state.allTasks,
      query: state.searchQuery,
      filter: state.filter,
      priority: event.priority,
      sortBy: state.sortBy,
    );
    emit(state.copyWith(
      priorityFilter: () => event.priority,
      filteredTasks: filtered,
    ));
  }

  void _onChangeSort(ChangeSortEvent event, Emitter<TaskState> emit) {
    final filtered = _filterAndSort(
      tasks: state.allTasks,
      query: state.searchQuery,
      filter: state.filter,
      priority: state.priorityFilter,
      sortBy: event.sortBy,
    );
    emit(state.copyWith(
      sortBy: event.sortBy,
      filteredTasks: filtered,
    ));
  }

  Future<void> _onSyncTasks(SyncTasksEvent event, Emitter<TaskState> emit) async {
    if (state.isSyncing) return;
    emit(state.copyWith(isSyncing: true));

    try {
      await syncTasksUseCase();
      final tasks = await getTasksUseCase();
      final filtered = _filterAndSort(
        tasks: tasks,
        query: state.searchQuery,
        filter: state.filter,
        priority: state.priorityFilter,
        sortBy: state.sortBy,
      );
      emit(state.copyWith(
        isSyncing: false,
        allTasks: tasks,
        filteredTasks: filtered,
        lastSyncedAt: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isSyncing: false,
        errorMessage: 'Sync error: $e',
      ));
    }
  }

  Future<void> _onNetworkStatusChanged(
    NetworkStatusChangedEvent event,
    Emitter<TaskState> emit,
  ) async {
    final wasOffline = !state.isOnline;
    emit(state.copyWith(isOnline: event.isConnected));

    // If connectivity was restored, automatically trigger sync!
    if (wasOffline && event.isConnected) {
      add(const SyncTasksEvent());
    }
  }

  List<TaskEntity> _filterAndSort({
    required List<TaskEntity> tasks,
    required String query,
    required TaskFilter filter,
    required TaskPriority? priority,
    required TaskSortBy sortBy,
  }) {
    var result = List<TaskEntity>.from(tasks);

    // 1. Text Search (title and description)
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((task) {
        return task.title.toLowerCase().contains(q) ||
            task.description.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Status Filter
    switch (filter) {
      case TaskFilter.all:
        break;
      case TaskFilter.pending:
        result = result.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        result = result.where((task) => task.isCompleted).toList();
        break;
    }

    // 3. Priority Filter
    if (priority != null) {
      result = result.where((task) => task.priority == priority).toList();
    }

    // 4. Sorting
    result.sort((a, b) {
      switch (sortBy) {
        case TaskSortBy.dueDateAsc:
          return a.dueDate.compareTo(b.dueDate);
        case TaskSortBy.dueDateDesc:
          return b.dueDate.compareTo(a.dueDate);
        case TaskSortBy.priorityHighToLow:
          return b.priority.rank.compareTo(a.priority.rank);
        case TaskSortBy.priorityLowToHigh:
          return a.priority.rank.compareTo(b.priority.rank);
        case TaskSortBy.createdDateDesc:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return result;
  }
}
