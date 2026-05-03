import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_core/state/nexo_async_state.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';

void main() {
  test('NexoAsyncState flags and dataOrNull', () {
    const idle = NexoAsyncIdle<int>();
    expect(idle.isIdle, isTrue);
    expect(idle.dataOrNull, isNull);

    const loading = NexoAsyncLoading<int>();
    expect(loading.isLoading, isTrue);

    const ok = NexoAsyncSuccess(7);
    expect(ok.isSuccess, isTrue);
    expect(ok.dataOrNull, 7);

    const fail = NexoAsyncFailure<int>(
      Failure.network(type: NetworkFailure.noInternet),
    );
    expect(fail.isFailure, isTrue);
    expect(fail.failureOrNull?.code, 'network.no_internet');
  });
}
