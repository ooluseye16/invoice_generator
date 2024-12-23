import 'package:hive/hive.dart';
import 'package:invoice_generator/data/models/goods.dart';

part 'invoice.g.dart';

@HiveType(typeId: 3)
class Invoice extends HiveObject {
  @HiveField(0)
  final String organizationId;

  @HiveField(1)
  final Map<String, dynamic> formData;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String invoiceNumber;

  Invoice({
    required this.organizationId,
    required this.formData,
    required this.createdAt,
    required this.invoiceNumber,
  });
} 