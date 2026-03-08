import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
part 'user_api_model.g.dart';

@JsonSerializable()
class UserApiModel {
  @JsonKey(name: '_id')
  final String? id;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String phoneNumber;
  final String? profilePicture;

  UserApiModel({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    this.password,
    this.confirmPassword,
    this.profilePicture,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) =>
      _$UserApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserApiModelToJson(this);

  // To Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: id,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
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
      profilePicture: entity.profilePicture,
    );
  }

  // To Entity List
  static List<UserEntity> toEntityList(List<UserApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
