import 'package:equatable/equatable.dart';
import 'package:next_destination/features/business/domain/entity/business_entity.dart';

enum BusinessStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  edited,
  documentUploaded,
  fetchedAll,
  approved,
  rejected,
  error,
  success,
}

class BusinessState extends Equatable {
  final BusinessStatus status;
  final BusinessEntity? businessEntity;
  final List<BusinessEntity> businesses;
  final String? errorMessage;

  const BusinessState({
    this.status = BusinessStatus.initial,
    this.businessEntity,
    this.businesses = const [],
    this.errorMessage,
  });

  BusinessState copyWith({
    BusinessStatus? status,
    BusinessEntity? businessEntity,
    List<BusinessEntity>? businesses,
    String? errorMessage,
  }) {
    return BusinessState(
      status: status ?? this.status,
      businessEntity: businessEntity ?? this.businessEntity,
      businesses: businesses ?? this.businesses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, businessEntity, businesses, errorMessage];
}
