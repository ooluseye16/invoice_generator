import 'package:flutter/material.dart';
import 'dart:io';

import 'package:invoice_generator/data/models/form_field.dart';

class FormCreationScreen extends StatefulWidget {
  final String? headerImage;
  final List<InvoiceFormField> fields;

  const FormCreationScreen({
    super.key,
    this.headerImage,
    required this.fields,
  });

  @override
  State<FormCreationScreen> createState() => _FormCreationScreenState();
}

class _FormCreationScreenState extends State<FormCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Image
            if (widget.headerImage != null)
              Image.file(
                File(widget.headerImage!),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 32),
            // Form Fields
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildFormField(field),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(InvoiceFormField field) {
    switch (field.type) {
      case 'Number':
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.name,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${field.name}';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          onSaved: (value) => _formData[field.name] = int.parse(value!),
        );

      case 'Email':
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.name,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${field.name}';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          onSaved: (value) => _formData[field.name] = value,
        );

      case 'Phone':
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.name,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${field.name}';
            }
            if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
          onSaved: (value) => _formData[field.name] = value,
        );

      case 'Date':
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.name,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(field.name),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select ${field.name}';
            }
            return null;
          },
          controller: TextEditingController(
            text: _formData[field.name]?.toString() ?? '',
          ),
        );

      default: // Text field
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.name,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${field.name}';
            }
            return null;
          },
          onSaved: (value) => _formData[field.name] = value,
        );
    }
  }

  Future<void> _selectDate(String fieldName) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _formData[fieldName] = picked.toString().split(' ')[0];
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Here you can handle the form data
      print(_formData);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
      
      // Navigate back or to a success screen
      Navigator.pop(context);
    }
  }
}