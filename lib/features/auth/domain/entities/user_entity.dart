import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String? email;
  final String? password;
  final String phoneNumber;

  const UserEntity({
    this.userId,
    required this.fullName,
    this.email,
    required this.password,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [userId, fullName, email, password, phoneNumber];
}
