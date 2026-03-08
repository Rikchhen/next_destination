import 'package:equatable/equatable.dart';

class TripEntity extends Equatable {
  final String? tripId;
  final String? businessId;
  final String type;
  final String from;
  final String to;
  final DateTime departureAt;
  final DateTime? arrivalAt;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String status;

  const TripEntity({
    this.tripId,
    this.businessId,
    required this.type,
    required this.from,
    required this.to,
    required this.departureAt,
    this.arrivalAt,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
  });

  @override
  List<Object?> get props => [
    tripId,
    businessId,
    type,
    from,
    to,
    departureAt,
    arrivalAt,
    price,
    totalSeats,
    availableSeats,
    status,
  ];
}
