import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final WatchAuthStateUseCase watchAuthStateUseCase;
  final SignInWithEmailUseCase signInWithEmailUseCase;
  final SignUpWithEmailUseCase signUpWithEmailUseCase;
  final SignInAnonymouslyUseCase signInAnonymouslyUseCase;
  final SignOutUseCase signOutUseCase;

  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required this.getCurrentUserUseCase,
    required this.watchAuthStateUseCase,
    required this.signInWithEmailUseCase,
    required this.signUpWithEmailUseCase,
    required this.signInAnonymouslyUseCase,
    required this.signOutUseCase,
  }) : super(const AuthState()) {
    on<AuthCheckRequestedEvent>(_onAuthCheckRequested);
    on<AuthUserChangedEvent>(_onAuthUserChanged);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInAnonymouslyEvent>(_onSignInAnonymously);
    on<SignOutEvent>(_onSignOut);

    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authStateSubscription = watchAuthStateUseCase().listen(
      (user) {
        if (!isClosed) {
          add(AuthUserChangedEvent(user));
        }
      },
      onError: (_) {
        if (!isClosed) {
          add(const AuthUserChangedEvent(null));
        }
      },
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      ));
    }
  }

  void _onAuthUserChanged(
    AuthUserChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: event.user,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      ));
    }
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await signInWithEmailUseCase(event.email, event.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await signUpWithEmailUseCase(
        event.email,
        event.password,
        displayName: event.displayName,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymouslyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await signInAnonymouslyUseCase();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await signOutUseCase();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is ServerException) {
      return error.message;
    }
    final raw = error.toString();
    if (raw.startsWith('ServerException: ')) {
      return raw.substring('ServerException: '.length);
    }
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }
    return raw;
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
