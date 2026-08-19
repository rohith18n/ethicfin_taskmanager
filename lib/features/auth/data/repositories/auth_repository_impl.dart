import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<UserEntity?> getCurrentUser() => remoteDataSource.getCurrentUser();

  @override
  Future<UserEntity> signInWithEmail(String email, String password) =>
      remoteDataSource.signInWithEmail(email, password);

  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) =>
      remoteDataSource.signUpWithEmail(email, password, displayName: displayName);

  @override
  Future<UserEntity> signInAnonymously() => remoteDataSource.signInAnonymously();

  @override
  Future<void> signOut() => remoteDataSource.signOut();
}
