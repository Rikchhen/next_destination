import 'package:equatable/equatable.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';

enum PaymentStatus {
  initial,
  loading,
  initiated,
  verified,
  fetched,
  error,
}

class PaymentState extends Equatable {
  final PaymentStatus status;
  final PaymentEntity? payment;
  final String? paymentUrl;
  final String? pidx;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.payment,
    this.paymentUrl,
    this.pidx,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentEntity? payment,
    String? paymentUrl,
    String? pidx,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      payment: payment ?? this.payment,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      pidx: pidx ?? this.pidx,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, payment, paymentUrl, pidx, errorMessage];
}

