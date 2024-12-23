import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_generator/components/widgets/button.dart';
import 'package:invoice_generator/data/models/invoice.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfPreviewSheet extends StatefulWidget {
  const PdfPreviewSheet({
    super.key,
    required this.pdf,
    this.formData,
    required this.organizationId,
  });

  final pw.Document pdf;
  final String organizationId;
  final Map<String, dynamic>? formData;
  @override
  State<PdfPreviewSheet> createState() => _PdfPreviewSheetState();
}

class _PdfPreviewSheetState extends State<PdfPreviewSheet> {
  Future<void> _saveInvoice(Map<String, dynamic> formData) async {
    final box = await Hive.openBox<Invoice>('invoices');

    // Generate a unique invoice number (you can customize this format)
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';

    final invoice = Invoice(
      organizationId: widget.organizationId,
      formData: formData,
      createdAt: DateTime.now(),
      invoiceNumber: invoiceNumber,
    );

    await box.add(invoice);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: PdfPreview(
                    build: (format) => widget.pdf.save(),
                    initialPageFormat: PdfPageFormat.a4,
                    pdfFileName: "invoice.pdf",
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    allowPrinting: false,
                    allowSharing: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DefaultButton(
                onTap: () async {
                  // Save PDF
                  final output = await getTemporaryDirectory();
                  final file = File('${output.path}/invoice.pdf');
                  await file.writeAsBytes(await widget.pdf.save());

                  if (context.mounted) {
                    // Save invoice
                    if (widget.formData != null) {
                      await _saveInvoice(widget.formData!);
                    }
                    Navigator.pop(context); // Close preview
                    Share.shareXFiles(
                      [
                        XFile(file.path, name: 'invoice.pdf'),
                      ],
                    );
                  }
                },
                text: 'Share',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
