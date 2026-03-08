import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/features/payment/domain/usecases/get_payment_by_booking_usecase.dart';
import 'package:next_destination/features/payment/domain/usecases/initiate_khalti_payment_usecase.dart';
import 'package:next_destination/features/payment/domain/usecases/verify_khalti_payment_usecase.dart';
import 'package:next_destination/features/payment/presentation/state/payment_state.dart';

final paymentViewModelProvider = NotifierProvider<PaymentViewModel, PaymentState>(
  () => PaymentViewModel(),
);

class PaymentViewModel extends Notifier<PaymentState> {
  late final InitiateKhaltiPaymentUsecase _initiateUsecase;
  late final VerifyKhaltiPaymentUsecase _verifyUsecase;
  late final GetPaymentByBookingUsecase _getByBookingUsecase;

  @override
  PaymentState build() {
    _initiateUsecase = ref.read(initiateKhaltiPaymentUsecaseProvider);
    _verifyUsecase = ref.read(verifyKhaltiPaymentUsecaseProvider);
    _getByBookingUsecase = ref.read(getPaymentByBookingUsecaseProvider);
    return const PaymentState();
  }

  Future<void> initiatePayment({
    required String bookingId,
    required String returnUrl,
  }) async {
    state = state.copyWith(status: PaymentStatus.loading);

    final result = await _initiateUsecase.call(
      InitiateKhaltiPaymentParams(bookingId: bookingId, returnUrl: returnUrl),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        );
      },
      (data) {
        state = state.copyWith(
          status: PaymentStatus.initiated,
          payment: data.payment,
          paymentUrl: data.paymentUrl,
          pidx: data.pidx,
        );
      },
    );
  }

  Future<void> verifyPayment({
    required String pidx,
    required String bookingId,
  }) async {
    state = state.copyWith(status: PaymentStatus.loading);

    final result = await _verifyUsecase.call(
      VerifyKhaltiPaymentParams(pidx: pidx, bookingId: bookingId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        );
      },
      (payment) {
        state = state.copyWith(
          status: PaymentStatus.verified,
          payment: payment,
          paymentUrl: payment.paymentUrl,
          pidx: payment.pidx,
        );
      },
    );
  }

  Future<void> getPaymentByBookingId(String bookingId) async {
    state = state.copyWith(status: PaymentStatus.loading);

    final result = await _getByBookingUsecase.call(bookingId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        );
      },
      (payment) {
        state = state.copyWith(
          status: PaymentStatus.fetched,
          payment: payment,
          paymentUrl: payment?.paymentUrl,
          pidx: payment?.pidx,
        );
      },
    );
  }
}

