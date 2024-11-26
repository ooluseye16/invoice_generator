import 'package:hive/hive.dart';
import 'package:invoice_generator/data/models/form_field.dart';

part 'organization.g.dart';

@HiveType(typeId: 0)
class Organization extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final List<InvoiceFormField> fields;

  @HiveField(4)
  final String? logoPath;

  Organization({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.fields,
    this.logoPath,
  });
}
