class FormValidator {
  static String? validateLoginForm(String email, String password) {
    if (email.trim().isEmpty) return 'Введите email';
    if (password.trim().isEmpty) return 'Введите пароль';
    return null;
  }

  static String? validateName(String name) {
    if (name.trim().isEmpty) return 'Введите имя';
    return null;
  }

  static String? validateEmail(String email) {
    if (email.trim().isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) return 'Некорректный формат email';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.trim().isEmpty) return 'Введите пароль';
    if (password.length < 8) return 'Минимум 8 символов';
    if (password.length > 16) return 'Максимум 16 символов';
    return null;
  }

  static String? validateConfirmPassword(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.trim().isEmpty) return 'Подтвердите пароль';
    if (password != confirmPassword) return 'Пароли не совпадают';
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
      return 'Пароль слишком длинный (максимум 16 символов)';
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
    return validateName(name) == null &&
        validateEmail(email) == null &&
        validatePassword(password) == null &&
        validateConfirmPassword(password, confirmPassword) == null;
  }
}
