import 'package:flutter/services.dart';

import '../failure.dart';
import '../types/location_failure.dart';
import '../types/notification_failure.dart';
import '../types/permission_failure.dart';
import '../types/platform_failure.dart';
import '../types/storage_failure.dart';
import 'failure_sub_mapper.dart';

final class PlatformFailureMapper implements FailureSubMapper {
  const PlatformFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is! PlatformException) return null;

    final code = error.code.toLowerCase();
    final message = error.message;
    final details = error.details?.toString().toLowerCase() ?? '';
    final raw = '$code $details ${message ?? ''}'.toLowerCase();

    if (_containsAny(raw, const [
      'permission',
      'denied',
      'denied_forever',
      'permanently_denied',
      'permanently',
    ])) {
      return _mapPermission(raw, message);
    }

    if (_containsAny(raw, const [
      'location',
      'gps',
      'geolocator',
      'geocode',
      'geocoding',
    ])) {
      return _mapLocation(raw, message);
    }

    if (_containsAny(raw, const ['notification', 'push', 'fcm', 'apns'])) {
      return _mapNotification(raw, message);
    }

    if (_containsAny(raw, const [
      'sharedpreferences',
      'securestorage',
      'storage',
      'keychain',
      'keystore',
    ])) {
      return _mapStorage(raw, message);
    }

    if (_containsAny(raw, const ['not implemented', 'unimplemented'])) {
      return Failure.platform(
        type: PlatformFailure.methodNotImplemented,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['unsupported', 'not supported'])) {
      return Failure.platform(
        type: PlatformFailure.notSupported,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['channel'])) {
      if (_containsAny(raw, const ['timeout'])) {
        return Failure.platform(
          type: PlatformFailure.channelTimeout,
          details: '${error.code}: ${error.message}',
        );
      }

      return Failure.platform(
        type: PlatformFailure.channelError,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['gps disabled'])) {
      return Failure.platform(
        type: PlatformFailure.gpsDisabled,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['bluetooth disabled'])) {
      return Failure.platform(
        type: PlatformFailure.bluetoothDisabled,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['nfc disabled'])) {
      return Failure.platform(
        type: PlatformFailure.nfcDisabled,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['wifi disabled'])) {
      return Failure.platform(
        type: PlatformFailure.wifiDisabled,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['offline', 'device offline'])) {
      return Failure.platform(
        type: PlatformFailure.deviceOffline,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['airplane mode'])) {
      return Failure.platform(
        type: PlatformFailure.airplaneModeEnabled,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['out of memory', 'memory'])) {
      return Failure.platform(
        type: PlatformFailure.outOfMemory,
        details: '${error.code}: ${error.message}',
      );
    }

    if (_containsAny(raw, const ['low power', 'battery saver'])) {
      return Failure.platform(
        type: PlatformFailure.lowPowerMode,
        details: '${error.code}: ${error.message}',
      );
    }

    return Failure.platform(
      type: PlatformFailure.pluginError,
      details: '${error.code}: ${error.message}',
    );
  }

  Failure _mapPermission(String raw, String? message) {
    final permission = _detectPermissionName(raw, message);

    if (_containsAny(raw, const [
      'denied_forever',
      'permanently_denied',
      'permanently',
    ])) {
      return Failure.permission(
        type: PermissionFailure.permanentlyDenied,
        permission: permission,
      );
    }

    if (_containsAny(raw, const ['camera'])) {
      return const Failure.permission(type: PermissionFailure.cameraDenied);
    }
    if (_containsAny(raw, const ['microphone', 'mic'])) {
      return const Failure.permission(type: PermissionFailure.microphoneDenied);
    }
    if (_containsAny(raw, const ['location', 'gps'])) {
      return const Failure.permission(type: PermissionFailure.locationDenied);
    }
    if (_containsAny(raw, const ['notification'])) {
      return const Failure.permission(
        type: PermissionFailure.notificationDenied,
      );
    }
    if (_containsAny(raw, const ['contacts'])) {
      return const Failure.permission(type: PermissionFailure.contactsDenied);
    }
    if (_containsAny(raw, const ['storage', 'photos', 'files'])) {
      return const Failure.permission(type: PermissionFailure.storageDenied);
    }
    if (_containsAny(raw, const ['calendar'])) {
      return const Failure.permission(type: PermissionFailure.calendarDenied);
    }
    if (_containsAny(raw, const ['bluetooth'])) {
      return const Failure.permission(type: PermissionFailure.bluetoothDenied);
    }
    if (_containsAny(raw, const ['speech'])) {
      return const Failure.permission(
        type: PermissionFailure.speechRecognitionDenied,
      );
    }
    if (_containsAny(raw, const ['biometric', 'face id', 'touch id'])) {
      return const Failure.permission(type: PermissionFailure.biometricDenied);
    }
    if (_containsAny(raw, const ['nfc'])) {
      return const Failure.permission(type: PermissionFailure.nfcDenied);
    }

    return Failure.permission(
      type: PermissionFailure.denied,
      permission: permission,
    );
  }

  Failure _mapLocation(String raw, String? message) {
    if (_containsAny(raw, const [
      'service disabled',
      'service_disabled',
      'gps disabled',
    ])) {
      return Failure.location(
        type: LocationFailure.gpsDisabled,
        message: message,
      );
    }

    if (_containsAny(raw, const ['timeout'])) {
      return Failure.location(type: LocationFailure.timeout, message: message);
    }

    if (_containsAny(raw, const ['geocoding'])) {
      return Failure.location(
        type: LocationFailure.geocodingFailed,
        message: message,
      );
    }

    if (_containsAny(raw, const ['reverse'])) {
      return Failure.location(
        type: LocationFailure.reverseGeocodingFailed,
        message: message,
      );
    }

    if (_containsAny(raw, const ['denied forever', 'permanently denied'])) {
      return Failure.location(
        type: LocationFailure.permissionPermanentlyDenied,
        message: message,
      );
    }

    return Failure.location(
      type: LocationFailure.locationUnavailable,
      message: message,
    );
  }

  Failure _mapNotification(String raw, String? message) {
    if (_containsAny(raw, const ['permission'])) {
      return Failure.notification(
        type: NotificationFailure.permissionDenied,
        message: message,
      );
    }

    if (_containsAny(raw, const ['token'])) {
      return Failure.notification(
        type: NotificationFailure.tokenRegistrationFailed,
        message: message,
      );
    }

    if (_containsAny(raw, const ['channel'])) {
      return Failure.notification(
        type: NotificationFailure.channelNotFound,
        message: message,
      );
    }

    return Failure.notification(
      type: NotificationFailure.serviceUnavailable,
      message: message,
    );
  }

  Failure _mapStorage(String raw, String? message) {
    if (_containsAny(raw, const ['read'])) {
      return Failure.storage(type: StorageFailure.readError, message: message);
    }

    if (_containsAny(raw, const ['write', 'save'])) {
      return Failure.storage(type: StorageFailure.writeError, message: message);
    }

    if (_containsAny(raw, const ['delete', 'remove'])) {
      return Failure.storage(
        type: StorageFailure.deleteError,
        message: message,
      );
    }

    if (_containsAny(raw, const ['encrypt'])) {
      return Failure.storage(
        type: StorageFailure.encryptionError,
        message: message,
      );
    }

    if (_containsAny(raw, const ['decrypt'])) {
      return Failure.storage(
        type: StorageFailure.decryptionError,
        message: message,
      );
    }

    if (_containsAny(raw, const ['not found'])) {
      return Failure.storage(type: StorageFailure.notFound, message: message);
    }

    return Failure.storage(type: StorageFailure.unavailable, message: message);
  }

  String? _detectPermissionName(String raw, String? fallback) {
    if (_containsAny(raw, const ['camera'])) return 'camera';
    if (_containsAny(raw, const ['microphone', 'mic'])) return 'microphone';
    if (_containsAny(raw, const ['location', 'gps'])) return 'location';
    if (_containsAny(raw, const ['notification'])) return 'notification';
    if (_containsAny(raw, const ['contacts'])) return 'contacts';
    if (_containsAny(raw, const ['calendar'])) return 'calendar';
    if (_containsAny(raw, const ['bluetooth'])) return 'bluetooth';
    if (_containsAny(raw, const ['storage', 'photos', 'files'])) {
      return 'storage';
    }
    if (_containsAny(raw, const ['speech'])) return 'speech';
    if (_containsAny(raw, const ['biometric', 'face id', 'touch id'])) {
      return 'biometric';
    }
    if (_containsAny(raw, const ['nfc'])) return 'nfc';

    return fallback;
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
