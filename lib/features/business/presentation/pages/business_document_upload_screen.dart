import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/colors.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/business/presentation/state/business_state.dart';
import 'package:next_destination/features/business/presentation/viewmodel/business_view_model.dart';

class BusinessDocumentUploadScreen extends ConsumerStatefulWidget {
  const BusinessDocumentUploadScreen({super.key});

  @override
  ConsumerState<BusinessDocumentUploadScreen> createState() =>
      _BusinessDocumentUploadScreenState();
}

class _BusinessDocumentUploadScreenState
    extends ConsumerState<BusinessDocumentUploadScreen> {
  String? _documentPath;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentPath = result.files.single.path;
      });
    }
  }

  Future<void> _uploadDocument() async {
    if (_documentPath == null) {
      SnackbarUtils.showError(context, "Please select a document");
      return;
    }

    await ref
        .read(businessViewModelProvider.notifier)
        .uploadBusinessDocument(documentPath: _documentPath!);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessViewModelProvider);
    final isLoading = state.status == BusinessStatus.loading;

    ref.listen<BusinessState>(businessViewModelProvider, (previous, next) {
      if (next.status == BusinessStatus.documentUploaded) {
        SnackbarUtils.showSuccess(context, "Document uploaded successfully");
      } else if (next.status == BusinessStatus.error &&
          next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Upload Verification Document")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _documentPath == null
                    ? "No document selected"
                    : _documentPath!.split(RegExp(r'[\\/]')).last,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: isLoading ? null : _pickDocument,
                child: const Text("Choose Document"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _uploadDocument,
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Upload Document",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
