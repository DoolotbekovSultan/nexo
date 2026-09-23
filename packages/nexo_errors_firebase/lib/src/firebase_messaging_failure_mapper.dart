import 'package:firebase_core/firebase_core.dart';
import 'package:nexo_errors/nexo_errors.dart';

/// Специализированный маппер ошибок Firebase Messaging.
///
/// Преобразует [FirebaseException] от Firebase Messaging в соответствующие
/// [Failure]: ошибки разрешений, регистрации токена, каналов уведомлений
/// и т.д. Распознаёт ошибки по плагину (`firebase_messaging`) и ключевым
/// словам в коде/сообщении.
///
/// Используется в цепочке [FailureSubMapper] как часть [FailureMapper].
///
/// См. также: [FailureSubMapper], [CommonFailureMapper].
final class FirebaseMessagingFailureMapper implements FailureSubMapper {
  const FirebaseMessagingFailureMapper();

  /// Пытается преобразовать [error] в [Failure], если это [FirebaseException]
  /// от Firebase Messaging.
  ///
  /// Анализирует плагин, код и сообщение ошибки для определения типа:
  /// - `permission`, `denied` → [NotificationFailure.permissionDenied]
  /// - `token`, `registration-token` → [NotificationFailure.tokenRegistrationFailed]
  /// - `channel` → [NotificationFailure.channelNotFound]
  /// - `payload`, `invalid-argument` → [NotificationFailure.invalidPayload]
  ///
  /// **Возвращает:** [Failure] или `null`, если ошибка не относится к Messaging.
  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is! FirebaseException) return null;

    final plugin = error.plugin.toLowerCase();
    final code = error.code.toLowerCase();
    final message = error.message?.toLowerCase() ?? '';

    final looksLikeMessaging =
        plugin.contains('messaging') ||
        code.contains('fcm') ||
        code.contains('apns') ||
        message.contains('notification') ||
        message.contains('messaging');

    if (!looksLikeMessaging) return null;

    if (_containsAny('$code $message', const [
      'permission',
      'denied',
      'authorization_denied',
    ])) {
      return const Failure.notification(
        type: NotificationFailure.permissionDenied,
      );
    }

    if (_containsAny('$code $message', const [
      'token',
      'registration-token',
      'apns-token',
    ])) {
      return Failure.notification(
        type: NotificationFailure.tokenRegistrationFailed,
        message: error.message,
      );
    }

    if (_containsAny('$code $message', const [
      'channel',
      'notification channel',
    ])) {
      return Failure.notification(
        type: NotificationFailure.channelNotFound,
        message: error.message,
      );
    }

    if (_containsAny('$code $message', const [
      'payload',
      'invalid-argument',
      'malformed',
    ])) {
      return Failure.notification(
        type: NotificationFailure.invalidPayload,
        message: error.message,
      );
    }

    if (_containsAny('$code $message', const [
      'unavailable',
      'service unavailable',
      'internal',
    ])) {
      return Failure.notification(
        type: NotificationFailure.serviceUnavailable,
        message: error.message,
      );
    }

    return Failure.notification(
      type: NotificationFailure.serviceUnavailable,
      message: error.message ?? error.toString(),
    );
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
