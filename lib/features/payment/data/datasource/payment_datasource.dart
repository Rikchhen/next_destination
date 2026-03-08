import 'package:next_destination/features/payment/data/model/payment_api_model.dart';
import 'package:next_destination/features/payment/data/model/payment_initiation_api_model.dart';

abstract interface class IPaymentRemoteDatasource {
  Future<PaymentInitiationApiModel> initiateKhaltiPayment({
    required String bookingId,
    required String returnUrl,
  });

  Future<PaymentApiModel> verifyKhaltiPayment({
    required String pidx,
    required String bookingId,
  });

  Future<PaymentApiModel?> getPaymentByBookingId(String bookingId);
}

