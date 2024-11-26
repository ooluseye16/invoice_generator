import 'package:invoice_generator/data/models/form_field.dart';

class Organization {
  final String name;
  final String phoneNumber;
  final List<InvoiceFormField> fields;

  Organization({
    required this.name,
    required this.phoneNumber,
    required this.fields,
  });
}
