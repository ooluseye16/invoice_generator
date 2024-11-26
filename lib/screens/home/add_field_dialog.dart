import 'package:flutter/material.dart';
import 'package:invoice_generator/components/widgets/button.dart';
import 'package:invoice_generator/components/widgets/text_field.dart';

class AddFieldDialog extends StatefulWidget {
  final Function(String name, String type) onAdd;

  const AddFieldDialog({super.key, required this.onAdd});

  @override
  State<AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<AddFieldDialog> {
  final _nameController = TextEditingController();
  String _selectedType = 'Text';

  final _fieldTypes = ['Text', 'Number', 'Date', 'Email', 'Phone'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Add Invoice Field',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Field Name',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _nameController,
              label: 'Field Name',
            ),
            const SizedBox(height: 16),
            Text(
              'Field Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Field Type',
                border: InputBorder.none,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              value: _selectedType,
              items: _fieldTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            DefaultButton(
              onTap: () {
                widget.onAdd(_nameController.text, _selectedType);
                Navigator.pop(context);
              },
              text: 'Add Field',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
