class Validators {
  Validators._();

  // ============================================================
  // REQUIRED FIELD
  // ============================================================

  static String? requiredField(
      String? value, {
        String fieldName = 'This field',
      }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // ============================================================
  // NAME
  // ============================================================

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }

  // ============================================================
  // EMAIL
  // ============================================================

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ============================================================
  // PASSWORD
  // ============================================================

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ============================================================
  // CONFIRM PASSWORD
  // ============================================================

  static String? confirmPassword(
      String? value,
      String password,
      ) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ============================================================
  // PHONE NUMBER
  // ============================================================

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  // ============================================================
  // BIRTHDATE
  // ============================================================

  static String? birthdate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Birthdate is required';
    }

    final birthDate = DateTime.tryParse(value.trim());

    if (birthDate == null) {
      return 'Enter a valid birthdate';
    }

    final today = DateTime.now();

    // Future date is not allowed.
    final todayOnly = DateTime(
      today.year,
      today.month,
      today.day,
    );

    final birthDateOnly = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
    );

    if (birthDateOnly.isAfter(todayOnly)) {
      return 'Birthdate cannot be in the future';
    }

    // Calculate exact age.
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    // Minimum age = 12 years.
    if (age < 12) {
      return 'You must be at least 12 years old';
    }

    return null;
  }

  // ============================================================
  // REVIEW
  // ============================================================

  static String? review(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Review cannot be empty';
    }

    if (value.trim().length < 3) {
      return 'Review is too short';
    }

    return null;
  }

  // ============================================================
  // OTP
  // ============================================================

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit OTP';
    }

    return null;
  }
}