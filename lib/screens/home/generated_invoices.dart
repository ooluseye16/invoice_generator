import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:invoice_generator/data/models/invoice.dart';
import 'package:invoice_generator/providers/organization_provider.dart';
import 'package:invoice_generator/screens/home/widgets/preview_sheet.dart';
import 'package:invoice_generator/utils/utilities.dart';

class GeneratedInvoicesScreen extends ConsumerWidget {
  static const routeName = '/generated-invoices';

  const GeneratedInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(organizationsProvider).asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Invoices'),
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         final box = await Hive.openBox<Invoice>('invoices');

        //         box.clear();
        //       },
        //       icon: const Icon(Icons.clear))
        // ],
      ),
      body: FutureBuilder<Box<Invoice>>(
        future: Hive.openBox<Invoice>('invoices'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final box = snapshot.data!;
          final invoices = box.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (invoices.isEmpty) {
            return const Center(
              child: Text('No invoices generated yet'),
            );
          }

          return ListView.builder(
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              final organization = organizations
                  ?.where(
                    (element) => element.id == invoice.organizationId,
                  )
                  .firstOrNull;

              final customerName = invoice.formData['fields']['Customer Name'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Dismissible(
                  key: ValueKey(invoice.invoiceNumber),
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
                  onDismissed: (direction) => box.delete(invoice.key),
                  child: ListTile(
                    title: organization != null
                        ? Text("${organization.name} - $customerName")
                        : Text("INVOICE ${invoice.invoiceNumber}"),
                    subtitle: Text(
                        'Created on ${DateFormat.yMMMd().format(invoice.createdAt)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () async {
                        final pdf = await Utilities.generatePdf(
                            invoice.formData, organization!);

                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => PdfPreviewSheet(
                              pdf: pdf,
                              organizationId: organization.id,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
