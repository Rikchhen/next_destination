// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_business_profile_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditBusinessProfileApiModel _$EditBusinessProfileApiModelFromJson(
        Map<String, dynamic> json) =>
    EditBusinessProfileApiModel(
      businessName: json['businessName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );

Map<String, dynamic> _$EditBusinessProfileApiModelToJson(
        EditBusinessProfileApiModel instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'profilePicture': instance.profilePicture,
    };
