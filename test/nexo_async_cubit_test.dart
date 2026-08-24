import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';

class _InstantCubit extends NexoAsyncCubit<int> {
  _InstantCubit(this.resultFactory) {
    onFailure = failures.add;
  }

  final Result<int> Function() resultFactory;

  final failures = <Failure>[];

  @override
  Future<Result<int>> fetch() async => resultFactory();
}

class _ManualCubit extends NexoAsyncCubit<int> {
  final completers = <Completer<Result<int>>>[];

  @override
  Future<Result<int>> fetch() {
    final completer = Completer<Result<int>>();
    completers.add(completer);
    return completer.future;
  }
}

void main() {
  const failure = Failure.network(type: NetworkFailure.noInternet);

  test('начальное состояние — Idle', () {
    final cubit = _InstantCubit(() => const Right(1));
    expect(cubit.state.isIdle, isTrue);
  });

  test('load: Idle -> Loading -> Success', () async {
    final cubit = _InstantCubit(() => const Right(42));
    final states = <NexoAsyncState<int>>[];
    cubit.stream.listen(states.add);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states.length, 2);
    expect(states.first.isLoading, isTrue);
    expect(states.last.dataOrNull, 42);
  });

  test('load: ошибка -> Failure + колбэк onFailure', () async {
    final cubit = _InstantCubit(() => const Left(failure));
    final states = <NexoAsyncState<int>>[];
    cubit.stream.listen(states.add);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states.last.failureOrNull, failure);
    expect(cubit.failures, [failure]);
  });

  test('refresh без данных: без промежуточного Loading', () async {
    final cubit = _InstantCubit(() => const Right(7));
    final states = <NexoAsyncState<int>>[];
    cubit.stream.listen(states.add);

    await cubit.refresh();
    await Future<void>.delayed(Duration.zero);

    expect(states, hasLength(1));
    expect(states.single.dataOrNull, 7);
  });

  test('refresh с данными: данные подменяются без Loading', () async {
    var value = 1;
    final cubit = _InstantCubit(() => Right(value));
    await cubit.load();

    final states = <NexoAsyncState<int>>[];
    cubit.stream.listen(states.add);
    value = 2;

    await cubit.refresh();
    await Future<void>.delayed(Duration.zero);

    expect(states, hasLength(1));
    expect(states.single.dataOrNull, 2);
  });

  test('load после успеха снова показывает Loading', () async {
    final cubit = _InstantCubit(() => const Right(1));
    await cubit.load();

    final states = <NexoAsyncState<int>>[];
    cubit.stream.listen(states.add);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states.first.isLoading, isTrue);
  });

  test('retry после ошибки повторяет загрузку', () async {
    var shouldFail = true;
    final cubit = _InstantCubit(
      () => shouldFail ? const Left(failure) : const Right(9),
    );
    await cubit.load();
    shouldFail = false;

    await cubit.retry();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.dataOrNull, 9);
  });

  test('ответ устаревшего запроса игнорируется', () async {
    final cubit = _ManualCubit();
    final first = cubit.load();
    final second = cubit.load();

    cubit.completers[1].complete(const Right(2));
    await second;
    expect(cubit.state.dataOrNull, 2);

    cubit.completers[0].complete(const Right(1));
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state.dataOrNull,
      2,
      reason: 'первый запрос должен быть отброшен',
    );
  });

  test('fetch, бросивший исключение, превращается в unknown-Failure', () async {
    final cubit = _InstantCubit(() => throw StateError('boom'));

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isFailure, isTrue);
  });

  test('после close методы не бросают и состояние не меняется', () async {
    final cubit = _ManualCubit();
    final pending = cubit.load();
    await cubit.close();

    expect(() => cubit.load(), returnsNormally);

    cubit.completers.single.complete(const Right(1));
    await pending;

    expect(
      cubit.state.isLoading,
      isTrue,
      reason: 'после close новые состояния не эмитятся',
    );
  });
}
