import 'package:freezed_annotation/freezed_annotation.dart';

part 'approve_business_api_model.g.dart';

@JsonSerializable()
class ApproveBusinessApiModel {
  final String action;
  final String? reason;

  ApproveBusinessApiModel({required this.action, this.reason});

  factory ApproveBusinessApiModel.fromJson(Map<String, dynamic> json) =>
      _$ApproveBusinessApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApproveBusinessApiModelToJson(this);
}
