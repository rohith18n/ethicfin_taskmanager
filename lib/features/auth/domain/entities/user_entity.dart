import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.isAnonymous = false,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, displayName, isAnonymous, createdAt];
}
