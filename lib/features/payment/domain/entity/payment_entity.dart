import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String? paymentId;
  final String userId;
  final String bookingId;
  final double amount;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final String? pidx;
  final String? paymentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentEntity({
    this.paymentId,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.pidx,
    this.paymentUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    paymentId,
    userId,
    bookingId,
    amount,
    status,
    paymentMethod,
    transactionId,
    pidx,
    paymentUrl,
    createdAt,
    updatedAt,
  ];
}

