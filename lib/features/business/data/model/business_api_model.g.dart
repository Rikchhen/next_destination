// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessApiModel _$BusinessApiModelFromJson(Map<String, dynamic> json) =>
    BusinessApiModel(
      id: json['_id'] as String?,
      businessName: json['businessName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      password: json['password'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String,
      profilePicture: json['profilePicture'] as String?,
      businessDocument: json['businessDocument'] as String?,
      businessVerified: json['businessVerified'] as bool,
      businessStatus: json['businessStatus'] as String,
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$BusinessApiModelToJson(BusinessApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'businessName': instance.businessName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'password': instance.password,
      'address': instance.address,
      'role': instance.role,
      'profilePicture': instance.profilePicture,
      'businessDocument': instance.businessDocument,
      'businessVerified': instance.businessVerified,
      'businessStatus': instance.businessStatus,
      'rejectionReason': instance.rejectionReason,
    };
