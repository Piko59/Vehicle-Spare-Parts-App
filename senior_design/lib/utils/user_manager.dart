class UserManager {
  static String? _currentUserId;

  static String? get currentUserId => _currentUserId;

  static void login(String userId) {
    _currentUserId = userId;
  }

  static void logout() {
    _currentUserId = null;
  }
}
