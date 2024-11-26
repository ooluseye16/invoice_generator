import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_generator/components/widgets/button.dart';
import 'package:invoice_generator/components/widgets/text_field.dart';
import 'package:invoice_generator/data/models/form_field.dart';
import 'package:invoice_generator/data/models/organization.dart';

class OrganizationFormScreen extends ConsumerWidget {
  const OrganizationFormScreen({super.key, required this.organization});
  final Organization organization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisSize: MainAxisSize.min,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: organization.fields.map((field) {
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
                        const PhoneNumberTextField(),
                        const SizedBox(height: 16),
                      ],
                    );
                  default:
                    return const SizedBox.shrink(); // Handle other field types
                }
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          DefaultButton(
            onTap: () {},
            text: "Generate Invoice",
          ),
        ],
      ),
    );
  }
}

IconData _getFieldIcon(String fieldType) {
  switch (fieldType) {
    case 'Text':
      return Icons.text_fields;
    case 'Number':
      return Icons.numbers;
    case 'Email':
      return Icons.email;
    case 'Phone':
      return Icons.phone;
    case 'Date':
      return Icons.calendar_today;
    default:
      return Icons.input;
  }
}
