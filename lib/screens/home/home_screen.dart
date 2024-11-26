import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice_generator/components/widgets/button.dart';
import 'package:invoice_generator/data/models/form_field.dart';
import 'package:invoice_generator/screens/home/add_field_dialog.dart';
import 'package:invoice_generator/screens/home/form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? headerImagePath;
  List<InvoiceFormField> fields = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice Form Builder',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Text('Header Image',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            // Header Image Section
            GestureDetector(
              onTap: _pickHeaderImage,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: headerImagePath != null
                    ? Image.file(File(headerImagePath!), fit: BoxFit.cover)
                    : const Center(child: Text('Tap to add header image')),
              ),
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
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
              Text('Fields', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: ReorderableListView.builder(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fields[index].name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fields[index].type,
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
            ),

            // Create Form Button
            DefaultButton(
              onTap: fields.isNotEmpty ? _createForm : null,
              text: 'Create Form',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickHeaderImage() async {
    // TODO: Implement image picker
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

  void _createForm() {
    // Navigate to form creation page with fields data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormCreationScreen(
          headerImage: headerImagePath,
          fields: fields,
        ),
      ),
    );
  }
}
