import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/payment/presentation/state/payment_state.dart';
import 'package:next_destination/features/payment/presentation/viewmodel/payment_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String bookingId;
  final String pidx;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.bookingId,
    required this.pidx,
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (request) {
            _checkAndHandleReturnUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _checkAndHandleReturnUrl(String url) async {
    if (_isVerifying) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final pidx = uri.queryParameters['pidx'];
    final purchaseOrderId = uri.queryParameters['purchase_order_id'];
    final status = (uri.queryParameters['status'] ?? '').toLowerCase();

    final looksLikeReturn =
        pidx != null &&
        pidx.isNotEmpty &&
        (purchaseOrderId == widget.bookingId ||
            (purchaseOrderId != null && purchaseOrderId.isNotEmpty));

    if (!looksLikeReturn) return;

    if (status.contains('failed') || status.contains('cancel')) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Payment failed or cancelled');
      Navigator.pop(context, false);
      return;
    }

    _isVerifying = true;
    await ref.read(paymentViewModelProvider.notifier).verifyPayment(
          pidx: pidx,
          bookingId: widget.bookingId,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentViewModelProvider, (previous, next) {
      if (next.status == PaymentStatus.verified) {
        SnackbarUtils.showSuccess(context, 'Payment verified successfully');
        Navigator.pop(context, true);
      } else if (next.status == PaymentStatus.error && next.errorMessage != null) {
        _isVerifying = false;
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment'),
                content: const Text('Are you sure you want to close payment?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, false);
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.65),
              child: const Center(
                child: CircularProgressIndicator(color: primaryRed),
              ),
            ),
        ],
      ),
    );
  }
}

