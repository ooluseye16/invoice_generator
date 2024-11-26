import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final currentOrganizationIdProvider = StateNotifierProvider<CurrentOrganizationNotifier, String?>((ref) {
  return CurrentOrganizationNotifier(ref);
});

class CurrentOrganizationNotifier extends StateNotifier<String?> {
  final Ref ref;
  static const _key = 'current_organization_id';

  CurrentOrganizationNotifier(this.ref) : super(null) {
    // Load initial value from SharedPreferences
    ref.read(sharedPreferencesProvider.future).then((prefs) {
      state = prefs.getString(_key);
    });
  }

  Future<void> setCurrentOrganization(String organizationId) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_key, organizationId);
    state = organizationId;
  }

  Future<void> clear() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_key);
    state = null;
  }
}
