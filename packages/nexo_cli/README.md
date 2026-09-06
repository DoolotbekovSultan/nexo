# nexo_cli

**CLI generator for Nexo-based Clean Architecture in Flutter apps.**

`nexo_cli` scaffolds feature modules with `data`, `domain`, and `presentation` layers wired to [Nexo](https://pub.dev/packages/nexo) patterns. Run it from the root of a Flutter app that already depends on `package:nexo`.

---

## Installation

```bash
dart pub global activate nexo_cli
```

Verify:

```bash
nexo_cli --help
```

---

## Quick Start

```bash
# From your Flutter app root
nexo_cli feature auth --get --create --list true
```

This creates `lib/features/auth/` with Cubit, datasource, repository, use case, and screen.

---

## Features

- **4 presentation styles:** `--bloc`, `--cubit` (default), `--list-cubit`, `--presentation-only`
- **CRUD operations:** `--get`, `--create`, `--update`, `--delete`
- **JSON model generation:** `--json '{"id": "String", "name": "String"}'`
- **Freezed support:** `--freezed` (default: on)
- **Injectable DI:** `--injectable` (default: on)
- **Mapper generation:** `--mapper` (default: on)
- **Mock datasources:** `--mock` (default: on)
- **List vs single:** `--list true/false`
- **Custom output directory:** `--root` (default: `lib/features`)
- **Stream use cases:** `--stream` (generates `NexoStreamUseCase` + `watchAll()`)
- **Stream only:** `--stream-only` (pure stream, no `getAll()`)
- **Pagination:** `--pagination` (generates `PaginationController`)
- **Optimistic updates:** `--optimistic` (generates cubit with `performOptimistic`)
- **Validators:** `--validators` (generates `NexoValidators` in params)
- **Get by ID:** `--get-by-id` (generates `GetByIdUseCase`)
- **Local storage:** `--local-storage <type>` (hive/shared-prefs/secure-storage)
- **Freezed fix:** `nexo fix` (patches freezed 3.x codegen bugs)

---

## Examples

```bash
# Simple GET list
nexo_cli feature products --get

# Single object
nexo_cli feature profile --get --list false

# Full CRUD with freezed
nexo_cli feature article --get --create --update --delete --freezed

# Model from JSON
nexo_cli feature product --get --json '{"id": "String", "name": "String", "price": "double"}'

# Presentation only
nexo_cli feature settings --presentation-only --preferences --ui

# NexoListCubit for simple lists
nexo_cli feature notification --list-cubit --get

# Everything combined
nexo_cli feature order --bloc --freezed --json '{"id": "String"}' --get --create --update --delete --tests

# Custom output directory
nexo_cli feature faq --get --root lib/presentation

# Stream use case for real-time data
nexo_cli feature messages --stream --injectable --freezed

# Stream only (no getAll)
nexo_cli feature notifications --stream-only --injectable

# Pagination with stream
nexo_cli feature events --pagination --stream --injectable --freezed

# Optimistic updates
nexo_cli feature cart --get --create --update --delete --optimistic --injectable

# Form validation
nexo_cli feature auth --create --validators --injectable

# Local storage with Hive
nexo_cli feature cache --get --local-storage hive --injectable

# Local storage with SharedPreferences
nexo_cli feature settings --get --local-storage shared-prefs --injectable

# Local storage with SecureStorage
nexo_cli feature tokens --get --local-storage secure-storage --injectable

# Get by ID
nexo_cli feature user --get --get-by-id --injectable

# Fix freezed codegen issues
nexo_cli fix
```

---

## Command-line Options

| Flag | Default | Description |
|------|---------|-------------|
| `--bloc` | off | Generate Bloc with events/states |
| `--cubit` | on* | Generate Cubit with state |
| `--list-cubit` | off | Generate NexoListCubit |
| `--async-cubit` | off | Generate NexoAsyncCubit with fetch() |
| `--presentation-only` | off | Only presentation layer |
| `--freezed` / `--no-freezed` | on | Use @freezed |
| `--injectable` / `--no-injectable` | on | Use @injectable |
| `--mapper` / `--no-mapper` | on | Generate mappers |
| `--mock` / `--no-mock` | on | Generate mock datasources |
| `--get` | off | Generate GET use case |
| `--create` | off | Generate CREATE use case + request DTO |
| `--update` | off | Generate UPDATE use case + request DTO |
| `--delete` | off | Generate DELETE use case |
| `--get-by-id` | off | Generate GetByIdUseCase |
| `--json '{...}'` | - | Generate model from JSON fields |
| `--list true/false` | true | List vs single object |
| `--local` | off | Include local datasource |
| `--local-storage <type>` | - | Storage backend: hive, shared-prefs, secure-storage |
| `--stream` | off | Generate NexoStreamUseCase + watchAll() |
| `--stream-only` | off | Pure stream (no getAll) |
| `--pagination` | off | Generate PaginationController |
| `--optimistic` | off | Generate cubit with performOptimistic |
| `--validators` | off | Generate NexoValidators in params |
| `--preferences` | off | Generate preferences wrapper |
| `--extensions` | off | Generate entity extensions |
| `--ui` | off | Generate pages/ and widgets/ |
| `--tests` | off | Generate test files |
| `--dry-run` (`-n`) | off | Preview without writing |
| `--overwrite` | off | Overwrite existing files |
| `--root` | `lib/features` | Base output directory |

*cubit is default when no style is specified.

---

## Generated Structure

```
lib/features/<name>/
├── data/
│   ├── datasources/     # interfaces, impl, mock
│   ├── models/          # model + requests/
│   ├── mappers/         # extension toDomain()
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/    # interface
│   ├── usecases/
│   └── parameters/
└── presentation/
    ├── bloc/ or cubit/
    └── <name>_screen.dart
```

---

## Documentation

See [DOCUMENTATION.md](DOCUMENTATION.md) for the complete guide with:

- All flags and options
- Architecture explanation
- JSON field generation
- CRUD operations
- Code templates
- Post-generation steps
- FAQ

---

## Development

```bash
dart pub get
dart format .
dart analyze
dart test
```

---

## License

See [LICENSE](LICENSE).
