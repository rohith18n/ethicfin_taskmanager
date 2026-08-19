import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() => repository.getCurrentUser();
}

class WatchAuthStateUseCase {
  final AuthRepository repository;
  WatchAuthStateUseCase(this.repository);

  Stream<UserEntity?> call() => repository.authStateChanges;
}

class SignInWithEmailUseCase {
  final AuthRepository repository;
  SignInWithEmailUseCase(this.repository);

  Future<UserEntity> call(String email, String password) =>
      repository.signInWithEmail(email, password);
}

class SignUpWithEmailUseCase {
  final AuthRepository repository;
  SignUpWithEmailUseCase(this.repository);

  Future<UserEntity> call(String email, String password, {String? displayName}) =>
      repository.signUpWithEmail(email, password, displayName: displayName);
}

class SignInAnonymouslyUseCase {
  final AuthRepository repository;
  SignInAnonymouslyUseCase(this.repository);

  Future<UserEntity> call() => repository.signInAnonymously();
}

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> call() => repository.signOut();
}
