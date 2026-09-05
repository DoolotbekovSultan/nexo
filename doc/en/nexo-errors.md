# Error Handling: Failure and Result

Nexo provides a unified error model via the sealed class `Failure` and the functional type `Result<T>`.

---

## Failure — Unified Error Model

`Failure` is a sealed class with 16 constructors for different error categories:

```dart
sealed class Failure {
  // Constructors
  Failure.network(...)     // Network errors
  Failure.http(...)        // HTTP errors (4xx, 5xx)
  Failure.auth(...)        // Authentication
  Failure.validation(...)  // Data validation
  Failure.storage(...)     // Local storage
  Failure.database(...)    // Database
  Failure.cache(...)       // Cache
  Failure.parse(...)       // Data parsing
  Failure.permission(...)  // OS permissions
  Failure.platform(...)    // Platform errors
  Failure.file(...)        // File operations
  Failure.location(...)    // Geolocation
  Failure.notification(...) // Push notifications
  Failure.payment(...)     // Payments
  Failure.sync(...)        // Data synchronization
  Failure.unknown(...)     // Unknown errors
}
```

### Every Failure contains

| Property | Type | Description |
|----------|------|-------------|
| `userMessage` | `String` | Message for the user (Russian by default) |
| `code` | `String` | Stable error code (e.g. `network.no_internet`) |
| `isRetryable` | `bool` | Whether the operation can be retried |
| `requiresLogout` | `bool` | Whether the user must be logged out |
| `logCategory` | `String` | Category for logging / analytics |

### Creation examples

```dart
// Network error
final failure = Failure.network(type: NetworkFailure.noInternet);

// HTTP error with details
final failure = Failure.http(
  type: HttpFailure.unauthorized,
  statusCode: 401,
  message: 'Invalid token',
);

// Auth error
final failure = Failure.auth(
  type: AuthFailure.tokenExpired,
  message: 'Session expired',
);

// Validation error with per-field errors
final failure = Failure.validation(
  type: ValidationFailure.requiredField,
  field: 'email',
  message: 'Email is required',
  fieldErrors: {'email': ['Required', 'Invalid format']},
);
```

---

## Enum Reference

### NetworkFailure

| Value | Description |
|-------|-------------|
| `noInternet` | No internet connection |
| `timeout` | Connection timed out |
| `badCertificate` | Invalid SSL certificate |
| `cancelled` | Request was cancelled |
| `dnsLookupFailed` | DNS resolution failed |
| `connectionRefused` | Server refused the connection |
| `hostUnreachable` | Host is unreachable |
| `connectionReset` | Connection was reset |
| `proxyError` | Proxy server error |
| `vpnError` | VPN error |
| `tooManyRedirects` | Too many redirects |
| `invalidUrl` | Invalid URL |

### HttpFailure

| Value | HTTP Status | Description |
|-------|-------------|-------------|
| `badRequest` | 400 | Bad request |
| `unauthorized` | 401 | Not authenticated |
| `paymentRequired` | 402 | Payment required |
| `forbidden` | 403 | Access denied |
| `notFound` | 404 | Resource not found |
| `methodNotAllowed` | 405 | HTTP method not allowed |
| `notAcceptable` | 406 | Not acceptable response format |
| `proxyAuthRequired` | 407 | Proxy authentication required |
| `requestTimeout` | 408 | Request timed out |
| `conflict` | 409 | Data conflict |
| `gone` | 410 | Resource permanently removed |
| `lengthRequired` | 411 | Content-Length required |
| `preconditionFailed` | 412 | Precondition failed |
| `payloadTooLarge` | 413 | Request body too large |
| `uriTooLong` | 414 | URI too long |
| `unsupportedMediaType` | 415 | Unsupported content type |
| `rangeNotSatisfiable` | 416 | Requested range not satisfiable |
| `expectationFailed` | 417 | Expectation failed |
| `teapot` | 418 | I'm a teapot (RFC 2324) |
| `misdirectedRequest` | 421 | Misdirected request |
| `unprocessableEntity` | 422 | Server-side validation errors |
| `locked` | 423 | Resource locked |
| `failedDependency` | 424 | Failed dependency |
| `tooEarly` | 425 | Too Early |
| `upgradeRequired` | 426 | Protocol upgrade required |
| `preconditionRequired` | 428 | Precondition required |
| `tooManyRequests` | 429 | Too many requests |
| `requestHeaderFieldsTooLarge` | 431 | Request header fields too large |
| `unavailableForLegalReasons` | 451 | Unavailable for legal reasons |
| `internalServerError` | 500 | Internal server error |
| `notImplemented` | 501 | Not implemented on server |
| `badGateway` | 502 | Bad gateway |
| `serviceUnavailable` | 503 | Service unavailable |
| `gatewayTimeout` | 504 | Gateway timed out |
| `httpVersionNotSupported` | 505 | HTTP version not supported |
| `variantAlsoNegotiates` | 506 | Variant also negotiates |
| `insufficientStorage` | 507 | Insufficient storage on server |
| `loopDetected` | 508 | Loop detected |
| `notExtended` | 510 | Extension not required |
| `networkAuthenticationRequired` | 511 | Network authentication required |
| `unknown` | — | Any other HTTP error status |

### AuthFailure

| Value | Description |
|-------|-------------|
| `unauthorized` | No active session |
| `forbidden` | Insufficient permissions |
| `tokenExpired` | Access token expired |
| `tokenInvalid` | Token invalid / corrupted |
| `refreshTokenExpired` | Refresh token expired |
| `refreshTokenInvalid` | Refresh token invalid |
| `sessionRevoked` | Session revoked (logout from another device / block) |
| `sessionNotFound` | Session not found |
| `wrongCredentials` | Wrong login / password |
| `accountBlocked` | Account blocked |
| `accountTemporarilyLocked` | Account temporarily locked (too many failed attempts) |
| `accountNotVerified` | Account not verified (email / phone) |
| `accountDeleted` | Account deleted |
| `accountNotFound` | Account not found |
| `accountAlreadyExists` | Account already exists |
| `passwordExpired` | Password expired, change required |
| `twoFactorRequired` | Two-factor authentication required |
| `twoFactorFailed` | Invalid two-factor code |
| `twoFactorExpired` | Two-factor code expired |
| `biometricFailed` | Biometric authentication error |
| `biometricNotAvailable` | Biometric not set up on device |
| `biometricLocked` | Biometric locked (too many failed attempts) |
| `oauthFailed` | OAuth provider error (Google, Apple, Facebook...) |
| `oauthDenied` | OAuth provider denied the request |
| `oauthTokenInvalid` | Invalid OAuth token |
| `oauthAccountNotLinked` | Account not linked to OAuth provider |

### ValidationFailure

| Value | Description |
|-------|-------------|
| `requiredField` | Required field is empty |
| `invalidFormat` | Invalid field format |
| `invalidEmail` | Invalid email format |
| `invalidPhone` | Invalid phone format |
| `invalidUrl` | Invalid URL format |
| `invalidDate` | Invalid date format |
| `invalidTime` | Invalid time format |
| `invalidNumber` | Invalid number format |
| `invalidCardNumber` | Invalid card number format |
| `tooLong` | Value exceeds max length |
| `tooShort` | Value is shorter than min length |
| `tooLarge` | Numeric value exceeds maximum |
| `tooSmall` | Numeric value is below minimum |
| `outOfRange` | Value out of allowed range |
| `notUnique` | Value is not unique (already exists) |
| `passwordTooWeak` | Password is too weak |
| `passwordMismatch` | Passwords do not match |
| `fileTooLarge` | File is too large |
| `invalidFileType` | Invalid file type |
| `invalidImageSize` | Invalid image dimensions |
| `invalidCharacters` | Value contains disallowed characters |
| `serverValidation` | Multiple validation errors from server |

---

## Result\<T\> — Functional Result

`Result<T>` is a sealed class replacing try-catch with composition:

```dart
sealed class Result<T> {
  Result.success(T value);  // Right — success
  Result.failure(Failure);  // Left — failure
}
```

### Creation

```dart
// Success
final result = Result.success(User(name: 'John'));

// Failure
final result = Result<int>.failure(
  Failure.network(type: NetworkFailure.noInternet),
);
```

### Handling

```dart
// 1. fold — unwrap into a single value
final message = result.fold(
  onFailure: (f) => f.userMessage,
  onSuccess: (data) => 'Loaded: $data',
);

// 2. Pattern matching
final text = switch (result) {
  Right(:final value) => 'Data: $value',
  Left(:final failure) => failure.userMessage,
};

// 3. Type check
if (result.isSuccess) {
  final data = result.dataOrNull;
}

// 4. Get value or fallback
final data = result.getOrElse((f) => defaultValue);

// 5. Transform
final mapped = result.map((data) => data.toUpperCase());
```

### In a UseCase

```dart
class GetUserUseCase extends NexoUseCase<User, String> {
  GetUserUseCase(super.logger);

  @override
  Future<User> execute(String userId) async {
    return await api.getUser(userId);
  }
}

// Calling — automatically wraps in Result
final result = await GetUserUseCase(logger)('user_123');

result.fold(
  onFailure: (f) => showError(f.userMessage),
  onSuccess: (user) => showProfile(user),
);
```

---

## Error Mappers

`FailureMapper` converts arbitrary exceptions into `Failure`:

```dart
try {
  await dio.get('/api/data');
} catch (e, s) {
  // Automatic mapping
  final failure = FailureMapper.from(e, s);
  showSnackBar(failure.userMessage);
}
```

### Via extension

```dart
catch (e, s) {
  final failure = e.toFailure(s);
  // same thing
}
```

### Mapper chain

`FailureMapper` tries mappers in order:

1. `DomainExceptionFailureMapper` — custom `AppException`
2. `FirebaseAuthFailureMapper` — Firebase Auth errors
3. `FirebaseMessagingFailureMapper` — Firebase Messaging errors
4. `DioFailureMapper` — Dio errors (HTTP)
5. `PlatformFailureMapper` — platform plugin errors
6. `HiveFailureMapper` — Hive errors
7. `IsarFailureMapper` — Isar errors
8. `DriftFailureMapper` — Drift/SQLite errors
9. `FileSystemFailureMapper` — file system errors
10. `CommonFailureMapper` — universal catch-all

---

## AppException — Domain Exceptions

For business logic errors, use `AppException`:

```dart
// Throw exceptions in UseCase / repositories
throw AuthAppException(AuthFailure.wrongCredentials, message: 'Wrong password');
throw ValidationAppException(
  ValidationFailure.requiredField,
  field: 'email',
  fieldErrors: {'email': ['Required']},
);

// FailureMapper automatically converts them to Failure
```

### AppException types

| Exception | Category |
|-----------|----------|
| `AuthAppException` | Authentication |
| `ValidationAppException` | Validation |
| `StorageAppException` | Storage |
| `DatabaseAppException` | Database |
| `CacheAppException` | Cache |
| `ParseAppException` | Parsing |
| `PermissionAppException` | Permissions |
| `PlatformAppException` | Platform |
| `FileAppException` | Files |
| `LocationAppException` | Location |
| `NotificationAppException` | Notifications |
| `PaymentAppException` | Payments |
| `SyncAppException` | Synchronization |

---

## Message Localization

### Built-in localization

```dart
// Russian messages (default)
final message = failure.userMessage; // "Нет подключения к интернету"

// English messages
final catalog = EnFailureUserMessages();
final message = failure.localizedMessage(catalog); // "No internet connection"
```

### Custom localization

```dart
class MyMessages implements FailureUserMessageCatalog {
  @override
  String forFailure(Failure failure) => switch (failure) {
    NetworkAppFailure(:final type) => switch (type) {
      NetworkFailure.noInternet => 'Check your connection',
      NetworkFailure.timeout => 'Server is not responding',
      _ => 'Network error',
    },
    _ => 'An error occurred',
  };
}

final message = failure.localizedMessage(MyMessages());
```

---

## FailurePresenter — Ready-made UI Strings

```dart
// For Snackbar
final text = FailurePresenter.snackbarMessage(failure);

// For Dialog — title
final title = FailurePresenter.dialogTitle(failure);

// For Dialog — body
final body = FailurePresenter.dialogBody(failure);

// Technical code (for developers)
final code = FailurePresenter.technicalCode(failure);
// → "network.no_internet"
```

---

## Error Codes

Every `Failure` has a stable string code:

```dart
final code = failure.code;
// → "network.no_internet"
// → "http.unauthorized"
// → "auth.token_expired"
// → "validation.required_field"
```

Codes are useful for:
- Analytics (tracking error frequency)
- Filtering (react to specific errors)
- Logging (stable identifier)

```dart
if (failure.code == 'auth.token_expired') {
  // Refresh the token
} else if (failure.code == 'network.no_internet') {
  // Show offline screen
}
```

---

## NexoFlutterErrors — Global Error Handling

`NexoFlutterErrors` provides global error capture for Flutter applications. After `install()`, the following are intercepted:

- `FlutterError.onError` — rendering errors and debug asserts
- `PlatformDispatcher.instance.onError` — uncaught async errors

Additionally, use `runAppInZone()` to catch errors within a zone.

### install()

```dart
NexoFlutterErrors.install(
  logger: logger,
  crashReporter: crashReporter, // optional
);
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `logger` | `NexoLogger` | yes | Logger for recording errors |
| `crashReporter` | `NexoCrashReporter` | no | Crash reporting service (e.g. Sentry, Crashlytics) |

### uninstall()

Removes the global handlers. Useful in tests.

```dart
NexoFlutterErrors.uninstall();
```

### runAppInZone()

Wraps `body` in `runZonedGuarded` with error reporting to both the logger and `NexoCrashReporter`. Errors from the `body` itself are caught and reported (without re-throwing) so the `Future` completes; the second channel catches unhandled errors within the zone.

```dart
NexoFlutterErrors.runAppInZone(() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DI setup, NexoFlutterErrors.install(), etc.
  runApp(MyApp());
});
```

### Gotcha: Zone Mismatch

`WidgetsFlutterBinding.ensureInitialized()` and `runApp` **must** be called in the **same zone**. If you call `ensureInitialized` outside the zone and `runApp` inside, Flutter will report a zone mismatch error.

**Correct:**

```dart
NexoFlutterErrors.runAppInZone(() async {
  WidgetsFlutterBinding.ensureInitialized();
  NexoFlutterErrors.install(logger: logger);
  runApp(MyApp());
});
```

**Wrong:**

```dart
WidgetsFlutterBinding.ensureInitialized();
NexoFlutterErrors.install(logger: logger);
NexoFlutterErrors.runAppInZone(() async {
  runApp(MyApp()); // zone mismatch!
});
```

**Rule:** Wrap your entire `main` (including `ensureInitialized`, DI, `install`, and `runApp`) inside the body of `runAppInZone`.
