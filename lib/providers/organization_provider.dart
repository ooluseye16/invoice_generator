import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_generator/data/models/organization.dart';
import 'package:invoice_generator/providers/preferences_provider.dart';

final organizationsProvider = StateNotifierProvider<OrganizationsNotifier, AsyncValue<List<Organization>>>((ref) {
  return OrganizationsNotifier();
});

class OrganizationsNotifier extends StateNotifier<AsyncValue<List<Organization>>> {
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
}

// Provider to handle the selected organization ID
final selectedOrganizationIdProvider = StateProvider<String?>((ref) => null);

// Provider that combines organizations data with selected ID to get current organization
final currentOrganizationProvider = Provider<AsyncValue<Organization>>((ref) {
  final organizationsAsync = ref.watch(organizationsProvider);
  final selectedId = ref.watch(selectedOrganizationIdProvider);

  return organizationsAsync.when(
    data: (organizations) {
      if (organizations.isEmpty) {
        return const AsyncValue.error('No organizations available', StackTrace.empty);
      }

      if (selectedId == null) {
        return AsyncValue.data(organizations.first);
      }

      try {
        final org = organizations.firstWhere(
          (org) => org.hashCode.toString() == selectedId,
          orElse: () => organizations.first,
        );
        return AsyncValue.data(org);
      } catch (e) {
        return AsyncValue.data(organizations.first);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider to initialize the selected organization from preferences
final initializeSelectedOrganizationProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final organizationId = prefs.getString('organizationId');
  if (organizationId != null) {
    ref.read(selectedOrganizationIdProvider.notifier).state = organizationId;
  }
});
