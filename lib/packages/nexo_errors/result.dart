import 'package:nexo/packages/nexo_errors/failure.dart';

/// Иммутабельный результат операции: успех со значением типа [T] либо [Failure].
///
/// Собственный sealed-тип вместо `Either` из dartz: те же короткие имена
/// [Right] / [Left], но работает исчерпывающий паттерн-матчинг и [Result.fold]
/// принимает именованные колбэки.
///
/// ```dart
/// final text = switch (result) {
///   Right(:final value) => 'Данные: $value',
///   Left(:final failure) => failure.userMessage,
/// };
/// ```
sealed class Result<T> {
  const Result();

  /// Успешная ветка — алиас класса [Right].
  const factory Result.success(T value) = Right<T>;

  /// Неудачная ветка — алиас класса [Left].
  const factory Result.failure(Failure failure) = Left<T>;

  bool get isSuccess => this is Right<T>;

  bool get isFailure => this is Left<T>;

  /// Значение при успехе, иначе `null`.
  T? get dataOrNull => switch (this) {
    Right<T>(:final value) => value,
    _ => null,
  };

  /// Ошибка при неудаче, иначе `null`.
  Failure? get failureOrNull => switch (this) {
    Left<T>(:final failure) => failure,
    _ => null,
  };

  /// Разворачивает результат в одно значение.
  ///
  /// ```dart
  /// final message = result.fold(
  ///   onFailure: (f) => f.userMessage,
  ///   onSuccess: (data) => 'Загружено: $data',
  /// );
  /// ```
  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T value) onSuccess,
  }) => switch (this) {
    Left<T>(:final failure) => onFailure(failure),
    Right<T>(:final value) => onSuccess(value),
  };

  /// Преобразует значение при успехе; ошибка проходит насквозь без изменений.
  Result<R> map<R>(R Function(T value) mapper) => switch (this) {
    Right<T>(:final value) => Result<R>.success(mapper(value)),
    Left<T>(:final failure) => Result<R>.failure(failure),
  };

  /// Значение при успехе, иначе результат [orElse] над ошибкой.
  T getOrElse(T Function(Failure failure) orElse) => switch (this) {
    Right<T>(:final value) => value,
    Left<T>(:final failure) => orElse(failure),
  };

  @override
  String toString() => switch (this) {
    Right<T>(:final value) => 'Right($value)',
    Left<T>(:final failure) => 'Left($failure)',
  };
}

/// Успешная ветка [Result]; создаётся через `Right(value)` или `Result.success(value)`.
final class Right<T> extends Result<T> {
  const Right(this.value);

  /// Данные успеха.
  final T value;

  @override
  bool operator ==(Object other) => other is Right && other.value == value;

  @override
  int get hashCode => Object.hash(Right, value);
}

/// Неудачная ветка [Result]; создаётся через `Left(failure)` или `Result.failure(failure)`.
final class Left<T> extends Result<T> {
  const Left(this.failure);

  /// Ошибка неудачи.
  final Failure failure;

  @override
  bool operator ==(Object other) => other is Left && other.failure == failure;

  @override
  int get hashCode => Object.hash(Left, failure);
}

/// Поток результатов с тем же смыслом, что и [Result].
typedef StreamResult<T> = Stream<Result<T>>;
