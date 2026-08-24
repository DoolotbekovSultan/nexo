import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_testing.dart';

void main() {
  const failure = Failure.network(type: NetworkFailure.noInternet);
  const ok = Result<int>.success(42);
  final err = Result<int>.failure(failure);

  group('isSuccess', () {
    test('совпадает по ветке и значению', () {
      expect(ok, isSuccess<int>());
      expect(ok, isSuccess(42));
    });

    test('не совпадает с другим значением и с failure', () {
      expect(ok, isNot(isSuccess(43)));
      expect(err, isNot(isSuccess()));
    });
  });

  group('isFailure', () {
    test('совпадает по ветке и коду', () {
      expect(err, isFailure());
      expect(err, isFailure(code: 'network.no_internet'));
    });

    test('не совпадает с другим кодом и со success', () {
      expect(err, isNot(isFailure(code: 'http.unauthorized')));
      expect(ok, isNot(isFailure()));
    });
  });

  group('расширения', () {
    test('dataOrThrow возвращает значение при успехе', () {
      expect(ok.dataOrThrow(), 42);
    });

    test('dataOrThrow бросает StateError с кодом ошибки', () {
      expect(() => err.dataOrThrow(), throwsStateError);
    });

    test('failureOrThrow возвращает ошибку', () {
      expect(err.failureOrThrow(), failure);
    });

    test('failureOrThrow бросает StateError при успехе', () {
      expect(() => ok.failureOrThrow(), throwsStateError);
    });
  });

  group('failure-матчеры', () {
    test('failureWithCode', () {
      expect(failure, failureWithCode('network.no_internet'));
      expect(failure, isNot(failureWithCode('http.unauthorized')));
    });

    test('failureWithUserMessage', () {
      expect(failure, failureWithUserMessage('Нет подключения к интернету'));
      expect(failure, isNot(failureWithUserMessage('Другой текст')));
    });
  });
}
