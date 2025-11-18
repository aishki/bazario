/// Service for handling all form validation logic
/// Can be reused across registration, profile editing, and password change screens
class ValidationService {
  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$',
  );

  // Phone validation regex (10-15 digits, optional + prefix)
  static final RegExp _phoneRegex = RegExp(r"^\+?[0-9]{10,15}$");

  /// Validates email format
  /// Returns null if valid, error message if invalid
  static String? validateEmailFormat(String email) {
    if (email.isEmpty) {
      return "Email is required";
    }

    if (!_emailRegex.hasMatch(email)) {
      return "Enter a valid email address.";
    }

    return null;
  }

  /// Validates phone number format
  /// Returns null if valid, error message if invalid
  static String? validatePhoneFormat(String phone) {
    if (phone.isEmpty) {
      return "Phone number is required";
    }

    if (!_phoneRegex.hasMatch(phone)) {
      return "Enter a valid phone number.";
    }

    return null;
  }

  /// Validates username format
  /// Returns null if valid, error message if invalid
  static String? validateUsernameFormat(String username) {
    if (username.isEmpty) {
      return "Username is required";
    }

    if (username.length < 3) {
      return "Username must be at least 3 characters";
    }

    if (username.length > 20) {
      return "Username must be less than 20 characters";
    }

    // Optional: Add more username rules (alphanumeric, underscores, etc.)
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      return "Username can only contain letters, numbers, and underscores";
    }

    return null;
  }

  /// Validates password strength
  /// Returns null if valid, error message if invalid
  static String? validatePasswordStrength(String password) {
    if (password.isEmpty) {
      return "Password is required";
    }

    final errors = <String>[];

    if (password.length < 8) errors.add("at least 8 characters");
    if (!RegExp(r'[A-Z]').hasMatch(password)) errors.add("1 uppercase letter");
    if (!RegExp(r'[0-9]').hasMatch(password)) errors.add("1 number");
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add("1 symbol");
    }

    if (errors.isEmpty) {
      return null;
    }

    return "Password must have ${errors.join(", ")}.";
  }

  /// Validates password confirmation
  /// Returns null if passwords match, error message if they don't
  static String? validatePasswordMatch(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return "Please retype your password.";
    }

    if (password != confirmPassword) {
      return "Passwords do not match.";
    }

    return null;
  }

  /// Validates business name (for vendors)
  /// Returns null if valid, error message if invalid
  static String? validateBusinessName(String businessName) {
    if (businessName.isEmpty) {
      return "Business name is required";
    }

    if (businessName.length < 2) {
      return "Business name must be at least 2 characters";
    }

    return null;
  }

  /// Validates business description (for vendors)
  /// Returns null if valid, error message if invalid
  static String? validateBusinessDescription(
    String description, {
    int maxLength = 180,
  }) {
    if (description.length > maxLength) {
      return "Description must be less than $maxLength characters";
    }

    return null;
  }
}
