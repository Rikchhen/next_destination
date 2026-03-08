import 'package:equatable/equatable.dart';

class BusinessEntity extends Equatable {
  final String? businessId;
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

  const BusinessEntity({
    this.businessId,
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

  @override
  List<Object?> get props => [
    businessId,
    businessName,
    email,
    phoneNumber,
    password,
    address,
    role,
    profilePicture,
    businessDocument,
    businessVerified,
    businessStatus,
    rejectionReason,
  ];
}
