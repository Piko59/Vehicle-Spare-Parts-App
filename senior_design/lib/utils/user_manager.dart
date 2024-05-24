class UserManager {
  static String? _currentUserId;
  static String? _currentUserProfileType;
  static String? _currentUserProfileImage;

  static String? get currentUserId => _currentUserId;
  static String? get currentUserProfileType => _currentUserProfileType;
  static String? get currentUserProfileImage => _currentUserProfileImage;

  static Future<void> login(String userId) async {
    _currentUserId = userId;
  }

  static void logout() {
    _currentUserId = null;
    _currentUserProfileType = null;
    _currentUserProfileImage = null;
  }

  static void setUserProfile(String profileType, String profileImage) {
    _currentUserProfileType = profileType;
    _currentUserProfileImage = profileImage;
  }
}
