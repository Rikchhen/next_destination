import 'package:next_destination/features/booking/domain/entity/ticket_entity.dart';

class TicketApiModel {
  final String? id;
  final String? booking;
  final String? trip;
  final String? bookedBy;
  final String passengerName;
  final String seatNumber;
  final String status;
  final String? qrToken;
  final DateTime? issuedAt;
  final DateTime? expiresAt;

  TicketApiModel({
    this.id,
    this.booking,
    this.trip,
    this.bookedBy,
    required this.passengerName,
    required this.seatNumber,
    required this.status,
    this.qrToken,
    this.issuedAt,
    this.expiresAt,
  });

  factory TicketApiModel.fromJson(Map<String, dynamic> json) {
    String normalizeId(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value['_id']?.toString() ?? '';
      }
      return value?.toString() ?? '';
    }

    return TicketApiModel(
      id: json['_id']?.toString(),
      booking: normalizeId(json['booking']),
      trip: normalizeId(json['trip']),
      bookedBy: normalizeId(json['bookedBy']),
      passengerName: (json['passengerName'] ?? '').toString(),
      seatNumber: (json['seatNumber'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      qrToken: json['qrToken']?.toString(),
      issuedAt: json['issuedAt'] != null
          ? DateTime.tryParse(json['issuedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }

  TicketEntity toEntity() {
    return TicketEntity(
      ticketId: id,
      bookingId: booking,
      tripId: trip,
      bookedBy: bookedBy,
      passengerName: passengerName,
      seatNumber: seatNumber,
      status: status,
      qrToken: qrToken,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );
  }

  static List<TicketEntity> toEntityList(List<TicketApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
