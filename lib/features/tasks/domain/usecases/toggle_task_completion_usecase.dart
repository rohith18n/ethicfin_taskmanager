import '../repositories/task_repository.dart';

class ToggleTaskCompletionUseCase {
  final TaskRepository repository;

  ToggleTaskCompletionUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.toggleTaskCompletion(id);
  }
}
