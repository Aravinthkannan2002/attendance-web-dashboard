import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_snackbar.dart';

class WebAuthService extends GetxService {
  final SupabaseClient _client = Supabase.instance.client;

  final RxString currentCompanyId = ''.obs;
  final RxString adminName = ''.obs;
  final RxString companyName = ''.obs;

  SupabaseClient get client => _client;

  bool get isLoggedIn => _client.auth.currentSession != null;

  Future<WebAuthService> init() async {
    // Try to restore company id from existing session
    if (isLoggedIn) {
      await _loadProfile();
    }
    return this;
  }

  /// Signs in with email/password and checks that the profile role == 'admin'.
  /// Returns true on success, throws a descriptive string on failure.
  Future<bool> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        AppSnackbar.error('No user returned. Please try again.', title: 'Login Failed');
        return false;
      }

      final error = await _loadProfile();
      if (error != null) {
        await _client.auth.signOut();
        AppSnackbar.error(error, title: 'Login Failed');
        return false;
      }

      return true;
    } on AuthException catch (e) {
      AppSnackbar.error(e.message, title: 'Login Failed');
      return false;
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Login Failed');
      return false;
    }
  }

  /// Returns null on success, or an error string describing the failure.
  Future<String?> _loadProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 'No authenticated user found.';

    debugPrint('WebAuth: loading profile for $userId');

    final data = await _client
        .from('profiles')
        .select('company_id, name, role')
        .eq('id', userId)
        .maybeSingle();

    debugPrint('WebAuth: profile data = $data');

    if (data == null) {
      return 'Profile not found. Your account may not be fully set up. '
          'Please register first using the mobile app.';
    }

    final role = data['role'] as String? ?? '';
    debugPrint('WebAuth: role = $role');

    if (role != 'admin') {
      return 'Access denied — only admin accounts can access the dashboard. '
          'Your role is "$role".';
    }

    final companyId = data['company_id'] as String? ?? '';
    debugPrint('WebAuth: company_id = $companyId');

    if (companyId.isEmpty) {
      return 'No company linked to this admin account. '
          'Please set up your company first using the mobile app.';
    }

    currentCompanyId.value = companyId;
    adminName.value = data['name'] as String? ?? 'Admin';

    // Fetch company name
    final company = await _client
        .from('companies')
        .select('name')
        .eq('id', companyId)
        .maybeSingle();
    companyName.value = company?['name'] as String? ?? '';
    debugPrint('WebAuth: company = ${companyName.value}');

    return null; // success
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    currentCompanyId.value = '';
    adminName.value = '';
    companyName.value = '';
  }

  String getCompanyId() => currentCompanyId.value;
}
