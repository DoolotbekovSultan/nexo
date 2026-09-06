# Changelog

## 0.3.0

- **New `--stream` flag:** Generate `NexoStreamUseCase` with `watchAll()` repository method.
- **New `--stream-only` flag:** Pure stream use case without `getAll()`.
- **New `--pagination` flag:** Generate `PaginationController` for paginated lists.
- **New `--optimistic` flag:** Generate cubit with `performOptimistic` helper for optimistic updates.
- **New `--validators` flag:** Generate `NexoValidators` validation in create/update params.
- **New `--get-by-id` flag:** Generate `GetByIdUseCase` for fetching single entities.
- **New `--local-storage <type>` flag:** Generate real local datasource implementations:
  - `hive`: Hive box with JSON serialization
  - `shared-prefs`: SharedPreferences with JSON string storage
  - `secure-storage`: FlutterSecureStorage with encrypted storage
- **New `--async-cubit` flag:** Generate `NexoAsyncCubit` with `fetch()` pattern.
- **New `nexo fix` command:** Patch freezed 3.x codegen bugs (extraneous `final` modifier).
- Fixed angle brackets in doc comments (`NexoAsyncState<T>`, `Stream<Result<T>>`).
- Fixed unused `_repository` fields in stream and CRUD use case templates.
- Fixed unused `nexo_core.dart` import in test templates.
- 132 tests passing.

## 0.2.2

- New `--root` flag to customize output directory (default: `lib/features`).
- 91 tests passing.

## 0.2.1

- Fixed: repository template now adds `@Named('prod')` on constructor parameter when `--mock` is enabled (resolves injectable DI ambiguity).
- Fixed: repository template now imports mapper and calls `.toDomain()` only when `--mapper` is enabled.
- Fixed: `--no-mapper` mode generates `return const []` with a TODO comment instead of broken `.toDomain()` call.
- 90 tests passing.

## 0.2.0

- **Breaking:** cubit is now the default presentation style (was bloc).
- New `--bloc` / `--cubit` / `--list-cubit` flags for presentation style selection.
- New `--presentation-only` flag for UI-only features.
- New `--freezed` / `--no-freezed` flag (default: on).
- New `--injectable` / `--no-injectable` flag (default: on).
- New `--mapper` / `--no-mapper` flag (default: on).
- New `--mock` / `--no-mock` flag (default: on).
- New `--get` / `--create` / `--update` / `--delete` flags for CRUD operations.
- New `--json '{...}'` flag to generate model fields from JSON.
- New `--list true/false` flag for list vs single object.
- New `--preferences` flag for SharedPreferences wrapper.
- New `--extensions` flag for entity extensions.
- New `--ui` flag for pages and widgets.
- Interface-based datasource pattern (`i_remote_*`, `i_local_*`).
- Mock datasource generation with environment-conditional DI.
- Request DTOs for create/update operations.
- Domain parameters for use cases.
- Updated templates to match nexo patterns (easycoins, niet_media).
- Added comprehensive documentation (`DOCUMENTATION.md`).
- Added example features with real generated code.
- 88 tests passing.

## 0.1.0

- Initial release.
- `feature` command: scaffold Clean Architecture layout under `lib/features/<name>/`.
- Templates for Bloc or Cubit, repository, use case, remote datasource, entity, and optional layers.
- Flags: `--bloc` / `--no-bloc`, `--cubit`, `--tests`, `--local`, `--ui`, `--dry-run`, `--overwrite`.
- `dart pub global activate` support via `nexo_cli` executable.
