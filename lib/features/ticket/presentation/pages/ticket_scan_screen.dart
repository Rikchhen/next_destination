import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/core/widgets/custom_text_field.dart';
import 'package:next_destination/features/ticket/presentation/pages/ticket_detail_screen.dart';
import 'package:next_destination/features/ticket/presentation/state/ticket_state.dart';
import 'package:next_destination/features/ticket/presentation/viewmodel/ticket_view_model.dart';

class TicketScanScreen extends ConsumerStatefulWidget {
  const TicketScanScreen({super.key});

  @override
  ConsumerState<TicketScanScreen> createState() => _TicketScanScreenState();
}

class _TicketScanScreenState extends ConsumerState<TicketScanScreen> {
  final TextEditingController _qrTokenController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _scanWithToken(String token) async {
    final qrToken = token.trim();
    if (qrToken.length < 5) {
      SnackbarUtils.showError(context, 'qrToken is required');
      return;
    }

    _qrTokenController.text = qrToken;
    await ref.read(ticketViewModelProvider.notifier).scanTicket(qrToken);
  }

  Future<void> _scan() async {
    await _scanWithToken(_qrTokenController.text);
  }

  Future<void> _scanFromCamera() async {
    final token = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _CameraQrScannerPage()),
    );

    if (!mounted || token == null || token.trim().isEmpty) return;
    await _scanWithToken(token);
  }

  Future<void> _scanFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );

    try {
      final capture = await controller.analyzeImage(image.path);
      final barcodes = capture?.barcodes ?? const <Barcode>[];
      final token = barcodes
          .map((e) => e.rawValue?.trim())
          .whereType<String>()
          .firstWhere(
            (e) => e.isNotEmpty,
            orElse: () => '',
          );

      if (!mounted) return;

      if (token.isEmpty) {
        SnackbarUtils.showError(context, 'No QR code found in selected image');
        return;
      }

      await _scanWithToken(token);
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed to read QR from gallery image');
    } finally {
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    _qrTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketViewModelProvider);
    final isLoading = state.status == TicketStatus.loading;

    ref.listen<TicketState>(ticketViewModelProvider, (previous, next) {
      if (next.status == TicketStatus.scanned && next.selectedTicket != null) {
        SnackbarUtils.showSuccess(
          context,
          'Ticket validated (check-in successful)',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailScreen(initialTicket: next.selectedTicket),
          ),
        );
      } else if (next.status == TicketStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter QR Token',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hint: 'QR-xxxxxxxx',
              controller: _qrTokenController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _scan,
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Validate Ticket',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _scanFromCamera,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan from Camera'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _scanFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Scan from Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraQrScannerPage extends StatefulWidget {
  const _CameraQrScannerPage();

  @override
  State<_CameraQrScannerPage> createState() => _CameraQrScannerPageState();
}

class _CameraQrScannerPageState extends State<_CameraQrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_handled) return;

              final token = capture.barcodes
                  .map((e) => e.rawValue?.trim())
                  .whereType<String>()
                  .firstWhere(
                    (e) => e.isNotEmpty,
                    orElse: () => '',
                  );

              if (token.isEmpty) return;

              _handled = true;
              Navigator.pop(context, token);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: Colors.black.withOpacity(0.45),
              child: const Text(
                'Align the QR code inside the camera view',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
