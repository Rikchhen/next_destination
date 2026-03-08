import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';

class PaymentApiModel {
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

  const PaymentApiModel({
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

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(
      paymentId: (json['_id'] ?? json['id'])?.toString(),
      userId: (json['userId'] ?? '').toString(),
      bookingId: (json['bookingId'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: (json['status'] ?? '').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'khalti').toString(),
      transactionId: json['transactionId']?.toString(),
      pidx: json['pidx']?.toString(),
      paymentUrl: json['paymentUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      paymentId: paymentId,
      userId: userId,
      bookingId: bookingId,
      amount: amount,
      status: status,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      pidx: pidx,
      paymentUrl: paymentUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

