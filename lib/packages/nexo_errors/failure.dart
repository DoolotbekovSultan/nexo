import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexo/packages/nexo_errors/types/file_failure.dart';
import 'package:nexo/packages/nexo_errors/types/auth_failure.dart';
import 'package:nexo/packages/nexo_errors/types/cache_failure.dart';
import 'package:nexo/packages/nexo_errors/types/database_failure.dart';
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

part 'failure.freezed.dart';

/// Система ошибок приложения
///
/// Иерархия:
/// Failure
/// ├── NetworkFailure      — проблемы соединения
/// ├── HttpFailure         — HTTP-ответы с ошибками (4xx / 5xx)
/// ├── AuthFailure         — аутентификация / авторизация
/// ├── ValidationFailure   — валидация данных
/// ├── StorageFailure      — SharedPreferences / SecureStorage / FileSystem
/// ├── DatabaseFailure     — локальная БД (Drift, Isar, SQLite)
/// ├── CacheFailure        — кэш
/// ├── ParseFailure        — парсинг / сериализация
/// ├── PermissionFailure   — разрешения ОС
/// ├── PlatformFailure     — MethodChannel / плагины / ОС
/// ├── FileFailure         — работа с файлами
/// ├── LocationFailure     — геолокация
/// ├── NotificationFailure — push-уведомления
/// ├── PaymentFailure      — платежи
/// ├── SyncFailure         — синхронизация данных
/// └── UnknownFailure      — непредвиденные ошибки
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Проблемы соединения
  const factory Failure.network({required NetworkFailure type}) =
      NetworkAppFailure;

  /// HTTP-ошибки (4xx / 5xx)
  const factory Failure.http({
    required HttpFailure type,
    int? statusCode,
    String? message,
    @Default({}) Map<String, List<String>> fieldErrors,
  }) = HttpAppFailure;

  /// Ошибки аутентификации и авторизации
  const factory Failure.auth({required AuthFailure type, String? message}) =
      AuthAppFailure;

  /// Ошибки валидации данных
  const factory Failure.validation({
    required ValidationFailure type,
    String? field,
    String? message,
    @Default({}) Map<String, List<String>> fieldErrors,
  }) = ValidationAppFailure;

  /// Ошибки локального хранилища
  const factory Failure.storage({
    required StorageFailure type,
    String? key,
    String? message,
  }) = StorageAppFailure;

  /// Ошибки локальной базы данных
  const factory Failure.database({
    required DatabaseFailure type,
    String? message,
  }) = DatabaseAppFailure;

  /// Ошибки кэша
  const factory Failure.cache({required CacheFailure type, String? key}) =
      CacheAppFailure;

  /// Ошибки парсинга / сериализации
  const factory Failure.parse({
    required ParseFailure type,
    String? field,
    String? message,
  }) = ParseAppFailure;

  /// Ошибки разрешений ОС
  const factory Failure.permission({
    required PermissionFailure type,
    String? permission,
  }) = PermissionAppFailure;

  /// Ошибки платформы (MethodChannel, плагины, ОС)
  const factory Failure.platform({
    required PlatformFailure type,
    String? details,
  }) = PlatformAppFailure;

  /// Ошибки работы с файлами
  const factory Failure.file({
    required FileFailure type,
    String? path,
    String? message,
  }) = FileAppFailure;

  /// Ошибки геолокации
  const factory Failure.location({
    required LocationFailure type,
    String? message,
  }) = LocationAppFailure;

  /// Ошибки push-уведомлений
  const factory Failure.notification({
    required NotificationFailure type,
    String? message,
  }) = NotificationAppFailure;

  /// Ошибки платежей
  const factory Failure.payment({
    required PaymentFailure type,
    String? message,
    String? transactionId,
  }) = PaymentAppFailure;

  /// Ошибки синхронизации данных
  const factory Failure.sync({required SyncFailure type, String? message}) =
      SyncAppFailure;

  /// Непредвиденная ошибка
  const factory Failure.unknown({
    Object? error,
    StackTrace? stackTrace,
    String? message,
  }) = UnknownAppFailure;

  /// Человеко-читаемое сообщение для UI
  String get userMessage => switch (this) {
    NetworkAppFailure(:final type) => switch (type) {
      NetworkFailure.noInternet => 'Нет подключения к интернету',
      NetworkFailure.timeout => 'Превышено время ожидания',
      NetworkFailure.badCertificate => 'Ошибка безопасного соединения',
      NetworkFailure.cancelled => 'Запрос отменён',
      NetworkFailure.dnsLookupFailed => 'Не удалось определить адрес сервера',
      NetworkFailure.connectionRefused => 'Сервер отклонил соединение',
      NetworkFailure.hostUnreachable => 'Сервер недоступен',
      NetworkFailure.connectionReset => 'Соединение прервано',
      NetworkFailure.proxyError => 'Ошибка прокси-сервера',
      NetworkFailure.vpnError => 'Ошибка VPN-соединения',
      NetworkFailure.tooManyRedirects => 'Слишком много перенаправлений',
      NetworkFailure.invalidUrl => 'Неверный адрес запроса',
    },
    HttpAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            HttpFailure.badRequest => 'Некорректный запрос',
            HttpFailure.unauthorized => 'Необходима авторизация',
            HttpFailure.paymentRequired => 'Требуется оплата',
            HttpFailure.forbidden => 'Доступ запрещён',
            HttpFailure.notFound => 'Ресурс не найден',
            HttpFailure.methodNotAllowed => 'Метод не поддерживается',
            HttpFailure.notAcceptable => 'Неприемлемый формат ответа',
            HttpFailure.proxyAuthRequired => 'Требуется аутентификация прокси',
            HttpFailure.requestTimeout => 'Время ожидания запроса истекло',
            HttpFailure.conflict => 'Конфликт данных',
            HttpFailure.gone => 'Ресурс больше недоступен',
            HttpFailure.lengthRequired => 'Требуется указать длину содержимого',
            HttpFailure.preconditionFailed =>
              'Предварительное условие не выполнено',
            HttpFailure.payloadTooLarge => 'Запрос слишком большой',
            HttpFailure.uriTooLong => 'Адрес запроса слишком длинный',
            HttpFailure.unsupportedMediaType =>
              'Неподдерживаемый формат данных',
            HttpFailure.rangeNotSatisfiable =>
              'Запрошенный диапазон недоступен',
            HttpFailure.expectationFailed => 'Ожидание не выполнено',
            HttpFailure.teapot => 'Сервер — чайник',
            HttpFailure.misdirectedRequest => 'Неверно перенаправленный запрос',
            HttpFailure.unprocessableEntity => 'Ошибка валидации данных',
            HttpFailure.locked => 'Ресурс заблокирован',
            HttpFailure.failedDependency => 'Зависимая операция не выполнена',
            HttpFailure.tooEarly => 'Запрос слишком ранний',
            HttpFailure.upgradeRequired => 'Требуется обновление протокола',
            HttpFailure.preconditionRequired =>
              'Требуется предварительное условие',
            HttpFailure.tooManyRequests =>
              'Слишком много запросов. Попробуйте позже',
            HttpFailure.requestHeaderFieldsTooLarge =>
              'Заголовки запроса слишком большие',
            HttpFailure.unavailableForLegalReasons =>
              'Недоступно по юридическим причинам',
            HttpFailure.internalServerError =>
              'Ошибка сервера. Попробуйте позже',
            HttpFailure.notImplemented => 'Функция не реализована на сервере',
            HttpFailure.badGateway => 'Сервер временно недоступен',
            HttpFailure.serviceUnavailable =>
              'Сервис на техническом обслуживании',
            HttpFailure.gatewayTimeout => 'Сервер не отвечает',
            HttpFailure.httpVersionNotSupported =>
              'Версия HTTP не поддерживается',
            HttpFailure.variantAlsoNegotiates =>
              'Ошибка согласования содержимого',
            HttpFailure.insufficientStorage => 'Недостаточно места на сервере',
            HttpFailure.loopDetected => 'Обнаружена петля запросов',
            HttpFailure.notExtended => 'Требуется расширение запроса',
            HttpFailure.networkAuthenticationRequired =>
              'Требуется сетевая аутентификация',
            HttpFailure.unknown => 'Ошибка сервера',
          },
    AuthAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            AuthFailure.unauthorized => 'Необходима авторизация',
            AuthFailure.forbidden => 'Недостаточно прав',
            AuthFailure.tokenExpired => 'Сессия истекла. Войдите снова',
            AuthFailure.tokenInvalid => 'Ошибка авторизации. Войдите снова',
            AuthFailure.refreshTokenExpired => 'Сессия истекла. Войдите снова',
            AuthFailure.refreshTokenInvalid =>
              'Ошибка авторизации. Войдите снова',
            AuthFailure.sessionRevoked => 'Сессия завершена. Войдите снова',
            AuthFailure.sessionNotFound => 'Сессия не найдена. Войдите снова',
            AuthFailure.wrongCredentials => 'Неверный логин или пароль',
            AuthFailure.accountBlocked => 'Аккаунт заблокирован',
            AuthFailure.accountTemporarilyLocked =>
              'Аккаунт временно заблокирован. Попробуйте позже',
            AuthFailure.accountNotVerified => 'Аккаунт не подтверждён',
            AuthFailure.accountDeleted => 'Аккаунт удалён',
            AuthFailure.accountNotFound => 'Аккаунт не найден',
            AuthFailure.accountAlreadyExists => 'Аккаунт уже существует',
            AuthFailure.passwordExpired => 'Пароль истёк. Измените пароль',
            AuthFailure.twoFactorRequired =>
              'Требуется двухфакторная аутентификация',
            AuthFailure.twoFactorFailed => 'Неверный код подтверждения',
            AuthFailure.twoFactorExpired => 'Код подтверждения истёк',
            AuthFailure.biometricFailed =>
              'Ошибка биометрической аутентификации',
            AuthFailure.biometricNotAvailable =>
              'Биометрия не настроена на устройстве',
            AuthFailure.biometricLocked => 'Биометрия заблокирована',
            AuthFailure.oauthFailed => 'Ошибка входа через внешний сервис',
            AuthFailure.oauthDenied => 'Вход через внешний сервис отклонён',
            AuthFailure.oauthTokenInvalid =>
              'Токен внешнего сервиса недействителен',
            AuthFailure.oauthAccountNotLinked =>
              'Аккаунт не привязан к внешнему сервису',
          },
    ValidationAppFailure(:final type, :final field, :final message) =>
      message ??
          switch (type) {
            ValidationFailure.requiredField =>
              'Поле${field != null ? ' «$field»' : ''} обязательно',
            ValidationFailure.invalidFormat =>
              'Неверный формат${field != null ? ' поля «$field»' : ''}',
            ValidationFailure.invalidEmail => 'Неверный формат email',
            ValidationFailure.invalidPhone => 'Неверный формат телефона',
            ValidationFailure.invalidUrl => 'Неверный формат URL',
            ValidationFailure.invalidDate => 'Неверный формат даты',
            ValidationFailure.invalidTime => 'Неверный формат времени',
            ValidationFailure.invalidNumber => 'Неверный формат числа',
            ValidationFailure.invalidCardNumber => 'Неверный номер карты',
            ValidationFailure.tooLong =>
              '${field != null ? '«$field»' : 'Поле'} слишком длинное',
            ValidationFailure.tooShort =>
              '${field != null ? '«$field»' : 'Поле'} слишком короткое',
            ValidationFailure.tooLarge => 'Значение слишком большое',
            ValidationFailure.tooSmall => 'Значение слишком маленькое',
            ValidationFailure.outOfRange =>
              'Значение вне допустимого диапазона',
            ValidationFailure.notUnique =>
              '${field != null ? '«$field»' : 'Значение'} уже существует',
            ValidationFailure.passwordTooWeak => 'Пароль слишком слабый',
            ValidationFailure.passwordMismatch => 'Пароли не совпадают',
            ValidationFailure.fileTooLarge => 'Файл слишком большой',
            ValidationFailure.invalidFileType => 'Неверный тип файла',
            ValidationFailure.invalidImageSize => 'Неверный размер изображения',
            ValidationFailure.invalidCharacters =>
              'Поле содержит недопустимые символы',
            ValidationFailure.serverValidation => 'Ошибка валидации данных',
          },
    StorageAppFailure(:final type) => switch (type) {
      StorageFailure.readError => 'Ошибка чтения данных',
      StorageFailure.writeError => 'Ошибка сохранения данных',
      StorageFailure.deleteError => 'Ошибка удаления данных',
      StorageFailure.clearError => 'Ошибка очистки данных',
      StorageFailure.notFound => 'Данные не найдены',
      StorageFailure.permissionDenied => 'Нет доступа к хранилищу',
      StorageFailure.outOfSpace => 'Недостаточно места на устройстве',
      StorageFailure.corrupted => 'Данные повреждены',
      StorageFailure.encryptionError => 'Ошибка шифрования данных',
      StorageFailure.decryptionError => 'Ошибка расшифровки данных',
      StorageFailure.unavailable => 'Хранилище недоступно',
      StorageFailure.versionMismatch => 'Несовместимая версия данных',
    },
    DatabaseAppFailure(:final type) => switch (type) {
      DatabaseFailure.readError => 'Ошибка чтения из базы данных',
      DatabaseFailure.writeError => 'Ошибка сохранения в базу данных',
      DatabaseFailure.deleteError => 'Ошибка удаления из базы данных',
      DatabaseFailure.updateError => 'Ошибка обновления в базе данных',
      DatabaseFailure.notFound => 'Запись не найдена',
      DatabaseFailure.uniqueConstraintViolation => 'Запись уже существует',
      DatabaseFailure.foreignKeyViolation => 'Нарушение связи данных',
      DatabaseFailure.notNullViolation => 'Отсутствует обязательное поле',
      DatabaseFailure.migrationFailed => 'Ошибка обновления базы данных',
      DatabaseFailure.transactionFailed => 'Ошибка транзакции',
      DatabaseFailure.corrupted => 'База данных повреждена',
      DatabaseFailure.locked => 'База данных заблокирована',
      DatabaseFailure.connectionLost => 'Соединение с базой данных разорвано',
      DatabaseFailure.outOfSpace => 'Недостаточно места для базы данных',
      DatabaseFailure.queryTimeout => 'Таймаут запроса к базе данных',
    },
    CacheAppFailure(:final type) => switch (type) {
      CacheFailure.miss => 'Данные не найдены в кэше',
      CacheFailure.expired => 'Кэш устарел',
      CacheFailure.readError => 'Ошибка чтения кэша',
      CacheFailure.writeError => 'Ошибка записи в кэш',
      CacheFailure.deleteError => 'Ошибка удаления из кэша',
      CacheFailure.clearError => 'Ошибка очистки кэша',
      CacheFailure.outOfSpace => 'Недостаточно места для кэша',
      CacheFailure.corrupted => 'Данные кэша повреждены',
      CacheFailure.invalidated => 'Кэш инвалидирован',
    },
    ParseAppFailure(:final type) => switch (type) {
      ParseFailure.jsonDecode => 'Ошибка обработки данных',
      ParseFailure.jsonEncode => 'Ошибка подготовки данных',
      ParseFailure.xmlDecode => 'Ошибка обработки XML',
      ParseFailure.csvDecode => 'Ошибка обработки CSV',
      ParseFailure.unexpectedType => 'Неожиданный формат данных',
      ParseFailure.missingField => 'Отсутствует поле в ответе сервера',
      ParseFailure.invalidEnumValue => 'Неверное значение в ответе сервера',
      ParseFailure.emptyResponse => 'Пустой ответ от сервера',
      ParseFailure.nullValue => 'Получено пустое значение',
      ParseFailure.invalidDateFormat => 'Неверный формат даты в ответе',
      ParseFailure.schemaMismatch => 'Ответ не соответствует ожидаемой схеме',
    },
    PermissionAppFailure(:final type, :final permission) => switch (type) {
      PermissionFailure.denied =>
        'Разрешение${permission != null ? ' «$permission»' : ''} отклонено',
      PermissionFailure.permanentlyDenied =>
        'Разрешение${permission != null ? ' «$permission»' : ''} запрещено. Откройте настройки',
      PermissionFailure.restricted =>
        'Разрешение${permission != null ? ' «$permission»' : ''} ограничено системой',
      PermissionFailure.notDetermined => 'Разрешение ещё не запрошено',
      PermissionFailure.cameraDenied => 'Нет доступа к камере',
      PermissionFailure.microphoneDenied => 'Нет доступа к микрофону',
      PermissionFailure.locationDenied => 'Нет доступа к геолокации',
      PermissionFailure.locationAlwaysDenied =>
        'Нет доступа к геолокации в фоне',
      PermissionFailure.notificationDenied => 'Уведомления отключены',
      PermissionFailure.contactsDenied => 'Нет доступа к контактам',
      PermissionFailure.storageDenied => 'Нет доступа к хранилищу',
      PermissionFailure.calendarDenied => 'Нет доступа к календарю',
      PermissionFailure.bluetoothDenied => 'Нет доступа к Bluetooth',
      PermissionFailure.activityDenied => 'Нет доступа к данным активности',
      PermissionFailure.trackingDenied => 'Отслеживание запрещено',
      PermissionFailure.speechRecognitionDenied =>
        'Нет доступа к распознаванию речи',
      PermissionFailure.biometricDenied => 'Нет доступа к биометрии',
      PermissionFailure.nfcDenied => 'Нет доступа к NFC',
    },
    PlatformAppFailure(:final type) => switch (type) {
      PlatformFailure.methodNotImplemented =>
        'Функция не поддерживается на этой платформе',
      PlatformFailure.pluginError => 'Ошибка системного плагина',
      PlatformFailure.osError => 'Системная ошибка',
      PlatformFailure.notSupported => 'Устройство не поддерживает эту функцию',
      PlatformFailure.gpsDisabled => 'GPS отключён. Включите геолокацию',
      PlatformFailure.bluetoothDisabled => 'Bluetooth отключён',
      PlatformFailure.nfcDisabled => 'NFC отключён',
      PlatformFailure.wifiDisabled => 'Wi-Fi отключён',
      PlatformFailure.deviceOffline => 'Устройство не в сети',
      PlatformFailure.airplaneModeEnabled => 'Включён режим полёта',
      PlatformFailure.channelError => 'Ошибка системного канала',
      PlatformFailure.channelTimeout => 'Таймаут системного канала',
      PlatformFailure.outOfMemory => 'Недостаточно памяти на устройстве',
      PlatformFailure.lowPowerMode => 'Устройство в режиме экономии энергии',
    },
    FileAppFailure(:final type) => switch (type) {
      FileFailure.notFound => 'Файл не найден',
      FileFailure.readError => 'Ошибка чтения файла',
      FileFailure.writeError => 'Ошибка записи файла',
      FileFailure.deleteError => 'Ошибка удаления файла',
      FileFailure.copyError => 'Ошибка копирования файла',
      FileFailure.moveError => 'Ошибка перемещения файла',
      FileFailure.tooLarge => 'Файл слишком большой',
      FileFailure.invalidType => 'Неверный тип файла',
      FileFailure.corrupted => 'Файл повреждён',
      FileFailure.accessDenied => 'Нет доступа к файлу',
      FileFailure.directoryNotFound => 'Папка не найдена',
      FileFailure.directoryCreationFailed => 'Ошибка создания папки',
      FileFailure.outOfSpace => 'Недостаточно места для файла',
      FileFailure.uploadFailed => 'Ошибка загрузки файла',
      FileFailure.downloadFailed => 'Ошибка скачивания файла',
      FileFailure.uploadCancelled => 'Загрузка отменена',
      FileFailure.downloadCancelled => 'Скачивание отменено',
      FileFailure.uploadTimeout => 'Таймаут загрузки файла',
      FileFailure.downloadTimeout => 'Таймаут скачивания файла',
    },
    LocationAppFailure(:final type) => switch (type) {
      LocationFailure.permissionDenied => 'Нет доступа к геолокации',
      LocationFailure.permissionPermanentlyDenied =>
        'Геолокация запрещена. Откройте настройки',
      LocationFailure.gpsDisabled => 'GPS отключён. Включите геолокацию',
      LocationFailure.locationUnavailable =>
        'Не удалось определить местоположение',
      LocationFailure.timeout => 'Таймаут получения местоположения',
      LocationFailure.geocodingFailed => 'Ошибка определения адреса',
      LocationFailure.reverseGeocodingFailed => 'Ошибка определения координат',
      LocationFailure.invalidCoordinates => 'Неверные координаты',
      LocationFailure.outOfBounds =>
        'Местоположение за пределами допустимой зоны',
    },
    NotificationAppFailure(:final type) => switch (type) {
      NotificationFailure.permissionDenied => 'Уведомления отключены',
      NotificationFailure.tokenRegistrationFailed =>
        'Ошибка регистрации для уведомлений',
      NotificationFailure.tokenExpired => 'Токен уведомлений устарел',
      NotificationFailure.sendFailed => 'Ошибка отправки уведомления',
      NotificationFailure.scheduleFailed => 'Ошибка планирования уведомления',
      NotificationFailure.cancelFailed => 'Ошибка отмены уведомления',
      NotificationFailure.serviceUnavailable => 'Сервис уведомлений недоступен',
      NotificationFailure.invalidPayload => 'Неверные данные уведомления',
      NotificationFailure.channelNotFound => 'Канал уведомлений не найден',
    },
    PaymentAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            PaymentFailure.declined => 'Платёж отклонён банком',
            PaymentFailure.insufficientFunds => 'Недостаточно средств',
            PaymentFailure.cardBlocked => 'Карта заблокирована',
            PaymentFailure.cardExpired => 'Срок действия карты истёк',
            PaymentFailure.invalidCvv => 'Неверный CVV',
            PaymentFailure.invalidCardNumber => 'Неверный номер карты',
            PaymentFailure.invalidPin => 'Неверный PIN',
            PaymentFailure.limitExceeded => 'Превышен лимит транзакций',
            PaymentFailure.cancelledByUser => 'Платёж отменён',
            PaymentFailure.timeout => 'Таймаут платежа',
            PaymentFailure.gatewayError => 'Ошибка платёжного шлюза',
            PaymentFailure.threeDSecureFailed =>
              'Ошибка 3D Secure аутентификации',
            PaymentFailure.duplicateTransaction => 'Транзакция уже существует',
            PaymentFailure.refundFailed => 'Ошибка возврата средств',
            PaymentFailure.serviceUnavailable => 'Платёжный сервис недоступен',
            PaymentFailure.invalidCurrency => 'Неверная валюта',
            PaymentFailure.invalidAmount => 'Неверная сумма платежа',
          },
    SyncAppFailure(:final type, :final message) =>
      message ??
          switch (type) {
            SyncFailure.alreadyInProgress => 'Синхронизация уже выполняется',
            SyncFailure.conflict => 'Конфликт данных при синхронизации',
            SyncFailure.noData => 'Нет данных для синхронизации',
            SyncFailure.dataOutdated => 'Данные устарели',
            SyncFailure.partialSync => 'Синхронизация выполнена частично',
            SyncFailure.cancelled => 'Синхронизация отменена',
            SyncFailure.timeout => 'Таймаут синхронизации',
            SyncFailure.serverUnavailable => 'Сервер синхронизации недоступен',
            SyncFailure.versionMismatch => 'Несовместимая версия данных',
            SyncFailure.dataLimitExceeded =>
              'Превышен лимит данных для синхронизации',
          },
    UnknownAppFailure(:final message) =>
      message ?? 'Что-то пошло не так. Попробуйте снова',
  };

  /// Можно ли повторить запрос автоматически?
  bool get isRetryable => switch (this) {
    NetworkAppFailure(type: NetworkFailure.noInternet) => true,
    NetworkAppFailure(type: NetworkFailure.timeout) => true,
    NetworkAppFailure(type: NetworkFailure.connectionReset) => true,
    HttpAppFailure(type: HttpFailure.internalServerError) => true,
    HttpAppFailure(type: HttpFailure.badGateway) => true,
    HttpAppFailure(type: HttpFailure.serviceUnavailable) => true,
    HttpAppFailure(type: HttpFailure.gatewayTimeout) => true,
    HttpAppFailure(type: HttpFailure.tooManyRequests) => true,
    HttpAppFailure(type: HttpFailure.requestTimeout) => true,
    SyncAppFailure(type: SyncFailure.timeout) => true,
    SyncAppFailure(type: SyncFailure.serverUnavailable) => true,
    _ => false,
  };

  /// Требует ли выхода из аккаунта?
  bool get requiresLogout => switch (this) {
    AuthAppFailure(type: AuthFailure.tokenExpired) => true,
    AuthAppFailure(type: AuthFailure.tokenInvalid) => true,
    AuthAppFailure(type: AuthFailure.refreshTokenExpired) => true,
    AuthAppFailure(type: AuthFailure.refreshTokenInvalid) => true,
    AuthAppFailure(type: AuthFailure.sessionRevoked) => true,
    AuthAppFailure(type: AuthFailure.sessionNotFound) => true,
    HttpAppFailure(type: HttpFailure.unauthorized) => true,
    _ => false,
  };

  /// Требует ли открытия настроек устройства?
  bool get requiresSettings => switch (this) {
    PermissionAppFailure(type: PermissionFailure.permanentlyDenied) => true,
    PermissionAppFailure(type: PermissionFailure.cameraDenied) => true,
    PermissionAppFailure(type: PermissionFailure.microphoneDenied) => true,
    PermissionAppFailure(type: PermissionFailure.locationDenied) => true,
    PermissionAppFailure(type: PermissionFailure.notificationDenied) => true,
    LocationAppFailure(type: LocationFailure.permissionPermanentlyDenied) =>
      true,
    _ => false,
  };

  /// Категория для логирования / аналитики
  String get logCategory => switch (this) {
    NetworkAppFailure() => 'network',
    HttpAppFailure() => 'http',
    AuthAppFailure() => 'auth',
    ValidationAppFailure() => 'validation',
    StorageAppFailure() => 'storage',
    DatabaseAppFailure() => 'database',
    CacheAppFailure() => 'cache',
    ParseAppFailure() => 'parse',
    PermissionAppFailure() => 'permission',
    PlatformAppFailure() => 'platform',
    FileAppFailure() => 'file',
    LocationAppFailure() => 'location',
    NotificationAppFailure() => 'notification',
    PaymentAppFailure() => 'payment',
    SyncAppFailure() => 'sync',
    UnknownAppFailure() => 'unknown',
  };
}
