# AGENTS.md

## Layout

- Root: Flutter package `nexo` (UseCase layer, `Failure` model, Bloc/Cubit wrappers, Dio client/interceptors, data sources, logging).
- `lib/packages/` (`nexo_core`, `nexo_errors`, `nexo_logger`, `nexo_ui`) are logical modules inside one package — **not** separate pub packages. Do not split them out or restructure without an explicit request.
- `packages/nexo_cli/`: pure Dart CLI (feature scaffolding). Own pubspec — use `dart pub get / dart format . / dart analyze / dart test` there, never `flutter`.
- `example/`: sample app with path dependency on the root package. CI analyzes and tests it separately.

## Commands

CI (`.github/workflows/ci.yml`) runs all of these; match locally before pushing:

```bash
dart format lib test example/lib          # CI uses --set-exit-if-changed on exactly these paths
flutter analyze                           # root package
flutter test                              # root package
dart doc --validate-links lib             # broken doc links fail CI
cd example && flutter pub get && flutter analyze && flutter test
```

Single test file: `flutter test test/failure_code_test.dart`.

## Codegen & exports

- `Failure` is Freezed-generated; `failure.freezed.dart` is committed to git. After editing `failure.dart` or related types run:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
  and commit the regenerated files.
- Public API is exported manually via barrels `lib/nexo.dart`, `lib/nexo_core.dart`, `lib/nexo_errors.dart`, `lib/nexo_logger.dart`, `lib/nexo_ui.dart`. A new public file is invisible until added there.

## Gotchas

- **Web compatibility** (enforced since 0.0.4-beta.4): error mappers must not import `dart:io` directly — use conditional-import probes in `platform_exceptions.dart`. Switches over dio enums (`DioExceptionType`) must be exhaustive or dart2js builds break.
- Version bumps: update `version` in `pubspec.yaml` and add a matching `CHANGELOG.md` entry together.
- Isar 3 is tied to specific Flutter/Dart versions — check compatibility before bumping SDK constraints.
- `Failure.userMessage` defaults to Russian; English/custom text goes through `FailureUserMessageCatalog` + `localizedMessage`.
- Inside `NexoFlutterErrors.runAppInZone`, call `WidgetsFlutterBinding.ensureInitialized()` then `runApp` inside its body — otherwise Flutter reports a zone mismatch.
