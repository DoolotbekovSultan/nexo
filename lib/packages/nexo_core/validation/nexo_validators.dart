import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/types/validation_failure.dart';

/// Валидатор поля формы: текст ошибки либо `null`, если значение корректно.
///
/// Совместим с `TextFormField.validator`.
typedef NexoValidator<T> = String? Function(T value);

/// Готовые валидаторы для форм.
///
/// По умолчанию тексты ошибок строятся через [Failure.userMessage] и
/// локализуются каталогом сообщений пакета; [String] параметр `fieldName`
/// подставляется в сообщение («Поле «Email» обязательно»). Любое правило
/// можно переопределить целиком параметром `message`.
///
/// Семантика: кроме [requiredField] пустые значения считаются валидными —
/// необязательные поля можно валидировать одним правилом, обязательные
/// собирайте цепочкой:
///
/// ```dart
/// TextFormField(
///   decoration: const InputDecoration(labelText: 'Email'),
///   validator: NexoValidators.compose([
///     NexoValidators.requiredField(fieldName: 'Email'),
///     NexoValidators.email(message: 'Проверьте адрес почты'),
///   ]),
/// )
/// ```
abstract final class NexoValidators {
  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _phoneRegExp = RegExp(r'^\+?[0-9\s\-()]{7,20}$');

  /// Значение не должно быть пустым или состоять из одних пробелов.
  static NexoValidator<String> requiredField({
    String? fieldName,
    String? message,
  }) => (value) {
    if (value.trim().isNotEmpty) return null;
    return message ??
        _message(ValidationFailure.requiredField, field: fieldName);
  };

  /// Email-адрес; пустое значение пропускает.
  static NexoValidator<String> email({String? fieldName, String? message}) =>
      (value) {
        if (value.trim().isEmpty) return null;
        if (_emailRegExp.hasMatch(value.trim())) return null;
        return message ??
            _message(ValidationFailure.invalidEmail, field: fieldName);
      };

  /// Телефон: цифры, ведущий `+`, скобки, дефисы и пробелы; пустое пропускает.
  static NexoValidator<String> phone({String? fieldName, String? message}) =>
      (value) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null;
        if (_phoneRegExp.hasMatch(trimmed)) return null;
        return message ??
            _message(ValidationFailure.invalidPhone, field: fieldName);
      };

  /// URL со схемой `http` / `https`; пустое значение пропускает.
  static NexoValidator<String> url({String? fieldName, String? message}) =>
      (value) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null;

        final uri = Uri.tryParse(trimmed);
        final valid =
            uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
        if (valid) return null;

        return message ??
            _message(ValidationFailure.invalidUrl, field: fieldName);
      };

  /// Число (целое или дробное); пустое значение пропускает.
  static NexoValidator<String> number({String? fieldName, String? message}) =>
      (value) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null;
        if (num.tryParse(trimmed.replaceFirst(',', '.')) != null) return null;
        return message ??
            _message(ValidationFailure.invalidNumber, field: fieldName);
      };

  /// Минимальная длина; пустое значение пропускает.
  static NexoValidator<String> minLength(
    int min, {
    String? fieldName,
    String? message,
  }) => (value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length >= min) return null;
    return message ?? _message(ValidationFailure.tooShort, field: fieldName);
  };

  /// Максимальная длина; пустое значение пропускает.
  static NexoValidator<String> maxLength(
    int max, {
    String? fieldName,
    String? message,
  }) => (value) {
    if (value.trim().length <= max) return null;
    return message ?? _message(ValidationFailure.tooLong, field: fieldName);
  };

  /// Пароль: минимальная длина и состав (буквы / цифры); пустое пропускает.
  ///
  /// Сначала проверяется длина ([ValidationFailure.tooShort]), затем
  /// состав ([ValidationFailure.passwordTooWeak]); `message` заменяет
  /// оба текста.
  static NexoValidator<String> password({
    int minLength = 8,
    bool requireLetter = true,
    bool requireDigit = true,
    String? fieldName,
    String? message,
  }) => (value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final effectiveField = fieldName ?? 'Пароль';

    if (trimmed.length < minLength) {
      return message ??
          _message(ValidationFailure.tooShort, field: effectiveField);
    }

    final hasLetter = trimmed.contains(RegExp(r'[A-Za-zА-Яа-яЁё]'));
    final hasDigit = trimmed.contains(RegExp(r'\d'));

    final strong = (!requireLetter || hasLetter) && (!requireDigit || hasDigit);
    if (strong) return null;

    return message ??
        _message(ValidationFailure.passwordTooWeak, field: effectiveField);
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
