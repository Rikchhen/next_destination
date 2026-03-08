import 'package:next_destination/features/booking/data/model/passenger_api_model.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';

class BookingApiModel {
  final String? id;
  final String bookedBy;
  final String trip;
  final String bookingRef;
  final String status;
  final List<PassengerApiModel> passengers;
  final String contactEmail;
  final String contactPhone;
  final double totalAmount;
  final String? cancelReason;
  final DateTime? createdAt;

  BookingApiModel({
    this.id,
    required this.bookedBy,
    required this.trip,
    required this.bookingRef,
    required this.status,
    required this.passengers,
    required this.contactEmail,
    required this.contactPhone,
    required this.totalAmount,
    this.cancelReason,
    this.createdAt,
  });

  factory BookingApiModel.fromJson(Map<String, dynamic> json) {
    String normalizeId(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value['_id']?.toString() ?? '';
      }
      return value?.toString() ?? '';
    }

    return BookingApiModel(
      id: json['_id']?.toString(),
      bookedBy: normalizeId(json['bookedBy']),
      trip: normalizeId(json['trip']),
      bookingRef: (json['bookingRef'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      passengers: (json['passengers'] as List<dynamic>? ?? [])
          .map((e) => PassengerApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      contactEmail: (json['contactEmail'] ?? '').toString(),
      contactPhone: (json['contactPhone'] ?? '').toString(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      cancelReason: json['cancelReason']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'trip': trip,
      'passengers': passengers.map((e) => e.toJson()).toList(),
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
    };
  }

  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: id,
      bookedBy: bookedBy,
      trip: trip,
      bookingRef: bookingRef,
      status: status,
      passengers: PassengerApiModel.toEntityList(passengers),
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      totalAmount: totalAmount,
      cancelReason: cancelReason,
      createdAt: createdAt,
    );
  }

  factory BookingApiModel.fromEntity(BookingEntity entity) {
    return BookingApiModel(
      id: entity.bookingId,
      bookedBy: entity.bookedBy,
      trip: entity.trip,
      bookingRef: entity.bookingRef,
      status: entity.status,
      passengers: entity.passengers
          .map((e) => PassengerApiModel.fromEntity(e))
          .toList(),
      contactEmail: entity.contactEmail,
      contactPhone: entity.contactPhone,
      totalAmount: entity.totalAmount,
      cancelReason: entity.cancelReason,
      createdAt: entity.createdAt,
    );
  }

  static List<BookingEntity> toEntityList(List<BookingApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
