import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_generator/data/models/organization.dart';

final organizationsProvider = StateNotifierProvider<OrganizationsNotifier,
    AsyncValue<List<Organization>>>((ref) {
  return OrganizationsNotifier();
});

class OrganizationsNotifier
    extends StateNotifier<AsyncValue<List<Organization>>> {
  OrganizationsNotifier() : super(const AsyncValue.loading()) {
    loadOrganizations();
  }

  Future<void> loadOrganizations() async {
    try {
      final box = await Hive.openBox<Organization>('organizations');
      final organizations = box.values.toList();
      state = AsyncValue.data(organizations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addOrganization(Organization organization) async {
    try {
      final box = await Hive.openBox<Organization>('organizations');
      await box.add(organization);
      await loadOrganizations(); // Reload the list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteOrganization(Organization organization) async {
    try {
      final box = await Hive.openBox<Organization>('organizations');
      // Find the key for this organization
      final key = box.values.toList().indexOf(organization);
      if (key != -1) {
        await box.deleteAt(key);
        await loadOrganizations(); // Reload the list
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
