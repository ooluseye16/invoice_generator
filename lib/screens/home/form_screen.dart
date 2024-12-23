import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invoice_generator/components/widgets/button.dart';
import 'package:invoice_generator/components/widgets/text_field.dart';
import 'package:invoice_generator/data/models/form_field.dart';
import 'package:invoice_generator/data/models/goods.dart';
import 'package:invoice_generator/data/models/organization.dart';
import 'package:invoice_generator/screens/home/widgets/preview_sheet.dart';
import 'package:invoice_generator/utils/number_to_word.dart';
import 'package:invoice_generator/utils/utilities.dart';

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
  final Map<InvoiceFormField, TextEditingController> fieldValues = {};
  final Map<InvoiceFormField, String?> amountInWords = {};

  @override
  void initState() {
    super.initState();
    _onArgumentChanged();
  }

  @override
  void didUpdateWidget(covariant OrganizationFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the argument has changed
    if (oldWidget.organization.id != widget.organization.id) {
      log('argument changed');
      _onArgumentChanged();
    }
  }

  void _onArgumentChanged() {
    fieldValues.clear();
    amountInWords.clear();
    goodsLists.clear();

    for (var field in widget.organization.fields) {
      if (field.type == FormFieldType.listOfGoods) {
        goodsLists[field] = [];
      } else if (field.type == FormFieldType.price) {
        amountInWords[field] = '';
        fieldValues[field] = TextEditingController();
        fieldValues[field]?.addListener(() {
          checkFormValidity();
        });
      } else {
        fieldValues[field] = TextEditingController();
        fieldValues[field]?.addListener(() {
          checkFormValidity();
        });
      }
    }

    setState(() {});
  }

  bool isFormValid = false;

  void checkFormValidity() {
    isFormValid =
        fieldValues.entries.every((element) => element.value.text.isNotEmpty);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // log("fieldValues: $fieldValues");
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
                            hintText: field.name,
                            controller: fieldValues[field],
                            //  // initialValue: fieldValues[field],
                            //   onChanged: (value) {
                            //     setState(() {
                            //       fieldValues[field] = value;
                            //     });
                            //  log("fieldValues: ${fieldValues[field]}");
                            //   checkFormValidity();
                            // },
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
                            controller: fieldValues[field],
                            //  initialValue: fieldValues[field],
                            //   onChanged: (value) {
                            //     setState(() {
                            //     fieldValues[field] = value;
                            //   });
                            //   checkFormValidity();
                            // },
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
                            controller: fieldValues[field],
                            //  initialValue: fieldValues[field],
                            //   onChanged: (value) {
                            //   setState(() {
                            //     fieldValues[field] = "+234$value";
                            //   });
                            //   checkFormValidity();
                            // },
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
                            controller: fieldValues[field],
                            //  initialValue: fieldValues[field],
                            //   onChanged: (value) {
                            //   setState(() {
                            //     fieldValues[field] = value;
                            //   });
                            //   checkFormValidity();
                            // },
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
                            controller: fieldValues[field],
                            // onChanged: (value) {
                            //   setState(() {
                            //     fieldValues[field] = value;
                            //   });
                            //   checkFormValidity();
                            // },
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
                            controller: fieldValues[field],
                            //  initialValue: fieldValues[field],
                            onChanged: (value) {
                              setState(() {
                                //fieldValues[field] = value;
                                final amount = double.tryParse(value) ?? 0;
                                amountInWords[field] =
                                    NumberToWord().convert(amount);
                              });
                              // checkFormValidity();
                            },
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hintText: 'Amount in words',
                            controller: TextEditingController(
                                text: amountInWords[field] ?? ''),
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
              // Create form data map
              final formData = {
                'fields': fieldValues.map((field, value) {
                  if (field.type == FormFieldType.price) {
                    return MapEntry(field.name, {
                      'amount': value.text.replaceAll(',', ''),
                      'amountInWords': amountInWords[field]
                    });
                  }
                  return MapEntry(field.name, value.text);
                }),
                'goods': goodsLists.map(
                  (field, list) => MapEntry(
                    field.name,
                    list.map((g) => g.toJson()).toList(),
                  ),
                ),
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

              // Generate PDF
              final pdf =
                  await Utilities.generatePdf(formData, widget.organization);

              // Show preview
              if (context.mounted) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PdfPreviewSheet(
                    pdf: pdf,
                    organizationId: widget.organization.id,
                    formData: formData,
                  ),
                );
              }
            },
            text: "Generate Invoice",
          ),
        ],
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
            hintText: 'Description',
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
