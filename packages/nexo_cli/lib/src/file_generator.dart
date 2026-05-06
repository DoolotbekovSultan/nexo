import 'dart:io';

typedef FileGeneratorLog = void Function(String message);

/// Creates parent directories and empty files from a list of absolute or
/// normalized file paths (e.g. paths built from [FeaturePlan] relatives).
final class FileGenerator {
  FileGenerator({FileGeneratorLog? log}) : _log = log ?? stdout.writeln;

  final FileGeneratorLog _log;

  /// For each path: ensures parent dirs exist, then creates an empty file
  /// (or skips / dry-run per flags).
  Future<void> generate(
    Iterable<String> filePaths, {
    required bool dryRun,
    required bool overwrite,
  }) async {
    for (final raw in filePaths) {
      final normalized = File(raw).absolute.path;
      final file = File(normalized);
      final exists = await file.exists();

      if (dryRun) {
        if (!exists || overwrite) {
          _log('would create: $normalized');
        } else {
          _log('skipped: $normalized');
        }
        continue;
      }

      if (exists && !overwrite) {
        _log('skipped: $normalized');
        continue;
      }

      await file.parent.create(recursive: true);
      await file.writeAsString('');
      _log('created: $normalized');
    }
  }
}
