class UserManager {
  static String? _currentUserId;

  static String? get currentUserId => _currentUserId;

  static Future<void> login(String userId) async {
    _currentUserId = userId;
  }

  static void logout() {
    _currentUserId = null;
  }
}
