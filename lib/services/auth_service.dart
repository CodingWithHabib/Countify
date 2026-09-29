import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final bool isLoggedIn;
  final bool isGuest;
  final String name;
  final String email;
  final String bio;
  final String avatarIcon;

  UserSession({
    required this.isLoggedIn,
    required this.isGuest,
    required this.name,
    required this.email,
    required this.bio,
    required this.avatarIcon,
  });
}

class AuthService {
  static bool _isGuest = false;
  static bool _isLoggedIn = false;
  static String _userName = "User";
  static String _userEmail = "";
  static String _userBio = "Progress over perfection ✨";
  static String _userAvatar = "crown";

  static bool get isGuest => _isGuest;
  static bool get isLoggedIn => _isLoggedIn;
  static String get userName => _userName;
  static String get userEmail => _userEmail;
  static String get userBio => _userBio;
  static String get userAvatar => _userAvatar;

  // Input Validation Helpers
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static Future<UserSession> init() async {
    final prefs = await SharedPreferences.getInstance();

    final hasLoggedInBefore = prefs.getBool("auth_is_logged_in") ?? false;
    _isGuest = prefs.getBool("auth_is_guest") ?? !hasLoggedInBefore;

    if (hasLoggedInBefore) {
      _isLoggedIn = true;
      _isGuest = false;
      _userName = prefs.getString("user_profile_name") ?? "User";
      _userEmail = prefs.getString("user_profile_email") ?? "";
      _userBio = prefs.getString("user_profile_bio") ?? "Progress over perfection ✨";
      _userAvatar = prefs.getString("user_profile_avatar") ?? "crown";
    } else {
      _isLoggedIn = false;
      _isGuest = true;
      _userName = "Guest User";
      _userEmail = "guest@countify.app";
      _userBio = "Guest Session (Unsaved Data) ⏱";
      _userAvatar = "star";
    }

    return UserSession(
      isLoggedIn: _isLoggedIn,
      isGuest: _isGuest,
      name: _userName,
      email: _userEmail,
      bio: _userBio,
      avatarIcon: _userAvatar,
    );
  }

  static Future<void> signInAsGuest() async {
    _isGuest = true;
    _isLoggedIn = false;
    _userName = "Guest User";
    _userEmail = "guest@countify.app";
    _userBio = "Guest Session (Unsaved Data) ⏱";
    _userAvatar = "star";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("auth_is_guest", true);
    await prefs.setBool("auth_is_logged_in", false);
  }

  static Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    String? bio,
    String? avatarIcon,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim().toLowerCase();

    if (!isValidName(trimmedName)) {
      return "Wrong Name! Name must be at least 2 characters long.";
    }

    if (!isValidEmail(trimmedEmail)) {
      return "Wrong Email Address! Please enter a valid email (e.g. user@domain.com).";
    }

    if (!isValidPassword(password)) {
      return "Wrong Password! Password must be at least 6 characters long.";
    }

    final prefs = await SharedPreferences.getInstance();
    final registeredEmails = prefs.getStringList("registered_emails") ?? [];

    if (registeredEmails.contains(trimmedEmail)) {
      return "Email Already Registered! An account with this email already exists. Please click 'SIGN IN'.";
    }

    _userName = trimmedName;
    _userEmail = trimmedEmail;
    _userBio = (bio == null || bio.trim().isEmpty) ? "Progress over perfection ✨" : bio.trim();
    _userAvatar = avatarIcon ?? "crown";

    _isLoggedIn = true;
    _isGuest = false;

    registeredEmails.add(trimmedEmail);
    await prefs.setStringList("registered_emails", registeredEmails);

    await prefs.setString("user_password_$trimmedEmail", password);
    await prefs.setString("user_name_$trimmedEmail", _userName);
    await prefs.setString("user_bio_$trimmedEmail", _userBio);
    await prefs.setString("user_avatar_$trimmedEmail", _userAvatar);

    await prefs.setBool("auth_is_logged_in", true);
    await prefs.setBool("auth_is_guest", false);
    await prefs.setString("user_profile_name", _userName);
    await prefs.setString("user_profile_email", _userEmail);
    await prefs.setString("user_profile_bio", _userBio);
    await prefs.setString("user_profile_avatar", _userAvatar);

    return null; // Success!
  }

  static Future<String?> loginWithPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    final registeredEmails = prefs.getStringList("registered_emails") ?? [];
    final isEmailFormatValid = isValidEmail(trimmedEmail);
    final isEmailRegistered = registeredEmails.contains(trimmedEmail);
    final storedPass = prefs.getString("user_password_$trimmedEmail");

    final isPasswordCorrect = (storedPass != null && storedPass == password);

    // Case 1: Both Email AND Password are wrong/unregistered
    if ((!isEmailFormatValid || !isEmailRegistered) && !isPasswordCorrect) {
      if (!isEmailFormatValid) {
        return "Wrong Email & Password! Email format is invalid and password is incorrect.";
      }
      return "Wrong Email & Password! Account is not registered and password is incorrect.";
    }

    // Case 2: Only Email is wrong/unregistered
    if (!isEmailFormatValid) {
      return "Wrong Email Address! Please enter a valid email address (e.g. user@domain.com).";
    }

    if (!isEmailRegistered) {
      return "Wrong Email Address! No account found with this email. Please click 'REGISTER' tab first.";
    }

    // Case 3: Only Password is wrong (Email is correct & registered, but Password fails)
    if (!isPasswordCorrect) {
      return "Wrong Password! Password does not match for $trimmedEmail.";
    }

    // Success! Email is registered AND Password matches
    _userName = prefs.getString("user_name_$trimmedEmail") ??
        prefs.getString("user_profile_name") ??
        trimmedEmail.split("@").first;
    _userEmail = trimmedEmail;
    _userBio = prefs.getString("user_bio_$trimmedEmail") ??
        prefs.getString("user_profile_bio") ??
        "Progress over perfection ✨";
    _userAvatar = prefs.getString("user_avatar_$trimmedEmail") ??
        prefs.getString("user_profile_avatar") ??
        "crown";

    _isLoggedIn = true;
    _isGuest = false;

    await prefs.setBool("auth_is_logged_in", true);
    await prefs.setBool("auth_is_guest", false);
    await prefs.setString("user_profile_name", _userName);
    await prefs.setString("user_profile_email", _userEmail);
    await prefs.setString("user_profile_bio", _userBio);
    await prefs.setString("user_profile_avatar", _userAvatar);

    return null; // Success!
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("auth_is_logged_in", false);
    await prefs.setBool("auth_is_guest", true);

    _isLoggedIn = false;
    _isGuest = true;
    _userName = "Guest User";
    _userEmail = "guest@countify.app";
    _userBio = "Guest Session (Unsaved Data) ⏱";
    _userAvatar = "star";
  }
}
