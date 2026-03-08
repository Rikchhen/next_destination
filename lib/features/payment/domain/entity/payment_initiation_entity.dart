import 'package:equatable/equatable.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';

class PaymentInitiationEntity extends Equatable {
  final PaymentEntity payment;
  final String? paymentUrl;
  final String? pidx;

  const PaymentInitiationEntity({
    required this.payment,
    this.paymentUrl,
    this.pidx,
  });

  @override
  List<Object?> get props => [payment, paymentUrl, pidx];
}

