// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approve_business_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApproveBusinessApiModel _$ApproveBusinessApiModelFromJson(
        Map<String, dynamic> json) =>
    ApproveBusinessApiModel(
      action: json['action'] as String,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$ApproveBusinessApiModelToJson(
        ApproveBusinessApiModel instance) =>
    <String, dynamic>{
      'action': instance.action,
      'reason': instance.reason,
    };
