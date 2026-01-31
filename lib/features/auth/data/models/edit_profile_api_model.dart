import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile_api_model.g.dart';

@JsonSerializable()
class EditProfileApiModel {
  final String? fullName;
  final String? username;
  final String? phoneNumber;
  final String? email;
  final String? profilePicture;

  EditProfileApiModel({
    this.fullName,
    this.username,
    this.phoneNumber,
    this.email,
    this.profilePicture,
  });

  factory EditProfileApiModel.fromJson(Map<String, dynamic> json) =>
      _$EditProfileApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$EditProfileApiModelToJson(this);

  // factory EditProfileApiModel.fromParams(EditProfileUsecaseParams params) {
  //   return EditProfileApiModel(
  //     fullName: params.fullName,
  //     username: params.username,
  //     phoneNumber: params.phoneNumber,
  //     address: params.address,
  //     avatar: params.avatar,
  //   );
  // }
}
