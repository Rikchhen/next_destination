import 'package:freezed_annotation/freezed_annotation.dart';
part 'edit_business_profile_api_model.g.dart';

@JsonSerializable()
class EditBusinessProfileApiModel {
  final String? businessName;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? profilePicture;

  EditBusinessProfileApiModel({
    this.businessName,
    this.email,
    this.phoneNumber,
    this.address,
    this.profilePicture,
  });

  factory EditBusinessProfileApiModel.fromJson(Map<String, dynamic> json) =>
      _$EditBusinessProfileApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$EditBusinessProfileApiModelToJson(this);
}
