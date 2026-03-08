import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:next_destination/features/business/domain/entity/business_entity.dart';

part 'business_api_model.g.dart';

@JsonSerializable()
class BusinessApiModel {
  @JsonKey(name: '_id')
  final String? id;
  final String businessName;
  final String email;
  final String phoneNumber;
  final String? password;
  final String? address;
  final String role;
  final String? profilePicture;
  final String? businessDocument;
  final bool businessVerified;
  final String businessStatus;
  final String? rejectionReason;

  BusinessApiModel({
    this.id,
    required this.businessName,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.address,
    required this.role,
    this.profilePicture,
    this.businessDocument,
    required this.businessVerified,
    required this.businessStatus,
    this.rejectionReason,
  });

  factory BusinessApiModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessApiModelToJson(this);

  BusinessEntity toEntity() {
    return BusinessEntity(
      businessId: id,
      businessName: businessName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      address: address,
      role: role,
      profilePicture: profilePicture,
      businessDocument: businessDocument,
      businessVerified: businessVerified,
      businessStatus: businessStatus,
      rejectionReason: rejectionReason,
    );
  }

  factory BusinessApiModel.fromEntity(BusinessEntity entity) {
    return BusinessApiModel(
      id: entity.businessId,
      businessName: entity.businessName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      address: entity.address,
      role: entity.role,
      profilePicture: entity.profilePicture,
      businessDocument: entity.businessDocument,
      businessVerified: entity.businessVerified,
      businessStatus: entity.businessStatus,
      rejectionReason: entity.rejectionReason,
    );
  }

  static List<BusinessEntity> toEntityList(List<BusinessApiModel> model) {
    return model.map((e) => e.toEntity()).toList();
  }
}
