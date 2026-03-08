import 'package:next_destination/features/payment/data/model/payment_api_model.dart';
import 'package:next_destination/features/payment/domain/entity/payment_initiation_entity.dart';

class PaymentInitiationApiModel {
  final PaymentApiModel payment;
  final String? paymentUrl;
  final String? pidx;

  const PaymentInitiationApiModel({
    required this.payment,
    this.paymentUrl,
    this.pidx,
  });

  factory PaymentInitiationApiModel.fromJson(Map<String, dynamic> json) {
    final paymentMap = json['payment'] as Map<String, dynamic>? ?? {};

    return PaymentInitiationApiModel(
      payment: PaymentApiModel.fromJson(paymentMap),
      paymentUrl: json['paymentUrl']?.toString(),
      pidx: json['pidx']?.toString(),
    );
  }

  PaymentInitiationEntity toEntity() {
    return PaymentInitiationEntity(
      payment: payment.toEntity(),
      paymentUrl: paymentUrl,
      pidx: pidx,
    );
  }
}

