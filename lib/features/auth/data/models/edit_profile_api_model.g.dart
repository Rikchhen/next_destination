// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditProfileApiModel _$EditProfileApiModelFromJson(Map<String, dynamic> json) =>
    EditProfileApiModel(
      fullName: json['fullName'] as String?,
      username: json['username'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$EditProfileApiModelToJson(
        EditProfileApiModel instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'profilePicture': instance.profilePicture,
    };
