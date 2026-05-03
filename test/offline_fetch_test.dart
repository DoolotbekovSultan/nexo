import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_core/network/offline_fetch.dart';

void main() {
  test('fetchCacheThenNetwork returns cache when hit', () async {
    final v = await fetchCacheThenNetwork(
      loadCache: () async => 1,
      loadNetwork: () async => fail('network should not run'),
    );
    expect(v, 1);
  });

  test(
    'fetchCacheThenNetwork loads network and saves when cache miss',
    () async {
    int? saved;
    final v = await fetchCacheThenNetwork(
      loadCache: () async => null,
      loadNetwork: () async => 42,
      saveCache: (x) async {
        saved = x;
      },
    );
    expect(v, 42);
    expect(saved, 42);
    },
  );

  test('fetchNetworkThenCache uses stale cache on failure', () async {
    final v = await fetchNetworkThenCache(
      loadNetwork: () async => throw Exception('net'),
      saveCache: (_) async {},
      onNetworkFailureLoadCache: () async => 'stale',
    );
    expect(v, 'stale');
  });
}
