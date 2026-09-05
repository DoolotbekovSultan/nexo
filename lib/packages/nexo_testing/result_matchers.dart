import 'package:matcher/matcher.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

/// Метка «ожидаемое значение не задано».
const Object _unset = Object();

/// Матчер: результат успешен; с [expectedValue] — ещё и содержит это значение.
///
/// ```dart
/// expect(result, isSuccess());
/// expect(result, isSuccess(42));
/// ```
Matcher isSuccess<T>([Object? expectedValue = _unset]) {
  final matcher = isA<Right<T>>();
  if (identical(expectedValue, _unset)) return matcher;
  return matcher.having((r) => r.value, 'value', expectedValue);
}

/// Матчер: результат неудачен; с [code] — ещё и с таким стабильным кодом ошибки.
///
/// ```dart
/// expect(result, isFailure(code: 'network.no_internet'));
/// ```
Matcher isFailure({String? code}) {
  final matcher = isA<Left<dynamic>>();
  if (code == null) return matcher;
  return matcher.having((r) => r.failure.code, 'failure.code', code);
}

/// Расширение для удобного извлечения данных из [Result] в тестах.
///
/// Если результат не соответствует ожиданию, выбрасывает [StateError]
/// с информативным сообщением.
extension ResultTestExpectationsX<T> on Result<T> {
  /// Значение успеха; иначе [StateError] с кодом и сообщением ошибки.
  T dataOrThrow() => switch (this) {
    Right<T>(:final value) => value,
    Left<T>(:final failure) => throw StateError(
      'Ожидался успех, получен Left (${failure.code}): ${failure.userMessage}',
    ),
  };

  /// Ошибка неудачи; иначе [StateError] со значением успеха.
  Failure failureOrThrow() => switch (this) {
    Left<T>(:final failure) => failure,
    Right<T>(:final value) => throw StateError(
      'Ожидался Left, получен Right ($value)',
    ),
  };
}
