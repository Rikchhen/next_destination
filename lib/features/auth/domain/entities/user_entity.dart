import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final String confirmPassword;

  const UserEntity({
    this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [userId, fullName, email, password, phoneNumber];
}
