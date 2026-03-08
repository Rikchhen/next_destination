import 'dart:io';
import 'dart:ui' as ui;

import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/presentation/state/ticket_state.dart';
import 'package:next_destination/features/ticket/presentation/viewmodel/ticket_view_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String? ticketId;
  final TicketEntity? initialTicket;

  const TicketDetailScreen({super.key, this.ticketId, this.initialTicket});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.ticketId != null && widget.initialTicket == null) {
      Future.microtask(
        () => ref.read(ticketViewModelProvider.notifier).getTicketById(widget.ticketId!),
      );
    }
  }

  String _fmt(DateTime? value) {
    if (value == null) return 'N/A';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  Future<void> _showQrDialog(String qrToken) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ticket QR'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: QrImageView(data: qrToken, version: QrVersions.auto),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadQr(String qrToken) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Gallery save is supported on mobile only');
      return;
    }

    try {
      final painter = QrPainter(data: qrToken, version: QrVersions.auto);
      final imageData = await painter.toImageData(
        1024,
        format: ui.ImageByteFormat.png,
      );

      if (imageData == null) {
        if (!mounted) return;
        SnackbarUtils.showError(context, 'Could not generate QR image');
        return;
      }

      final fileName = 'ticket_qr_${DateTime.now().millisecondsSinceEpoch}';
      final bytes = imageData.buffer.asUint8List();
      await Gal.putImageBytes(
        bytes,
        name: fileName,
        album: 'Next Destination',
      );

      if (!mounted) return;
      SnackbarUtils.showSuccess(context, 'QR saved to gallery');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'QR download failed: $e');
    }
  }

  Future<void> _voidTicket(String ticketId) async {
    final reasonController = TextEditingController();

    final shouldVoid = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Void Ticket'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Void reason (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Void'),
            ),
          ],
        );
      },
    );

    if (shouldVoid == true && mounted) {
      await ref
          .read(ticketViewModelProvider.notifier)
          .voidTicket(ticketId: ticketId, reason: reasonController.text.trim());
    }

    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketViewModelProvider);
    final isLoading = state.status == TicketStatus.loading;

    ref.listen<TicketState>(ticketViewModelProvider, (previous, next) {
      if (next.status == TicketStatus.voided) {
        SnackbarUtils.showSuccess(context, 'Ticket voided successfully');
      } else if (next.status == TicketStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    final ticket = state.selectedTicket ?? widget.initialTicket;

    if (isLoading && ticket == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (ticket == null) {
      return const Scaffold(body: Center(child: Text('Ticket not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.passengerName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Seat: ${ticket.seatNumber}'),
                    Text('Status: ${ticket.status.toUpperCase()}'),
                    Text('QR Token: ${ticket.qrToken}'),
                    const SizedBox(height: 12),
                    Center(
                      child: QrImageView(
                        data: ticket.qrToken,
                        version: QrVersions.auto,
                        size: 170,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Issued At: ${_fmt(ticket.issuedAt)}'),
                    Text('Used At: ${_fmt(ticket.usedAt)}'),
                    Text('Expires At: ${_fmt(ticket.expiresAt)}'),
                    if (ticket.voidReason != null && ticket.voidReason!.isNotEmpty)
                      Text('Void Reason: ${ticket.voidReason}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showQrDialog(ticket.qrToken);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                    icon: const Icon(Icons.qr_code, color: Colors.white),
                    label: const Text('Open QR', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadQr(ticket.qrToken),
                    icon: const Icon(Icons.download),
                    label: const Text('Download QR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (ticket.status != 'used' && ticket.status != 'void' && ticket.ticketId != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => _voidTicket(ticket.ticketId!),
                  child: const Text('Void Ticket'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
