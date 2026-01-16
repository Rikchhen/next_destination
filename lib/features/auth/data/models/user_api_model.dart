import 'package:next_destination/features/auth/domain/entities/user_entity.dart';

class UserApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;

  UserApiModel({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  // To JSON
  // Using dynamic because user le j pani value pathauna paayo
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
    };
  }

  // From JSON

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    final userJson =
        json['user'] ??
        json; // null safety measure. the code kept throwing it because some feilds were being returned null
    return UserApiModel(
      id: userJson['_id'] as String?,
      fullName: userJson['fullName'] as String? ?? '',
      email: userJson['email'] as String? ?? '',
      password: userJson['password'] as String? ?? '',
      confirmPassword: userJson['confirmPassword'] as String? ?? '',
      phoneNumber: userJson['phoneNumber'] as String? ?? '',
    );
  }

  // To Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: id,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
    );
  }

  // From Entity
  factory UserApiModel.fromEntity(UserEntity entity) {
    return UserApiModel(
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  // To Entity List
  static List<UserEntity> toEntityList(List<UserApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
