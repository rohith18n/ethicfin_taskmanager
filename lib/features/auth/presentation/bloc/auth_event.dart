import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequestedEvent extends AuthEvent {
  const AuthCheckRequestedEvent();
}

class AuthUserChangedEvent extends AuthEvent {
  final UserEntity? user;
  const AuthUserChangedEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignInAnonymouslyEvent extends AuthEvent {
  const SignInAnonymouslyEvent();
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
