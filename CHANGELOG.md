# Changelog

## 0.0.4-beta.4

- **Web-совместимость `nexo_errors`**: мапперы больше не импортируют `dart:io` напрямую.
  Новые probe-хелперы (`platform_exceptions.dart`) через conditional imports определяют
  `SocketException` / `HandshakeException` / `TlsException` / `HttpException` /
  `FileSystemException` на VM и возвращают «не совпадает» на вебе, где эти типы недоступны.
- **`DioFailureMapper`**: добавлен кейс `DioExceptionType.transformTimeout` (появился в dio 5.10;
  dart2js требует исчерпывающий switch по enum — без кейса веб-сборка падала).
- Констрейнт dio поднят до `^5.10.0`.

## 0.0.4-beta.3

- Metadata refresh and republish for current stable Flutter/Dart compatibility.
- Includes recent core, error handling, and CLI generator improvements.

## 0.0.4-beta.2

- Документация и примеры: `WidgetsFlutterBinding.ensureInitialized` и `runApp` должны вызываться **внутри** тела [`runAppInZone`](lib/packages/nexo_errors/nexo_flutter_errors.dart), иначе Flutter сообщает о zone mismatch.

## 0.0.4-beta.1

- Добавлен [`NexoFlutterErrors`](lib/packages/nexo_errors/nexo_flutter_errors.dart): глобальные `FlutterError.onError`, `PlatformDispatcher.instance.onError`, опционально зона через `runAppInZone`; интеграция с `NexoLogger` и `NexoCrashReporter` (без UI).
- [`NexoBlocObserver`](lib/packages/nexo_core/bloc/nexo_bloc_observer.dart): опциональный `crashReporter` для дублирования ошибок BLoC в отчётность.
- Добавлен [`CollectingNexoCrashReporter`](lib/packages/nexo_errors/collecting_nexo_crash_reporter.dart) для тестов.

## 0.0.3-beta.1

- Предыдущая публичная версия.
