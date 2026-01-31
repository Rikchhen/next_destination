import 'package:hive_flutter/hive_flutter.dart';
import 'package:next_destination/core/constants/hive_table_constant.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';

part 'user_hive_model.g.dart';

// dart run build_runner build -d : CLI command to generate the adapter file
@HiveType(typeId: HiveTableConstant.userTypeId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? confirmPassword;

  @HiveField(5)
  final String phoneNumber;

  @HiveField(6)
  final String? profilePicture;

  UserHiveModel({
    String? userId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    required this.phoneNumber,
    this.profilePicture,
  }) : userId = userId ?? Uuid().v4();

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
    );
  }

  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      profilePicture: entity.profilePicture,
    );
  }

  static List<UserEntity> toEntityList(List<UserHiveModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
