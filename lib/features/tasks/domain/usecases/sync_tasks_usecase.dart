import '../repositories/task_repository.dart';

class SyncTasksUseCase {
  final TaskRepository repository;

  SyncTasksUseCase(this.repository);

  Future<void> call({String? userId}) async {
    return await repository.syncPendingTasks(userId: userId);
  }
}
