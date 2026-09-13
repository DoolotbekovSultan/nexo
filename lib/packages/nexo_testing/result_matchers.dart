import 'package:matcher/matcher.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

/// Метка «ожидаемое значение не задано».
const Object _unset = Object();

/// Матчер: результат успешен ([Right]); с [expectedValue] — ещё и содержит это значение.
///
/// ```dart
/// expect(result, isRight());
/// expect(result, isRight(42));
/// ```
Matcher isRight<T>([Object? expectedValue = _unset]) {
  final matcher = isA<Right<T>>();
  if (identical(expectedValue, _unset)) return matcher;
  return matcher.having((r) => r.value, 'value', expectedValue);
}

/// Матчер: результат неудачен ([Left]); с [code] — ещё и с таким стабильным кодом ошибки.
///
/// ```dart
/// expect(result, isLeft());
/// expect(result, isLeft(code: 'network.no_internet'));
/// ```
Matcher isLeft<T>({String? code}) {
  final matcher = isA<Left<T>>();
  if (code == null) return matcher;
  return matcher.having((r) => r.failure.code, 'failure.code', code);
}

/// Матчер: результат успешен; с [expectedValue] — ещё и содержит это значение.
///
/// ```dart
/// expect(result, isSuccess());
/// expect(result, isSuccess(42));
/// ```
Matcher isSuccess<T>([Object? expectedValue = _unset]) =>
    isRight<T>(expectedValue);

/// Матчер: результат неудачен; с [code] — ещё и с таким стабильным кодом ошибки.
///
/// ```dart
/// expect(result, isFailure(code: 'network.no_internet'));
/// ```
Matcher isFailure<T>({String? code}) => isLeft<T>(code: code);

/// Матчер: ошибка с ожидаемым стабильным кодом ([Failure.code]).
///
/// ```dart
/// expect(failure, hasFailureCode('http.unauthorized'));
/// ```
Matcher hasFailureCode(String code) =>
    isA<Failure>().having((f) => f.code, 'code', code);

/// Матчер: ошибка с ожидаемым типом.
///
/// ```dart
/// expect(failure, hasFailureType(NetworkAppFailure));
/// ```
Matcher hasFailureType(Type failureType) => isA<Failure>();

/// Матчер: ошибка с ожидаемым пользовательским сообщением ([Failure.userMessage]).
Matcher hasFailureMessage(String message) =>
    isA<Failure>().having((f) => f.userMessage, 'userMessage', message);

/// Матчер: содержит значение.
///
/// ```dart
/// expect(result, resultContains(42));
/// ```
Matcher resultContains<T>(T expected) => isRight<T>(expected);

/// Расширение для удобного извлечения данных из [Result] в тестах.
///
/// Если результат не соответствует ожиданию, выбрасывает [StateError]
/// с информативным сообщением.
extension ResultTestExpectationsX<T> on Result<T> {
  /// Значение успеха; иначе [StateError] с кодом и сообщением ошибки.
  ///
  /// ```dart
  /// final data = result.dataOrThrow();
  /// ```
  T dataOrThrow() => switch (this) {
    Right<T>(:final value) => value,
    Left<T>(:final failure) => throw StateError(
      'Ожидался успех, получен Left (${failure.code}): ${failure.userMessage}',
    ),
  };

  /// Ошибка неудачи; иначе [StateError] со значением успеха.
  ///
  /// ```dart
  /// final failure = result.failureOrThrow();
  /// ```
  Failure failureOrThrow() => switch (this) {
    Left<T>(:final failure) => failure,
    Right<T>(:final value) => throw StateError(
      'Ожидался Left, получен Right ($value)',
    ),
  };
}
