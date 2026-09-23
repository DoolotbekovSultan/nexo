import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexo_errors/nexo_errors.dart';

/// Специализированный маппер ошибок Firebase Auth.
///
/// Преобразует [FirebaseAuthException] в соответствующие [Failure]:
/// сетевые ошибки, ошибки аутентификации (неверные учётные данные,
/// истечение токена, блокировка аккаунта и т.д.).
///
/// Используется в цепочке [FailureSubMapper] как часть [FailureMapper].
///
/// См. также: [FailureSubMapper], [CommonFailureMapper].
final class FirebaseAuthFailureMapper implements FailureSubMapper {
  const FirebaseAuthFailureMapper();

  /// Пытается преобразовать [error] в [Failure], если это [FirebaseAuthException].
  ///
  /// Анализирует код ошибки Firebase Auth для определения типа:
  /// - `network-request-failed` → [NetworkFailure.noInternet]
  /// - `wrong-password`, `invalid-credential` → [AuthFailure.wrongCredentials]
  /// - `user-not-found` → [AuthFailure.accountNotFound]
  /// - `email-already-in-use` → [AuthFailure.accountAlreadyExists]
  /// - `user-disabled` → [AuthFailure.accountBlocked]
  /// - `too-many-requests` → [AuthFailure.accountTemporarilyLocked]
  ///
  /// **Возвращает:** [Failure] или `null`, если [error] не является [FirebaseAuthException].
  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is! FirebaseAuthException) return null;

    final code = error.code.toLowerCase();
    final message = error.message;

    if (_containsAny(code, const ['network-request-failed', 'network_error'])) {
      return const Failure.network(type: NetworkFailure.noInternet);
    }

    if (_containsAny(code, const ['too-many-requests'])) {
      return Failure.auth(
        type: AuthFailure.accountTemporarilyLocked,
        message: message,
      );
    }

    if (_containsAny(code, const [
      'invalid-credential',
      'wrong-password',
      'invalid-login-credentials',
    ])) {
      return Failure.auth(type: AuthFailure.wrongCredentials, message: message);
    }

    if (_containsAny(code, const ['user-not-found'])) {
      return Failure.auth(type: AuthFailure.accountNotFound, message: message);
    }

    if (_containsAny(code, const ['email-already-in-use'])) {
      return Failure.auth(
        type: AuthFailure.accountAlreadyExists,
        message: message,
      );
    }

    if (_containsAny(code, const ['user-disabled'])) {
      return Failure.auth(type: AuthFailure.accountBlocked, message: message);
    }

    if (_containsAny(code, const [
      'requires-recent-login',
      'user-token-expired',
    ])) {
      return Failure.auth(type: AuthFailure.tokenExpired, message: message);
    }

    if (_containsAny(code, const ['invalid-user-token'])) {
      return Failure.auth(type: AuthFailure.tokenInvalid, message: message);
    }

    if (_containsAny(code, const [
      'account-exists-with-different-credential',
    ])) {
      return Failure.auth(
        type: AuthFailure.accountAlreadyExists,
        message: message,
      );
    }

    if (_containsAny(code, const ['operation-not-allowed'])) {
      return Failure.auth(type: AuthFailure.forbidden, message: message);
    }

    if (_containsAny(code, const ['expired-action-code'])) {
      return Failure.auth(type: AuthFailure.tokenExpired, message: message);
    }

    if (_containsAny(code, const ['invalid-action-code'])) {
      return Failure.auth(type: AuthFailure.tokenInvalid, message: message);
    }

    if (_containsAny(code, const [
      'invalid-verification-code',
      'code-expired',
      'session-expired',
    ])) {
      return Failure.auth(type: AuthFailure.twoFactorFailed, message: message);
    }

    if (_containsAny(code, const ['invalid-verification-id'])) {
      return Failure.auth(type: AuthFailure.twoFactorFailed, message: message);
    }

    if (_containsAny(code, const [
      'second-factor-required',
      'multi-factor-auth-required',
    ])) {
      return Failure.auth(
        type: AuthFailure.twoFactorRequired,
        message: message,
      );
    }

    if (_containsAny(code, const [
      'credential-already-in-use',
      'provider-already-linked',
    ])) {
      return Failure.auth(
        type: AuthFailure.accountAlreadyExists,
        message: message,
      );
    }

    if (_containsAny(code, const [
      'popup-closed-by-user',
      'user-cancelled',
      'user-cancelled-sign-in',
    ])) {
      return Failure.auth(type: AuthFailure.oauthDenied, message: message);
    }

    if (_containsAny(code, const [
      'invalid-oauth-provider',
      'invalid-oauth-client-id',
      'missing-or-invalid-nonce',
    ])) {
      return Failure.auth(type: AuthFailure.oauthFailed, message: message);
    }

    return Failure.auth(
      type: AuthFailure.unauthorized,
      message: message ?? error.toString(),
    );
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
