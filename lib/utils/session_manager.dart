import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class SessionManager {
  SessionManager._();

  static SharedPreferences? _preferences;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // ============================================================
  // SAVE USER SESSION
  // ============================================================

  static Future<void> saveUserSession({
    required String userId,
    required String name,
    required String email,
  }) async {
    await init();

    await _preferences!.setString(
      AppConstants.userIdKey,
      userId,
    );

    await _preferences!.setString(
      AppConstants.userNameKey,
      name,
    );

    await _preferences!.setString(
      AppConstants.userEmailKey,
      email,
    );

    await _preferences!.setBool(
      AppConstants.loggedInKey,
      true,
    );
  }

  // ============================================================
  // GET USER ID
  // ============================================================

  static Future<String?> getUserId() async {
    await init();

    return _preferences!.getString(
      AppConstants.userIdKey,
    );
  }

  // ============================================================
  // GET USER NAME
  // ============================================================

  static Future<String?> getUserName() async {
    await init();

    return _preferences!.getString(
      AppConstants.userNameKey,
    );
  }

  // ============================================================
  // GET USER EMAIL
  // ============================================================

  static Future<String?> getUserEmail() async {
    await init();

    return _preferences!.getString(
      AppConstants.userEmailKey,
    );
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    await init();

    return _preferences!.getBool(
      AppConstants.loggedInKey,
    ) ??
        false;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await init();

    await _preferences!.remove(
      AppConstants.userIdKey,
    );

    await _preferences!.remove(
      AppConstants.userNameKey,
    );

    await _preferences!.remove(
      AppConstants.userEmailKey,
    );

    await _preferences!.setBool(
      AppConstants.loggedInKey,
      false,
    );
  }

  // ============================================================
  // CLEAR SESSION
  // ============================================================

  static Future<void> clearSession() async {
    await init();

    await _preferences!.clear();
  }
}