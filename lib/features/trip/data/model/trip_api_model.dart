import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';

class TripApiModel {
  final String? id;
  final String? business;
  final String type;
  final String from;
  final String to;
  final DateTime departureAt;
  final DateTime? arrivalAt;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String status;

  TripApiModel({
    this.id,
    this.business,
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

  factory TripApiModel.fromJson(Map<String, dynamic> json) {
    final businessValue = json['business'];
    final businessId = businessValue is Map<String, dynamic>
        ? businessValue['_id']?.toString()
        : businessValue?.toString();

    return TripApiModel(
      id: json['_id']?.toString(),
      business: businessId,
      type: (json['type'] ?? '').toString(),
      from: (json['from'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      departureAt: DateTime.parse(json['departureAt'].toString()),
      arrivalAt: json['arrivalAt'] != null
          ? DateTime.parse(json['arrivalAt'].toString())
          : null,
      price: (json['price'] as num).toDouble(),
      totalSeats: (json['totalSeats'] as num).toInt(),
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'active').toString(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'type': type,
      'from': from,
      'to': to,
      'departureAt': departureAt.toIso8601String(),
      if (arrivalAt != null) 'arrivalAt': arrivalAt!.toIso8601String(),
      'price': price,
      'totalSeats': totalSeats,
      'status': status,
    };
  }

  Map<String, dynamic> toEditJson() {
    return {
      if (from.trim().isNotEmpty) 'from': from,
      if (to.trim().isNotEmpty) 'to': to,
      'departureAt': departureAt.toIso8601String(),
      if (arrivalAt != null) 'arrivalAt': arrivalAt!.toIso8601String(),
      'price': price,
      'totalSeats': totalSeats,
      'status': status,
    };
  }

  TripEntity toEntity() {
    return TripEntity(
      tripId: id,
      businessId: business,
      type: type,
      from: from,
      to: to,
      departureAt: departureAt,
      arrivalAt: arrivalAt,
      price: price,
      totalSeats: totalSeats,
      availableSeats: availableSeats,
      status: status,
    );
  }

  factory TripApiModel.fromEntity(TripEntity entity) {
    return TripApiModel(
      id: entity.tripId,
      business: entity.businessId,
      type: entity.type,
      from: entity.from,
      to: entity.to,
      departureAt: entity.departureAt,
      arrivalAt: entity.arrivalAt,
      price: entity.price,
      totalSeats: entity.totalSeats,
      availableSeats: entity.availableSeats,
      status: entity.status,
    );
  }

  static List<TripEntity> toEntityList(List<TripApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
