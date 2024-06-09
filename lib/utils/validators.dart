String? _validatePassword(String? value) {
  print("Validating password: $value");
  if (value == null || value.isEmpty) {
    print("Password cannot be empty");
    return 'Password cannot be empty';
  }
  if (value.length < 8) {
    print("Password must be at least 8 characters long");
    return 'Password must be at least 8 characters long';
  }

  // Simplified regex checks
  bool hasLowercase = RegExp(r'[a-z]').hasMatch(value);
  bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
  bool hasDigit = RegExp(r'\d').hasMatch(value);
  bool hasSpecialCharacter = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

  print("Has lowercase: $hasLowercase");
  print("Has uppercase: $hasUppercase");
  print("Has digit: $hasDigit");
  print("Has special character: $hasSpecialCharacter");

  if (!hasLowercase) {
    print("Password must contain at least one lowercase letter");
    return 'Password must contain at least one lowercase letter';
  }
  if (!hasUppercase) {
    print("Password must contain at least one uppercase letter");
    return 'Password must contain at least one uppercase letter';
  }
  if (!hasDigit) {
    print("Password must contain at least one number");
    return 'Password must contain at least one number';
  }
  if (!hasSpecialCharacter) {
    print("Password must contain at least one special character");
    return 'Password must contain at least one special character';
  }

  print("Password is valid");
  return null;
}
