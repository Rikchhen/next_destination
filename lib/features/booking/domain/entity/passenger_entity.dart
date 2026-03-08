import 'package:equatable/equatable.dart';

class PassengerEntity extends Equatable {
  final String fullName;
  final int age;
  final String gender;
  final String seatNumber;

  const PassengerEntity({
    required this.fullName,
    required this.age,
    required this.gender,
    required this.seatNumber,
  });

  @override
  List<Object?> get props => [fullName, age, gender, seatNumber];
}
