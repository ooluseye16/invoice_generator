import 'package:hive/hive.dart';

part 'form_field.g.dart';

@HiveType(typeId: 1)
class InvoiceFormField {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final FormFieldType type;

  @HiveField(2)
  final bool isRequired;

  InvoiceFormField({
    required this.name,
    required this.type,
    this.isRequired = false,
  });
}

@HiveType(typeId: 2)
enum FormFieldType {
  @HiveField(0)
  text,
  @HiveField(1)
  number,
  @HiveField(2)
  phone,
  @HiveField(3)
  date,
  @HiveField(4)
  email,
  @HiveField(5)
  listOfGoods,
  @HiveField(6)
  price
}
