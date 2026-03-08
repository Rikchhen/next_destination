import 'package:equatable/equatable.dart';
import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';

class BookingEntity extends Equatable {
  final String? bookingId;
  final String bookedBy;
  final String trip;
  final String bookingRef;
  final String status;
  final List<PassengerEntity> passengers;
  final String contactEmail;
  final String contactPhone;
  final double totalAmount;
  final String? cancelReason;
  final DateTime? createdAt;

  const BookingEntity({
    this.bookingId,
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

  @override
  List<Object?> get props => [
    bookingId,
    bookedBy,
    trip,
    bookingRef,
    status,
    passengers,
    contactEmail,
    contactPhone,
    totalAmount,
    cancelReason,
    createdAt,
  ];
}
