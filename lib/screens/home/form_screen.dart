import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invoice_generator/components/widgets/button.dart';
import 'package:invoice_generator/components/widgets/text_field.dart';
import 'package:invoice_generator/data/models/form_field.dart';
import 'package:invoice_generator/data/models/goods.dart';
import 'package:invoice_generator/data/models/organization.dart';
import 'package:invoice_generator/utils/extensions.dart';
import 'package:invoice_generator/utils/number_to_word.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class OrganizationFormScreen extends ConsumerStatefulWidget {
  const OrganizationFormScreen({super.key, required this.organization});
  final Organization organization;

  @override
  ConsumerState<OrganizationFormScreen> createState() =>
      _OrganizationFormScreenState();
}

class _OrganizationFormScreenState
    extends ConsumerState<OrganizationFormScreen> {
  final Map<InvoiceFormField, List<Goods>> goodsLists = {};
  final Map<InvoiceFormField, dynamic> fieldValues = {};
  String amountInWords = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //run once
    if (goodsLists.isEmpty && fieldValues.isEmpty) {
      for (var field in widget.organization.fields) {
        if (field.type == FormFieldType.listOfGoods) {
          goodsLists[field] = [];
        } else {
          fieldValues[field] = '';
        }
      }
    }
  }

  bool isFormValid = false;

  void checkFormValidity() {
    isFormValid =
        widget.organization.fields.every((field) => fieldValues[field] != '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    "Kindly fill the following fields to generate your invoice."),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.organization.fields.map((field) {
                  switch (field.type) {
                    case FormFieldType.text:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(field.name),
                          const SizedBox(height: 8),
                          CustomTextField(
                            label: field.name,
                            onChanged: (value) {
                              setState(() {
                                fieldValues[field] = value;
                              });
                              checkFormValidity();
                            },
                            //   controller: TextEditingController(text: fieldValues[field]),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    case FormFieldType.number:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(field.name),
                          const SizedBox(height: 8),
                          NumberTextField(
                            hintText: field.name,
                            // controller: TextEditingController(text: fieldValues[field]),
                            onChanged: (value) {
                              setState(() {
                                fieldValues[field] = value;
                              });
                              checkFormValidity();
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    case FormFieldType.phone:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(field.name),
                          const SizedBox(height: 8),
                          PhoneNumberTextField(
                            //  controller:
                            //     TextEditingController(text: fieldValues[field]),
                            onChanged: (value) {
                              setState(() {
                                fieldValues[field] = "+234$value";
                              });
                              checkFormValidity();
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    case FormFieldType.listOfGoods:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(field.name),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => AddGoods(
                                      onAdd: (goods) {
                                        setState(() {
                                          goodsLists[field]?.add(goods);
                                        });
                                        checkFormValidity();
                                      },
                                    ),
                                  );
                                },
                                child: const Text("Add Item"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: goodsLists[field]?.length ?? 0,
                            itemBuilder: (context, index) {
                              return GoodsCard(
                                goods: goodsLists[field]![index],
                                onDelete: () {
                                  setState(() {
                                    goodsLists[field]!.removeAt(index);
                                  });
                                  checkFormValidity();
                                },
                              );
                            },
                          ),
                          if (goodsLists[field]?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total cost of Goods: ₦${NumberFormat('#,###').format(goodsLists[field]!.fold(0.0, (sum, goods) => sum + (goods.price * goods.quantity)))}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      );
                    case FormFieldType.date:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(field.name),
                          const SizedBox(height: 8),
                          DateTextField(
                            hintText: field.name,
                            onChanged: (value) {
                              setState(() {
                                fieldValues[field] = value;
                              });
                              checkFormValidity();
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    case FormFieldType.email:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(field.name),
                          const SizedBox(height: 8),
                          EmailTextField(
                            hintText: field.name,
                            onChanged: (value) {
                              setState(() {
                                fieldValues[field] = value;
                              });
                              checkFormValidity();
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    case FormFieldType.price:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(field.name),
                          const SizedBox(height: 8),
                          PriceTextField(
                            hintText: field.name,
                            // controller: TextEditingController(text: fieldValues[field]),
                            onChanged: (value) {
                              setState(() {
                                fieldValues[field] = value;
                                final amount = double.tryParse(value) ?? 0;
                                amountInWords = NumberToWord().convert(amount);
                              });
                              checkFormValidity();
                            },
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            label: 'Amount in words',
                            controller:
                                TextEditingController(text: amountInWords),
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    default:
                      return const SizedBox
                          .shrink(); // Handle other field types
                  }
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DefaultButton(
            isActive: isFormValid,
            onTap: () async {
              if (!isFormValid) return;
              // Create a map of all form data
              final formData = {
                'fields': fieldValues.map(
                  (field, value) => MapEntry(field.name, value),
                ),
                'goods': goodsLists.map(
                  (field, list) => MapEntry(
                    field.name,
                    list
                        .map(
                          (g) => g.toJson(),
                        )
                        .toList(),
                  ),
                ),
                'amountInWords': amountInWords,
                'total_price_goods': goodsLists.values.fold(
                  0.0,
                  (sum, list) =>
                      sum +
                      list.fold(
                        0.0,
                        (sum, goods) => sum + (goods.price * goods.quantity),
                      ),
                ),
              };

              // Create PDF document
              final pdf = await _generatePdf(formData);

              // Show preview dialog
              if (context.mounted) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PdfPreviewSheet(pdf: pdf),
                );
              }
            },
            text: "Generate Invoice",
          ),
        ],
      ),
    );
  }

// Move PDF generation to a separate method
  Future<pw.Document> _generatePdf(Map<String, dynamic> formData) async {
    final pdf = pw.Document();

    // Load a font that supports more characters (optional)
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    final fields = Map<String, dynamic>.from(formData['fields'])
        .entries
        .where((e) => !e.key.toLowerCase().contains('total amount paid'))
        .toList();

    final totalAmount = formData['fields']['Total Amount Paid'];

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (context) => pw.Column(
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
                      File(widget.organization.logoPath!).readAsBytesSync(),
                    ),
                    fit: pw.BoxFit.cover,
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${widget.organization.name} INVOICE'.toUpperCase(),
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      widget.organization.phoneNumber.formatPhoneNumber(),
                    ),
                  ],
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
                    text:
                        NumberFormat('#,###').format(double.parse(totalAmount)),
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
                    text: amountInWords,
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
                    pw.Text(entry.key.name,
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
                              border: pw.Border(top: pw.BorderSide(width: 1))),
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
                              border: pw.Border(top: pw.BorderSide(width: 1))),
                        )
                      ])
                ])
          ],
        ),
      ),
    );

    return pdf;
  }
}

class PdfPreviewSheet extends StatelessWidget {
  const PdfPreviewSheet({
    super.key,
    required this.pdf,
  });

  final pw.Document pdf;

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
                    build: (format) => pdf.save(),
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
                  await file.writeAsBytes(await pdf.save());

                  if (context.mounted) {
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

class GoodsCard extends StatelessWidget {
  const GoodsCard({
    super.key,
    required this.goods,
    required this.onDelete,
  });

  final Goods goods;
  final Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Description: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                            TextSpan(text: goods.description),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Quantity: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                            TextSpan(text: '${goods.quantity}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: 'Price per Unit: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                            TextSpan(text: '₦ ${goods.price}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    onDelete();
                    // setState(() {
                    //   goodsList.removeAt(index);
                    // });
                  },
                ),
              ],
            )),
      ),
    );
  }
}

class AddGoods extends StatefulWidget {
  const AddGoods({
    super.key,
    required this.onAdd,
  });
  final Function(Goods) onAdd;

  @override
  State<AddGoods> createState() => _AddGoodsState();
}

class _AddGoodsState extends State<AddGoods> {
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16.0,
        16.0,
        16.0,
        16.0 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Add Item",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Text("Description",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          CustomTextField(
            controller: descriptionController,
            label: 'Description',
          ),
          const SizedBox(height: 16),
          Text("Quantity",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          NumberTextField(
            controller: quantityController,
            hintText: 'Quantity',
          ),
          const SizedBox(height: 16),
          Text("Price per unit",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          NumberTextField(
            controller: priceController,
            hintText: 'Price',
          ),
          const SizedBox(height: 16),
          DefaultButton(
            onTap: () {
              widget.onAdd(Goods(
                description: descriptionController.text,
                quantity: int.parse(quantityController.text),
                price: double.parse(priceController.text),
              ));
              Navigator.pop(context);
            },
            text: "Add Item",
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// IconData _getFieldIcon(String fieldType) {
//   switch (fieldType) {
//     case 'Text':
//       return Icons.text_fields;
//     case 'Number':
//       return Icons.numbers;
//     case 'Email':
//       return Icons.email;
//     case 'Phone':
//       return Icons.phone;
//     case 'Date':
//       return Icons.calendar_today;
//     default:
//       return Icons.input;
//   }
//}
