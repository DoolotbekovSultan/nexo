/// Normalizes feature CLI input (`auth`, `user_profile`, `UserProfile`) to
/// snake_case and PascalCase for paths and type names.
final class NameUtils {
  NameUtils._(this.rawInput);

  /// Trims [input] and builds derived names. [input] must be non-empty.
  factory NameUtils.fromFeatureInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        input,
        'input',
        'Feature name must not be empty',
      );
    }
    return NameUtils._(trimmed);
  }

  final String rawInput;

  /// Original trimmed input (e.g. `user_profile`, `UserProfile`).
  String get featureName => rawInput;

  /// Lowercase segments joined with `_` (e.g. `user_profile`).
  String get snakeCase => _wordsToSnake(_splitWords(rawInput));

  /// UpperCamelCase (e.g. `UserProfile`).
  String get pascalCase => _wordsToPascal(_splitWords(rawInput));

  /// Same as [pascalCase] (explicit alias for generated class names).
  String get upperCamelCase => pascalCase;
}

/// Splits `auth`, `user_profile`, `userProfile`, `UserProfile` into word tokens.
List<String> _splitWords(String input) {
  var s = input.trim().replaceAll(RegExp(r'\s+'), '').replaceAll('-', '_');
  s = s.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (m) => '${m[1]}_${m[2]}',
  );
  s = s.replaceAll(RegExp(r'_+'), '_');
  final parts = s.toLowerCase().split('_').where((w) => w.isNotEmpty).toList();
  if (parts.isEmpty) {
    throw ArgumentError.value(input, 'input', 'No valid name segments');
  }
  return parts;
}

String _wordsToSnake(List<String> words) => words.join('_');

String _wordsToPascal(List<String> words) {
  return words
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join();
}
