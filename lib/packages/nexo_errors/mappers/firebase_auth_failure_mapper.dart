import 'package:firebase_auth/firebase_auth.dart';

import '../failure.dart';
import '../types/auth_failure.dart';
import '../types/network_failure.dart';
import 'failure_sub_mapper.dart';

final class FirebaseAuthFailureMapper implements FailureSubMapper {
  const FirebaseAuthFailureMapper();

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
