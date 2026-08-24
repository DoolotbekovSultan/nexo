import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/types/validation_failure.dart';

/// Валидатор поля формы: текст ошибки либо `null`, если значение корректно.
///
/// Совместим с `TextFormField.validator`.
typedef NexoValidator<T> = String? Function(T value);

/// Готовые валидаторы для форм.
///
/// Тексты ошибок строятся через [Failure.userMessage], поэтому локализуются
/// тем же каталогом, что и весь пакет; [String] параметр `fieldName`
/// подставляется в сообщение («Поле «Email» обязательно»).
///
/// Семантика: кроме [requiredField] пустые значения считаются валидными —
/// необязательные поля можно валидировать одним правилом, обязательные
/// собирайте цепочкой:
///
/// ```dart
/// TextFormField(
///   decoration: const InputDecoration(labelText: 'Email'),
///   validator: NexoValidators.compose([
///     NexoValidators.requiredField('Email'),
///     NexoValidators.email(),
///   ]),
/// )
/// ```
abstract final class NexoValidators {
  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _phoneRegExp = RegExp(r'^\+?[0-9\s\-()]{7,20}$');

  /// Значение не должно быть пустым или состоять из одних пробелов.
  static NexoValidator<String> requiredField([String? fieldName]) =>
      (value) => value.trim().isEmpty
      ? _message(ValidationFailure.requiredField, field: fieldName)
      : null;

  /// Email-адрес; пустое значение пропускает.
  static NexoValidator<String> email([String? fieldName]) => (value) {
    if (value.trim().isEmpty) return null;
    return _emailRegExp.hasMatch(value.trim())
        ? null
        : _message(ValidationFailure.invalidEmail, field: fieldName);
  };

  /// Телефон: цифры, ведущий `+`, скобки, дефисы и пробелы; пустое пропускает.
  static NexoValidator<String> phone([String? fieldName]) => (value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return _phoneRegExp.hasMatch(trimmed)
        ? null
        : _message(ValidationFailure.invalidPhone, field: fieldName);
  };

  /// URL со схемой `http` / `https`; пустое значение пропускает.
  static NexoValidator<String> url([String? fieldName]) => (value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    final valid =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    return valid
        ? null
        : _message(ValidationFailure.invalidUrl, field: fieldName);
  };

  /// Число (целое или дробное); пустое значение пропускает.
  static NexoValidator<String> number([String? fieldName]) => (value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return num.tryParse(trimmed.replaceFirst(',', '.')) != null
        ? null
        : _message(ValidationFailure.invalidNumber, field: fieldName);
  };

  /// Минимальная длина; пустое значение пропускает.
  static NexoValidator<String> minLength(int min, [String? fieldName]) =>
      (value) => value.trim().isEmpty || value.trim().length >= min
      ? null
      : _message(ValidationFailure.tooShort, field: fieldName);

  /// Максимальная длина; пустое значение пропускает.
  static NexoValidator<String> maxLength(int max, [String? fieldName]) =>
      (value) => value.trim().length <= max
      ? null
      : _message(ValidationFailure.tooLong, field: fieldName);

  /// Пароль: минимальная длина и состав (буквы / цифры); пустое пропускает.
  ///
  /// Сначала проверяется длина ([ValidationFailure.tooShort]), затем
  /// состав ([ValidationFailure.passwordTooWeak]).
  static NexoValidator<String> password({
    int minLength = 8,
    bool requireLetter = true,
    bool requireDigit = true,
    String? fieldName,
  }) => (value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.length < minLength) {
      return _message(ValidationFailure.tooShort, field: fieldName ?? 'Пароль');
    }

    final hasLetter = trimmed.contains(RegExp(r'[A-Za-zА-Яа-яЁё]'));
    final hasDigit = trimmed.contains(RegExp(r'\d'));

    final strong = (!requireLetter || hasLetter) && (!requireDigit || hasDigit);
    return strong
        ? null
        : _message(ValidationFailure.passwordTooWeak, field: fieldName);
  };

  /// Композитор: применяет правила по очереди и возвращает первую ошибку.
  static NexoValidator<T> compose<T>(List<NexoValidator<T>> validators) =>
      (value) {
        for (final validator in validators) {
          final error = validator(value);
          if (error != null) return error;
        }
        return null;
      };

  static String _message(ValidationFailure type, {String? field}) =>
      Failure.validation(type: type, field: field).userMessage;
}
