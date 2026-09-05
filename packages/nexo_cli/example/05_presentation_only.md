# Example 5: Presentation-Only Feature

Minimal feature with only presentation layer.

## Command

```bash
nexo_cli feature settings --presentation-only --preferences --ui
```

## Generated Structure

```
lib/features/settings/
├── data/
│   └── settings_preferences.dart
└── presentation/
    ├── settings_screen.dart
    ├── pages/
    │   └── settings_page.dart
    └── widgets/
        └── settings_widget.dart
```

## What's Generated

- **Preferences**: `SettingsPreferences` with `SharedPreferences` wrapper
- **Screen**: `StatefulWidget` for the main screen
- **Page**: `StatelessWidget` page layout
- **Widget**: `StatelessWidget` reusable component

No data/domain layers are generated.
