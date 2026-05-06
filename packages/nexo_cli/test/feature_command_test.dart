import 'package:nexo_cli/nexo_cli.dart' as cli;
import 'package:test/test.dart';

void main() {
  group('runNexoCli feature', () {
    // Use --dry-run so tests do not write under packages/nexo_cli/lib|test.
    test('default: bloc on, cubit off, exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--dry-run']), 0);
    });

    test('cubit-only: --no-bloc --cubit exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--no-bloc', '--cubit', '--dry-run']),
        0,
      );
    });

    test('both bloc and cubit: exits 64', () async {
      expect(await cli.run(['feature', 'auth', '--cubit']), 64);
    });

    test('neither bloc nor cubit: exits 64', () async {
      expect(await cli.run(['feature', 'auth', '--no-bloc']), 64);
    });

    test('--local and --ui: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--local', '--ui', '--dry-run']),
        0,
      );
    });

    test('--tests: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--tests', '--dry-run']), 0);
    });

    test('missing feature name exits 64', () async {
      expect(await cli.run(['feature']), 64);
    });
  });
}
