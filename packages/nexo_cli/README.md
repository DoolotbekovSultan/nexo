# nexo_cli

**CLI generator for Nexo-based Clean Architecture in Flutter apps.**

`nexo_cli` scaffolds a feature module: `data`, `domain`, and `presentation` layers wired to [Nexo](https://pub.dev/packages/nexo) patterns (`NexoBloc` / `NexoCubit`, `NexoUseCase`, `NexoAsyncState`, `Result`, `BaseRemoteDataSource`, and related types). Run it from the root of a Flutter app that already depends on `package:nexo`.

---

## Installation

```bash
dart pub global activate nexo_cli
```

Ensure the pub cache `bin` directory is on your `PATH` (the `dart pub global` output shows the path to add).

Verify:

```bash
nexo_cli --help
```

---

## Usage

From your **Flutter app root** (where `lib/` and `pubspec.yaml` live):

```bash
nexo_cli feature <feature_name> [options]
```

Example:

```bash
nexo_cli feature auth
```

This creates `lib/features/auth/` with the default stack (**Bloc** on, **Cubit** off), remote datasource, repository, use case, and presentation files. With `--tests`, matching files are added under `test/features/auth/`.

---

## Examples

```bash
# Default: Bloc presentation, no tests folder in plan unless --tests
nexo_cli feature auth

# Cubit instead of Bloc (mutually exclusive with default Bloc)
nexo_cli feature auth --no-bloc --cubit

# User profile with Cubit and test stubs
nexo_cli feature user_profile --no-bloc --cubit --tests

# Bloc + local datasource + UI placeholders + tests
nexo_cli feature checkout --local --ui --tests

# Preview paths without writing files
nexo_cli feature auth --dry-run

# Overwrite existing generated files
nexo_cli feature auth --overwrite
```

---

## Command-line options

| Flag | Default | Description |
|------|---------|-------------|
| `--bloc` / `--no-bloc` | Bloc **on** | Generate Bloc files under `presentation/bloc/`. |
| `--cubit` / `--no-cubit` | Cubit **off** | Generate Cubit files under `presentation/cubit/`. |
| `--tests` | off | Add planned files under `test/features/<name>/`. |
| `--local` | off | Include a local datasource file in `data/datasources/`. |
| `--ui` | off | Include `presentation/pages/` and `presentation/widgets/` stubs. |
| `--dry-run` (`-n`) | off | Print what would be created; **no** files written. |
| `--overwrite` | off | Replace existing files; without it, existing files are **skipped**. |

**Presentation:** exactly one of Bloc or Cubit must be enabled. Default is Bloc only; use `--no-bloc --cubit` for Cubit-only.

---

## Generated feature layout (example)

For `nexo_cli feature auth` (Bloc, no `--local`, no `--ui`, no `--tests`), paths are relative to `lib/features/auth/`:

```text
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── auth_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── get_auth_usecase.dart
└── presentation/
    └── bloc/
        ├── auth_bloc.dart
        ├── auth_event.dart
        └── auth_state.dart
```

With `--tests`, analogous files appear under `test/features/auth/` (repository, use case, bloc/cubit tests as planned).

---

## Clean Architecture (short)

- **Domain:** entities and repository contracts; use cases orchestrate business rules.
- **Data:** repository implementations and datasources (remote/local) map APIs or storage to domain models.
- **Presentation:** Bloc or Cubit reacts to user events and drives UI state (here aligned with `NexoAsyncState` patterns).

The generator gives you a consistent folder layout and starter types so you can focus on real endpoints and UI.

---

## Sample generated Cubit (excerpt)

After `nexo_cli feature auth --no-bloc --cubit`, the Cubit extends `NexoCubit<AuthState>` with `AuthState` as `NexoAsyncState<AuthEntity>`, injects `GetAuthUseCase` and `NexoLogger`, and exposes a minimal `load()` calling `executeEither<AuthEntity>(...)`. Imports use `package:nexo/nexo_core.dart`, `package:nexo/nexo_errors.dart`, and `package:nexo/nexo_logger.dart` as in the templates.

Bloc mode is analogous: `NexoBloc<AuthEvent, AuthState>`, sealed events (e.g. `LoadAuth`), and `on<LoadAuth>` handling.

---

## Development

From this package directory (`packages/nexo_cli` in the monorepo, or your clone root):

```bash
dart pub get
dart format .
dart analyze
dart test
```

### Before publishing to pub.dev

1. Replace `repository` / `homepage` in `pubspec.yaml` with your real Git URL (currently placeholders).
2. Run `dart format .`, `dart analyze`, and `dart test` with a clean checkout.
3. Follow [Publishing a package](https://dart.dev/tools/pub/publishing): `dart pub publish --dry-run`, then `dart pub publish` when satisfied.

---

## License

See [LICENSE](LICENSE).
