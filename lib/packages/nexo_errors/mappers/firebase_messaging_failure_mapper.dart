import 'package:firebase_core/firebase_core.dart';

import '../failure.dart';
import '../types/notification_failure.dart';
import 'failure_sub_mapper.dart';

final class FirebaseMessagingFailureMapper implements FailureSubMapper {
  const FirebaseMessagingFailureMapper();

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
