# NEXO Documentation

Modular Flutter toolkit for app architecture: error handling, logging, UI components, and utilities.

---

## Choose Language / Выберите язык

| | |
|---|---|
| [English](en/getting-started.md) | [Русский](ru/getting-started.md) |

---

## Modules

| Module | Purpose | Import |
|--------|---------|--------|
| **nexo_core** | Cubit/Bloc, UseCase, networking, data sources, validation | `package:nexo/nexo_core.dart` |
| **nexo_errors** | `Failure`, `Result`, error mappers, localization | `package:nexo/nexo_errors.dart` |
| **nexo_logger** | Logger abstraction + Talker adapter | `package:nexo/nexo_logger.dart` |
| **nexo_ui** | Ready-made widgets and extensions | `package:nexo/nexo_ui.dart` |
| **nexo_testing** | Test matchers | `package:nexo/nexo_testing.dart` |

Or import everything at once:
```dart
import 'package:nexo/nexo.dart';
```
