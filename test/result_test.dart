import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';

void main() {
  const failure = Failure.network(type: NetworkFailure.noInternet);
  const Result<int> ok = Right(42);
  final Result<int> err = Left(failure);

  group('тип ветки и доступ к содержимому', () {
    test('Right хранит значение', () {
      expect(ok.isSuccess, isTrue);
      expect(ok.isFailure, isFalse);
      expect(ok.dataOrNull, 42);
      expect(ok.failureOrNull, isNull);
    });

    test('Left хранит ошибку', () {
      expect(err.isFailure, isTrue);
      expect(err.isSuccess, isFalse);
      expect(err.failureOrNull, failure);
      expect(err.dataOrNull, isNull);
    });
  });

  group('fold с именованными колбэками', () {
    test('Right уходит в onSuccess', () {
      final s = ok.fold(onFailure: (_) => 'f', onSuccess: (v) => 'v$v');
      expect(s, 'v42');
    });

    test('Left уходит в onFailure', () {
      final s = err.fold(
        onFailure: (f) => 'f:${f.code}',
        onSuccess: (v) => 'v$v',
      );
      expect(s, 'f:network.no_internet');
    });
  });

  group('map', () {
    test('преобразует значение при успехе', () {
      expect(ok.map((v) => v * 2), const Right(84));
    });

    test('проносит ошибку насквозь', () {
      final mapped = err.map((v) => v * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.failureOrNull, failure);
    });
  });

  test('getOrElse возвращает значение или fallback', () {
    expect(ok.getOrElse((_) => -1), 42);
    expect(err.getOrElse((_) => -1), -1);
  });

  group('value-equality', () {
    test('одинаковые Right равны', () {
      expect(ok, const Right(42));
      expect(ok.hashCode, const Right(42).hashCode);
    });

    test('одинаковые Left равны', () {
      expect(err, Left(failure));
      expect(err.hashCode, Left(failure).hashCode);
    });

    test('разные значения/ветки не равны', () {
      expect(ok == const Right(43), isFalse);
      expect(ok == err, isFalse);
    });

    test('равенство не зависит от типа-параметра (как у dartz)', () {
      expect(const Right(42), const Right<num>(42));
      expect(const Right(42).hashCode, const Right<num>(42).hashCode);
    });

    test('фабрики-алиасы эквивалентны классам', () {
      expect(const Result<int>.success(42), const Right(42));
      expect(const Result<int>.failure(failure), Left(failure));
    });
  });

  test('исчерпывающий паттерн-матчинг по sealed-классу', () {
    String describe(Result<int> r) => switch (r) {
      Right(:final value) => 'ok:$value',
      Left(:final failure) => 'err:${failure.code}',
    };

    expect(describe(ok), 'ok:42');
    expect(describe(err), 'err:network.no_internet');
  });

  test('toString удобен для логов', () {
    expect('$ok', 'Right(42)');
    expect('${err.map((_) => "не должно выполниться")}', startsWith('Left('));
  });
}
