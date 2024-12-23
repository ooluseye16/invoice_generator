import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice_generator/components/widgets/button.dart';
import 'package:invoice_generator/components/widgets/text_field.dart';
import 'package:invoice_generator/data/models/form_field.dart';
import 'package:invoice_generator/data/models/organization.dart';
import 'package:invoice_generator/providers/organization_provider.dart';
import 'package:invoice_generator/screens/home/add_field_dialog.dart';
import 'package:uuid/uuid.dart';

class CreateOrganizationScreen extends ConsumerStatefulWidget {
  static const routeName = '/create-organization';
  const CreateOrganizationScreen({super.key});

  @override
  ConsumerState<CreateOrganizationScreen> createState() =>
      _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState
    extends ConsumerState<CreateOrganizationScreen> {
  String? headerImagePath;
  List<InvoiceFormField> fields = [];
  final TextEditingController _organizationNameController =
      TextEditingController();
  final TextEditingController _organizationPhoneNumberController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _organizationNameController.addListener(checkFormValidity);
    _organizationPhoneNumberController.addListener(checkFormValidity);
    // Initialize with required fields
    fields = [
      InvoiceFormField(
          name: 'Customer Name', type: FormFieldType.text, isRequired: true),
      InvoiceFormField(
          name: 'Date Issued', type: FormFieldType.date, isRequired: true),
      InvoiceFormField(
          name: 'Total Amount Paid', type: FormFieldType.price, isRequired: true),
    ];
  }

  bool isButtonActive = false;

  checkFormValidity() {
    bool isActive = _organizationNameController.text.isNotEmpty &&
        _organizationPhoneNumberController.text.isNotEmpty &&
        fields.isNotEmpty;
    setState(() {
      isButtonActive = isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Create Organization',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              // Info Text with icon
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Add fields to create your invoice form. You can add up to 10 fields.'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Organization Logo',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      // Header Image Section
                      GestureDetector(
                        onTap: _pickHeaderImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: headerImagePath != null
                              ? Image.file(File(headerImagePath!),
                                  fit: BoxFit.cover)
                              : const Center(
                                  child: Text('Tap to add logo'),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Organization Name',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _organizationNameController,
                        hintText: 'Enter organization name',
                      ),
                      const SizedBox(height: 16),
                      Text('Organization Phone Number',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      PhoneNumberTextField(
                        controller: _organizationPhoneNumberController,
                      ),

                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _addField,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Add Field',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.add,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Fields List
                      if (fields.isNotEmpty) ...[
                        Text('Fields',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                      ],
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: fields.length,
                        proxyDecorator: (child, index, animation) => Container(
                          key: ValueKey(fields[index]),
                          child: child,
                        ),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = fields.removeAt(oldIndex);
                            fields.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) => Padding(
                          key: ValueKey(fields[index]),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey(fields[index]),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            direction: fields[index].isRequired
                                ? DismissDirection.none
                                : DismissDirection.endToStart,
                            onDismissed: (direction) => _removeField(index),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: fields[index].isRequired
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: fields[index].isRequired
                                    ? Colors.grey.shade50
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                fields[index].name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              if (fields[index].isRequired) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  '(Required)',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fields[index]
                                                .type
                                                .name
                                                .toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.drag_handle,
                                        color: Colors.grey.shade600),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Create Form Button
                    ],
                  ),
                ),
              ),
              DefaultButton(
                isActive: isButtonActive,
                onTap: _createOrganization,
                text: 'Create Organization',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickHeaderImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        headerImagePath = image.path;
      });
    }
  }

  void _addField() {
    // Show modal bottom sheet to add field
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddFieldDialog(
        onAdd: (name, type) {
          setState(() {
            fields.add(InvoiceFormField(name: name, type: type));
          });
        },
      ),
    );
  }

  void _removeField(int index) {
    setState(() {
      fields.removeAt(index);
    });
  }
  void _createOrganization() async {
    // Show confirmation dialog
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you done adding all necessary fields? You won\'t be able to modify them later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, go back'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, continue'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    final organization = Organization(
      id: const Uuid().v4(),
      name: _organizationNameController.text,
      phoneNumber: _organizationPhoneNumberController.text,
      fields: fields,
      logoPath: headerImagePath,
    );

    // Use the provider to add the organization
    await ref
        .read(organizationsProvider.notifier)
        .addOrganization(organization);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
