class FormValidator {
  static String? validateLoginForm(String email, String password) {
    if (email.trim().isEmpty) return 'Введите email';
    if (password.trim().isEmpty) return 'Введите пароль';
    return null;
  }

  static String? validateRegistrationForm(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    if (name.trim().isEmpty) return 'Введите имя';
    if (email.trim().isEmpty) return 'Введите email';
    if (password.trim().isEmpty) return 'Введите пароль';
    if (password.length < 8)
      return 'Пароль слишком короткий (минимум 8 символов)';
    if (password.length > 16)
      return 'Пароль слишком длинный (максиму 16 символов)';
    if (confirmPassword.trim().isEmpty) return 'Подтвердите пароль';
    if (password != confirmPassword) return 'Пароли не совпадают';
    return null;
  }

  static bool isLoginFormValid(String email, String password) {
    return email.trim().isNotEmpty && password.trim().isNotEmpty;
  }

  static bool isRegistrationFormValid(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    return name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        password.length >= 8 &&
        password.length <= 16 &&
        confirmPassword.isNotEmpty &&
        password.compareTo(confirmPassword) == 0;
  }
}
