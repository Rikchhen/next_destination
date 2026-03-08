import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';

class TicketApiModel {
  final String? id;
  final String booking;
  final String trip;
  final String bookedBy;
  final String passengerName;
  final String seatNumber;
  final String qrToken;
  final String status;
  final DateTime? issuedAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;
  final String? voidReason;

  TicketApiModel({
    this.id,
    required this.booking,
    required this.trip,
    required this.bookedBy,
    required this.passengerName,
    required this.seatNumber,
    required this.qrToken,
    required this.status,
    this.issuedAt,
    this.usedAt,
    this.expiresAt,
    this.voidReason,
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
      qrToken: (json['qrToken'] ?? '').toString(),
      status: (json['status'] ?? 'issued').toString(),
      issuedAt: json['issuedAt'] != null
          ? DateTime.tryParse(json['issuedAt'].toString())
          : null,
      usedAt: json['usedAt'] != null
          ? DateTime.tryParse(json['usedAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      voidReason: json['voidReason']?.toString(),
    );
  }

  TicketEntity toEntity() {
    return TicketEntity(
      ticketId: id,
      booking: booking,
      trip: trip,
      bookedBy: bookedBy,
      passengerName: passengerName,
      seatNumber: seatNumber,
      qrToken: qrToken,
      status: status,
      issuedAt: issuedAt,
      usedAt: usedAt,
      expiresAt: expiresAt,
      voidReason: voidReason,
    );
  }

  static List<TicketEntity> toEntityList(List<TicketApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
