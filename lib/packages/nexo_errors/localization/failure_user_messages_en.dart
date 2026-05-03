import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/localization/failure_user_message_catalog.dart';
import 'package:nexo/packages/nexo_errors/types/auth_failure.dart';
import 'package:nexo/packages/nexo_errors/types/cache_failure.dart';
import 'package:nexo/packages/nexo_errors/types/database_failure.dart';
import 'package:nexo/packages/nexo_errors/types/file_failure.dart';
import 'package:nexo/packages/nexo_errors/types/http_failure.dart';
import 'package:nexo/packages/nexo_errors/types/location_failure.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';
import 'package:nexo/packages/nexo_errors/types/notification_failure.dart';
import 'package:nexo/packages/nexo_errors/types/parse_failure.dart';
import 'package:nexo/packages/nexo_errors/types/payment_failure.dart';
import 'package:nexo/packages/nexo_errors/types/permission_failure.dart';
import 'package:nexo/packages/nexo_errors/types/platform_failure.dart';
import 'package:nexo/packages/nexo_errors/types/storage_failure.dart';
import 'package:nexo/packages/nexo_errors/types/sync_failure.dart';
import 'package:nexo/packages/nexo_errors/types/validation_failure.dart';

/// English UI strings for [Failure].
final class EnFailureUserMessages implements FailureUserMessageCatalog {
  const EnFailureUserMessages();

  @override
  String forFailure(Failure failure) => switch (failure) {
    NetworkAppFailure(:final type) => switch (type) {
      NetworkFailure.noInternet => 'No internet connection',
      NetworkFailure.timeout => 'Request timed out',
      NetworkFailure.badCertificate => 'Secure connection error',
      NetworkFailure.cancelled => 'Request was cancelled',
      NetworkFailure.dnsLookupFailed => 'Could not resolve server address',
      NetworkFailure.connectionRefused => 'Server refused the connection',
      NetworkFailure.hostUnreachable => 'Server is unreachable',
      NetworkFailure.connectionReset => 'Connection was reset',
      NetworkFailure.proxyError => 'Proxy server error',
      NetworkFailure.vpnError => 'VPN connection error',
      NetworkFailure.tooManyRedirects => 'Too many redirects',
      NetworkFailure.invalidUrl => 'Invalid request URL',
    },
    HttpAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            HttpFailure.badRequest => 'Bad request',
            HttpFailure.unauthorized => 'Sign in required',
            HttpFailure.paymentRequired => 'Payment required',
            HttpFailure.forbidden => 'Access denied',
            HttpFailure.notFound => 'Resource not found',
            HttpFailure.methodNotAllowed => 'Method not allowed',
            HttpFailure.notAcceptable => 'Response format not acceptable',
            HttpFailure.proxyAuthRequired => 'Proxy authentication required',
            HttpFailure.requestTimeout => 'Request timed out',
            HttpFailure.conflict => 'Data conflict',
            HttpFailure.gone => 'Resource is no longer available',
            HttpFailure.lengthRequired => 'Content length required',
            HttpFailure.preconditionFailed => 'Precondition failed',
            HttpFailure.payloadTooLarge => 'Request payload too large',
            HttpFailure.uriTooLong => 'Request URL too long',
            HttpFailure.unsupportedMediaType => 'Unsupported media type',
            HttpFailure.rangeNotSatisfiable =>
              'Requested range not satisfiable',
            HttpFailure.expectationFailed => 'Expectation failed',
            HttpFailure.teapot => 'I\'m a teapot',
            HttpFailure.misdirectedRequest => 'Misdirected request',
            HttpFailure.unprocessableEntity => 'Validation error',
            HttpFailure.locked => 'Resource is locked',
            HttpFailure.failedDependency => 'Failed dependency',
            HttpFailure.tooEarly => 'Too early',
            HttpFailure.upgradeRequired => 'Protocol upgrade required',
            HttpFailure.preconditionRequired => 'Precondition required',
            HttpFailure.tooManyRequests => 'Too many requests. Try again later',
            HttpFailure.requestHeaderFieldsTooLarge =>
              'Request headers too large',
            HttpFailure.unavailableForLegalReasons =>
              'Unavailable for legal reasons',
            HttpFailure.internalServerError =>
              'Server error. Please try again later',
            HttpFailure.notImplemented => 'Not implemented on the server',
            HttpFailure.badGateway => 'Bad gateway',
            HttpFailure.serviceUnavailable => 'Service unavailable',
            HttpFailure.gatewayTimeout => 'Gateway timeout',
            HttpFailure.httpVersionNotSupported => 'HTTP version not supported',
            HttpFailure.variantAlsoNegotiates => 'Variant also negotiates',
            HttpFailure.insufficientStorage => 'Insufficient storage on server',
            HttpFailure.loopDetected => 'Loop detected',
            HttpFailure.notExtended => 'Not extended',
            HttpFailure.networkAuthenticationRequired =>
              'Network authentication required',
            HttpFailure.unknown => 'Server error',
          },
    AuthAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            AuthFailure.unauthorized => 'Sign in required',
            AuthFailure.forbidden => 'Insufficient permissions',
            AuthFailure.tokenExpired => 'Session expired. Sign in again',
            AuthFailure.tokenInvalid => 'Auth error. Sign in again',
            AuthFailure.refreshTokenExpired => 'Session expired. Sign in again',
            AuthFailure.refreshTokenInvalid => 'Auth error. Sign in again',
            AuthFailure.sessionRevoked => 'Session ended. Sign in again',
            AuthFailure.sessionNotFound => 'Session not found. Sign in again',
            AuthFailure.wrongCredentials => 'Invalid username or password',
            AuthFailure.accountBlocked => 'Account is blocked',
            AuthFailure.accountTemporarilyLocked =>
              'Account temporarily locked. Try again later',
            AuthFailure.accountNotVerified => 'Account is not verified',
            AuthFailure.accountDeleted => 'Account was deleted',
            AuthFailure.accountNotFound => 'Account not found',
            AuthFailure.accountAlreadyExists => 'Account already exists',
            AuthFailure.passwordExpired => 'Password expired. Change password',
            AuthFailure.twoFactorRequired =>
              'Two-factor authentication required',
            AuthFailure.twoFactorFailed => 'Invalid verification code',
            AuthFailure.twoFactorExpired => 'Verification code expired',
            AuthFailure.biometricFailed => 'Biometric authentication failed',
            AuthFailure.biometricNotAvailable =>
              'Biometrics not set up on this device',
            AuthFailure.biometricLocked => 'Biometrics locked',
            AuthFailure.oauthFailed => 'External sign-in failed',
            AuthFailure.oauthDenied => 'External sign-in was denied',
            AuthFailure.oauthTokenInvalid =>
              'External service token is invalid',
            AuthFailure.oauthAccountNotLinked =>
              'Account not linked to external service',
          },
    ValidationAppFailure(:final type, :final field, :final message) =>
      message ??
          switch (type) {
            ValidationFailure.requiredField =>
              'Field${field != null ? ' "$field"' : ''} is required',
            ValidationFailure.invalidFormat =>
              'Invalid format${field != null ? ' for field "$field"' : ''}',
            ValidationFailure.invalidEmail => 'Invalid email format',
            ValidationFailure.invalidPhone => 'Invalid phone format',
            ValidationFailure.invalidUrl => 'Invalid URL format',
            ValidationFailure.invalidDate => 'Invalid date format',
            ValidationFailure.invalidTime => 'Invalid time format',
            ValidationFailure.invalidNumber => 'Invalid number format',
            ValidationFailure.invalidCardNumber => 'Invalid card number',
            ValidationFailure.tooLong =>
              '${field != null ? '"$field"' : 'Field'} is too long',
            ValidationFailure.tooShort =>
              '${field != null ? '"$field"' : 'Field'} is too short',
            ValidationFailure.tooLarge => 'Value is too large',
            ValidationFailure.tooSmall => 'Value is too small',
            ValidationFailure.outOfRange => 'Value is out of range',
            ValidationFailure.notUnique =>
              '${field != null ? '"$field"' : 'Value'} already exists',
            ValidationFailure.passwordTooWeak => 'Password is too weak',
            ValidationFailure.passwordMismatch => 'Passwords do not match',
            ValidationFailure.fileTooLarge => 'File is too large',
            ValidationFailure.invalidFileType => 'Invalid file type',
            ValidationFailure.invalidImageSize => 'Invalid image size',
            ValidationFailure.invalidCharacters =>
              'Field contains invalid characters',
            ValidationFailure.serverValidation => 'Validation error',
          },
    StorageAppFailure(:final type) => switch (type) {
      StorageFailure.readError => 'Failed to read data',
      StorageFailure.writeError => 'Failed to save data',
      StorageFailure.deleteError => 'Failed to delete data',
      StorageFailure.clearError => 'Failed to clear data',
      StorageFailure.notFound => 'Data not found',
      StorageFailure.permissionDenied => 'No access to storage',
      StorageFailure.outOfSpace => 'Not enough space on device',
      StorageFailure.corrupted => 'Data is corrupted',
      StorageFailure.encryptionError => 'Encryption error',
      StorageFailure.decryptionError => 'Decryption error',
      StorageFailure.unavailable => 'Storage unavailable',
      StorageFailure.versionMismatch => 'Incompatible data version',
    },
    DatabaseAppFailure(:final type) => switch (type) {
      DatabaseFailure.readError => 'Database read error',
      DatabaseFailure.writeError => 'Database write error',
      DatabaseFailure.deleteError => 'Database delete error',
      DatabaseFailure.updateError => 'Database update error',
      DatabaseFailure.notFound => 'Record not found',
      DatabaseFailure.uniqueConstraintViolation => 'Record already exists',
      DatabaseFailure.foreignKeyViolation => 'Data relationship violation',
      DatabaseFailure.notNullViolation => 'Required field is missing',
      DatabaseFailure.migrationFailed => 'Database migration failed',
      DatabaseFailure.transactionFailed => 'Transaction failed',
      DatabaseFailure.corrupted => 'Database is corrupted',
      DatabaseFailure.locked => 'Database is locked',
      DatabaseFailure.connectionLost => 'Database connection lost',
      DatabaseFailure.outOfSpace => 'Not enough space for database',
      DatabaseFailure.queryTimeout => 'Database query timed out',
    },
    CacheAppFailure(:final type) => switch (type) {
      CacheFailure.miss => 'Cache miss',
      CacheFailure.expired => 'Cache expired',
      CacheFailure.readError => 'Cache read error',
      CacheFailure.writeError => 'Cache write error',
      CacheFailure.deleteError => 'Cache delete error',
      CacheFailure.clearError => 'Cache clear error',
      CacheFailure.outOfSpace => 'Not enough space for cache',
      CacheFailure.corrupted => 'Cache data is corrupted',
      CacheFailure.invalidated => 'Cache invalidated',
    },
    ParseAppFailure(:final type) => switch (type) {
      ParseFailure.jsonDecode => 'Failed to parse data',
      ParseFailure.jsonEncode => 'Failed to encode data',
      ParseFailure.xmlDecode => 'Failed to parse XML',
      ParseFailure.csvDecode => 'Failed to parse CSV',
      ParseFailure.unexpectedType => 'Unexpected data format',
      ParseFailure.missingField => 'Missing field in server response',
      ParseFailure.invalidEnumValue => 'Invalid value in server response',
      ParseFailure.emptyResponse => 'Empty server response',
      ParseFailure.nullValue => 'Null value received',
      ParseFailure.invalidDateFormat => 'Invalid date format in response',
      ParseFailure.schemaMismatch => 'Response does not match expected schema',
    },
    PermissionAppFailure(:final type, :final permission) => switch (type) {
      PermissionFailure.denied =>
        'Permission${permission != null ? ' "$permission"' : ''} denied',
      PermissionFailure.permanentlyDenied =>
        'Permission${permission != null ? ' "$permission"' : ''} permanently denied. Open Settings',
      PermissionFailure.restricted =>
        'Permission${permission != null ? ' "$permission"' : ''} restricted by the system',
      PermissionFailure.notDetermined => 'Permission not requested yet',
      PermissionFailure.cameraDenied => 'Camera access denied',
      PermissionFailure.microphoneDenied => 'Microphone access denied',
      PermissionFailure.locationDenied => 'Location access denied',
      PermissionFailure.locationAlwaysDenied => 'Background location denied',
      PermissionFailure.notificationDenied => 'Notifications disabled',
      PermissionFailure.contactsDenied => 'Contacts access denied',
      PermissionFailure.storageDenied => 'Storage access denied',
      PermissionFailure.calendarDenied => 'Calendar access denied',
      PermissionFailure.bluetoothDenied => 'Bluetooth access denied',
      PermissionFailure.activityDenied => 'Activity data access denied',
      PermissionFailure.trackingDenied => 'Tracking denied',
      PermissionFailure.speechRecognitionDenied =>
        'Speech recognition access denied',
      PermissionFailure.biometricDenied => 'Biometrics access denied',
      PermissionFailure.nfcDenied => 'NFC access denied',
    },
    PlatformAppFailure(:final type) => switch (type) {
      PlatformFailure.methodNotImplemented =>
        'Feature not supported on this platform',
      PlatformFailure.pluginError => 'System plugin error',
      PlatformFailure.osError => 'System error',
      PlatformFailure.notSupported => 'Device does not support this feature',
      PlatformFailure.gpsDisabled => 'GPS is off. Enable location',
      PlatformFailure.bluetoothDisabled => 'Bluetooth is off',
      PlatformFailure.nfcDisabled => 'NFC is off',
      PlatformFailure.wifiDisabled => 'Wi-Fi is off',
      PlatformFailure.deviceOffline => 'Device is offline',
      PlatformFailure.airplaneModeEnabled => 'Airplane mode is on',
      PlatformFailure.channelError => 'Platform channel error',
      PlatformFailure.channelTimeout => 'Platform channel timed out',
      PlatformFailure.outOfMemory => 'Not enough memory on device',
      PlatformFailure.lowPowerMode => 'Low power mode is on',
    },
    FileAppFailure(:final type) => switch (type) {
      FileFailure.notFound => 'File not found',
      FileFailure.readError => 'Failed to read file',
      FileFailure.writeError => 'Failed to write file',
      FileFailure.deleteError => 'Failed to delete file',
      FileFailure.copyError => 'Failed to copy file',
      FileFailure.moveError => 'Failed to move file',
      FileFailure.tooLarge => 'File is too large',
      FileFailure.invalidType => 'Invalid file type',
      FileFailure.corrupted => 'File is corrupted',
      FileFailure.accessDenied => 'No access to file',
      FileFailure.directoryNotFound => 'Folder not found',
      FileFailure.directoryCreationFailed => 'Failed to create folder',
      FileFailure.outOfSpace => 'Not enough space for file',
      FileFailure.uploadFailed => 'Upload failed',
      FileFailure.downloadFailed => 'Download failed',
      FileFailure.uploadCancelled => 'Upload cancelled',
      FileFailure.downloadCancelled => 'Download cancelled',
      FileFailure.uploadTimeout => 'Upload timed out',
      FileFailure.downloadTimeout => 'Download timed out',
    },
    LocationAppFailure(:final type) => switch (type) {
      LocationFailure.permissionDenied => 'Location access denied',
      LocationFailure.permissionPermanentlyDenied =>
        'Location permanently denied. Open Settings',
      LocationFailure.gpsDisabled => 'GPS is off. Enable location',
      LocationFailure.locationUnavailable => 'Could not determine location',
      LocationFailure.timeout => 'Location request timed out',
      LocationFailure.geocodingFailed => 'Geocoding failed',
      LocationFailure.reverseGeocodingFailed => 'Reverse geocoding failed',
      LocationFailure.invalidCoordinates => 'Invalid coordinates',
      LocationFailure.outOfBounds => 'Location outside allowed area',
    },
    NotificationAppFailure(:final type) => switch (type) {
      NotificationFailure.permissionDenied => 'Notifications disabled',
      NotificationFailure.tokenRegistrationFailed =>
        'Failed to register for notifications',
      NotificationFailure.tokenExpired => 'Notification token expired',
      NotificationFailure.sendFailed => 'Failed to send notification',
      NotificationFailure.scheduleFailed => 'Failed to schedule notification',
      NotificationFailure.cancelFailed => 'Failed to cancel notification',
      NotificationFailure.serviceUnavailable =>
        'Notification service unavailable',
      NotificationFailure.invalidPayload => 'Invalid notification payload',
      NotificationFailure.channelNotFound => 'Notification channel not found',
    },
    PaymentAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            PaymentFailure.declined => 'Payment declined by bank',
            PaymentFailure.insufficientFunds => 'Insufficient funds',
            PaymentFailure.cardBlocked => 'Card is blocked',
            PaymentFailure.cardExpired => 'Card has expired',
            PaymentFailure.invalidCvv => 'Invalid CVV',
            PaymentFailure.invalidCardNumber => 'Invalid card number',
            PaymentFailure.invalidPin => 'Invalid PIN',
            PaymentFailure.limitExceeded => 'Transaction limit exceeded',
            PaymentFailure.cancelledByUser => 'Payment cancelled',
            PaymentFailure.timeout => 'Payment timed out',
            PaymentFailure.gatewayError => 'Payment gateway error',
            PaymentFailure.threeDSecureFailed =>
              '3D Secure authentication failed',
            PaymentFailure.duplicateTransaction => 'Transaction already exists',
            PaymentFailure.refundFailed => 'Refund failed',
            PaymentFailure.serviceUnavailable => 'Payment service unavailable',
            PaymentFailure.invalidCurrency => 'Invalid currency',
            PaymentFailure.invalidAmount => 'Invalid payment amount',
          },
    SyncAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            SyncFailure.alreadyInProgress => 'Sync already in progress',
            SyncFailure.conflict => 'Data conflict during sync',
            SyncFailure.noData => 'No data to sync',
            SyncFailure.dataOutdated => 'Data is outdated',
            SyncFailure.partialSync => 'Sync completed partially',
            SyncFailure.cancelled => 'Sync cancelled',
            SyncFailure.timeout => 'Sync timed out',
            SyncFailure.serverUnavailable => 'Sync server unavailable',
            SyncFailure.versionMismatch => 'Incompatible data version',
            SyncFailure.dataLimitExceeded => 'Sync data limit exceeded',
          },
    UnknownAppFailure(:final message) =>
      message ?? 'Something went wrong. Please try again',
  };
}
