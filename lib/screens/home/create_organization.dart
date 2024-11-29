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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                        label: 'Enter organization name',
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
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) => _removeField(index),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
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
                                          Text(
                                            fields[index].name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
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
                onTap: fields.isNotEmpty ? _createOrganization : null,
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
