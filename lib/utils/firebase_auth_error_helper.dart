import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrorHelper {
 
  static String getErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'Пользователь с таким email не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-email':
        return 'Некорректный формат email';
      case 'too-many-requests':
        return 'Слишком много попыток входа. Попробуйте позже';
      case 'invalid-credential':
        return 'Неверные учетные данные';
      
      case 'email-already-in-use':
        return 'Пользователь с таким email уже существует';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету';
      case 'internal-error':
        return 'Внутренняя ошибка сервера. Попробуйте позже';

      default:
        return 'Произошла ошибка аутентификации: ${exception.message ?? 'Неизвестная ошибка'}';
    }
  }
}
