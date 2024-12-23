import 'dart:io';

import 'package:intl/intl.dart';
import 'package:invoice_generator/data/models/goods.dart';
import 'package:invoice_generator/data/models/organization.dart';
import 'package:invoice_generator/utils/extensions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Utilities {
  // Move PDF generation to a separate method
  static Future<pw.Document> generatePdf(
    Map<String, dynamic> formData,
    Organization organization,
  ) async {
    final pdf = pw.Document();

    // Load a font that supports more characters (optional)
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    final fields = Map<String, dynamic>.from(formData['fields'])
        .entries
        .where((e) => !e.key.toLowerCase().contains('total amount paid'))
        .toList();

    final totalAmount = formData['fields']['Total Amount Paid']['amount'];
    final totalAmountInWords =
        formData['fields']['Total Amount Paid']['amountInWords'];

    final goodsLists = formData['goods'].map((key, value) => MapEntry(
          key,
          (value as List).map((item) => Goods.fromJson(item)).toList(),
        ));

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Organization Logo
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    height: 60,
                    width: 60,
                    decoration: const pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: PdfColors.purple,
                    ),
                    child: pw.Image(
                      pw.MemoryImage(
                        File(organization.logoPath!).readAsBytesSync(),
                      ),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${organization.name} INVOICE'.toUpperCase(),
                            style: pw.TextStyle(
                                fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                          organization.phoneNumber.formatPhoneNumber(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              // Organization Details
              pw.Wrap(
                alignment: pw.WrapAlignment.spaceBetween,
                spacing: 30,
                runSpacing: 20,
                children: List.generate(
                  (fields.length / 2).ceil(),
                  (index) {
                    final start = index * 2;
                    final entries = fields.toList();
                    return pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${entries[start].key}:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            pw.Text(
                                entries[start].value.toString().toUpperCase()),
                            pw.SizedBox(height: 10),
                          ],
                        ),
                        if (start + 1 < entries.length)
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                '${entries[start + 1].key}:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              pw.Text(entries[start + 1]
                                  .value
                                  .toString()
                                  .toUpperCase()),
                              pw.SizedBox(height: 10),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),

              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    const pw.TextSpan(
                      text: 'Total Amount Paid: ',
                    ),
                    pw.TextSpan(
                      text: NumberFormat('#,###')
                          .format(double.parse(totalAmount)),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    const pw.TextSpan(
                      text: 'Amount in Words: ',
                    ),
                    pw.TextSpan(
                      text: totalAmountInWords ?? '',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Goods List
              ...goodsLists.entries.map((entry) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(entry.key,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          // Header
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('Description')),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('Quantity')),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('Price')),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('Total')),
                            ],
                          ),
                          // Data rows
                          ...entry.value.map((goods) => pw.TableRow(
                                children: [
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text(goods.description)),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('${goods.quantity}')),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text('₦${goods.price}')),
                                  pw.Padding(
                                      padding: const pw.EdgeInsets.all(5),
                                      child: pw.Text(
                                          '₦${goods.price * goods.quantity}')),
                                ],
                              )),
                        ],
                      ),
                      pw.SizedBox(height: 20),
                      pw.Text(
                          'Total: ₦${entry.value.fold(0, (sum, goods) => sum + goods.price * goods.quantity)}'),
                    ],
                  )),

              //add signature
              pw.SizedBox(height: 60),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Customer Signature'),
                          pw.SizedBox(height: 40),
                          pw.Container(
                            width: 200,
                            decoration: const pw.BoxDecoration(
                                border:
                                    pw.Border(top: pw.BorderSide(width: 1))),
                          )
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Company Signature'),
                          pw.SizedBox(height: 40),
                          pw.Container(
                            width: 200,
                            decoration: const pw.BoxDecoration(
                                border:
                                    pw.Border(top: pw.BorderSide(width: 1))),
                          )
                        ])
                  ])
            ],
          ),
        ),
      ),
    );

    return pdf;
  }
}
