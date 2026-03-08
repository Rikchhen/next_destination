import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';

class PassengerApiModel {
  final String fullName;
  final int age;
  final String gender;
  final String seatNumber;

  PassengerApiModel({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.seatNumber,
  });

  factory PassengerApiModel.fromJson(Map<String, dynamic> json) {
    return PassengerApiModel(
      fullName: (json['fullName'] ?? '').toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: (json['gender'] ?? 'male').toString(),
      seatNumber: (json['seatNumber'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'seatNumber': seatNumber,
    };
  }

  PassengerEntity toEntity() {
    return PassengerEntity(
      fullName: fullName,
      age: age,
      gender: gender,
      seatNumber: seatNumber,
    );
  }

  factory PassengerApiModel.fromEntity(PassengerEntity entity) {
    return PassengerApiModel(
      fullName: entity.fullName,
      age: entity.age,
      gender: entity.gender,
      seatNumber: entity.seatNumber,
    );
  }

  static List<PassengerEntity> toEntityList(List<PassengerApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}
