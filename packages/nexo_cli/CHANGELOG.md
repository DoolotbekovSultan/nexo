# Changelog

## 0.1.0

- Initial release.
- `feature` command: scaffold Clean Architecture layout under `lib/features/<name>/`.
- Templates for Bloc or Cubit, repository, use case, remote datasource, entity, and optional layers.
- Flags: `--bloc` / `--no-bloc`, `--cubit`, `--tests`, `--local`, `--ui`, `--dry-run`, `--overwrite`.
- `dart pub global activate` support via `nexo_cli` executable.
