import '../entities/task_entity.dart';

enum ConflictResolutionStrategy {
  lastWriteWins,
  localWins,
  remoteWins,
}

class ConflictResolutionResult {
  final TaskEntity resolvedTask;
  final bool wasConflict;
  final String winner; // 'LOCAL' or 'REMOTE'

  const ConflictResolutionResult({
    required this.resolvedTask,
    required this.wasConflict,
    required this.winner,
  });
}

class ConflictResolver {
  final ConflictResolutionStrategy defaultStrategy;

  const ConflictResolver({
    this.defaultStrategy = ConflictResolutionStrategy.lastWriteWins,
  });

  /// Resolves conflicts between a local version and remote version of a Task
  ConflictResolutionResult resolve({
    required TaskEntity localTask,
    required TaskEntity remoteTask,
    ConflictResolutionStrategy? strategy,
  }) {
    final effectiveStrategy = strategy ?? defaultStrategy;

    switch (effectiveStrategy) {
      case ConflictResolutionStrategy.localWins:
        return ConflictResolutionResult(
          resolvedTask: localTask,
          wasConflict: true,
          winner: 'LOCAL',
        );

      case ConflictResolutionStrategy.remoteWins:
        return ConflictResolutionResult(
          resolvedTask: remoteTask,
          wasConflict: true,
          winner: 'REMOTE',
        );

      case ConflictResolutionStrategy.lastWriteWins:
        // Compare updatedAt timestamps
        final localUpdated = localTask.updatedAt;
        final remoteUpdated = remoteTask.updatedAt;

        if (localUpdated.isAfter(remoteUpdated)) {
          // Local is newer -> Local wins
          return ConflictResolutionResult(
            resolvedTask: localTask,
            wasConflict: true,
            winner: 'LOCAL',
          );
        } else if (remoteUpdated.isAfter(localUpdated)) {
          // Remote is newer -> Remote wins
          return ConflictResolutionResult(
            resolvedTask: remoteTask.copyWith(
              isSynced: true,
              syncAction: 'NONE',
            ),
            wasConflict: true,
            winner: 'REMOTE',
          );
        } else {
          // Exactly same timestamp -> Prefer remote for consistency
          return ConflictResolutionResult(
            resolvedTask: remoteTask.copyWith(
              isSynced: true,
              syncAction: 'NONE',
            ),
            wasConflict: false,
            winner: 'REMOTE',
          );
        }
    }
  }
}
