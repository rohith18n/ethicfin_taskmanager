import 'package:bloc_test/bloc_test.dart';
import 'package:ethicfin_taskmanager/features/auth/domain/entities/user_entity.dart';
import 'package:ethicfin_taskmanager/features/auth/domain/usecases/auth_usecases.dart';
import 'package:ethicfin_taskmanager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ethicfin_taskmanager/features/auth/presentation/bloc/auth_event.dart';
import 'package:ethicfin_taskmanager/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}
class MockSignInWithEmailUseCase extends Mock implements SignInWithEmailUseCase {}
class MockSignUpWithEmailUseCase extends Mock implements SignUpWithEmailUseCase {}
class MockSignInAnonymouslyUseCase extends Mock implements SignInAnonymouslyUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockWatchAuthStateUseCase mockWatchAuthStateUseCase;
  late MockSignInWithEmailUseCase mockSignInWithEmailUseCase;
  late MockSignUpWithEmailUseCase mockSignUpWithEmailUseCase;
  late MockSignInAnonymouslyUseCase mockSignInAnonymouslyUseCase;
  late MockSignOutUseCase mockSignOutUseCase;

  setUp(() {
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockWatchAuthStateUseCase = MockWatchAuthStateUseCase();
    mockSignInWithEmailUseCase = MockSignInWithEmailUseCase();
    mockSignUpWithEmailUseCase = MockSignUpWithEmailUseCase();
    mockSignInAnonymouslyUseCase = MockSignInAnonymouslyUseCase();
    mockSignOutUseCase = MockSignOutUseCase();

    when(() => mockWatchAuthStateUseCase()).thenAnswer((_) => const Stream.empty());
  });

  const testUser = UserEntity(
    id: 'user-123',
    email: 'rohith@ethicfin.com',
    displayName: 'Rohith',
  );

  AuthBloc buildBloc() {
    return AuthBloc(
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      watchAuthStateUseCase: mockWatchAuthStateUseCase,
      signInWithEmailUseCase: mockSignInWithEmailUseCase,
      signUpWithEmailUseCase: mockSignUpWithEmailUseCase,
      signInAnonymouslyUseCase: mockSignInAnonymouslyUseCase,
      signOutUseCase: mockSignOutUseCase,
    );
  }

  group('AuthBloc Tests', () {
    test('initial state is AuthStatus.initial', () {
      final bloc = buildBloc();
      expect(bloc.state.status, AuthStatus.initial);
    });

    blocTest<AuthBloc, AuthState>(
      'emits [authenticated] when user signs in with email successfully',
      build: () {
        when(() => mockSignInWithEmailUseCase('test@example.com', 'password123'))
            .thenAnswer((_) async => testUser);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithEmailEvent(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.authenticated, user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when user signs out',
      build: () {
        when(() => mockSignOutUseCase()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const AuthState(status: AuthStatus.loading),
        const AuthState(status: AuthStatus.unauthenticated, user: null),
      ],
    );
  });
}
