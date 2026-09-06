import 'package:nexo_cli/nexo_cli.dart' as cli;
import 'package:test/test.dart';

void main() {
  group('runNexoCli init', () {
    test('default: exits 0 with dry-run', () async {
      expect(await cli.run(['init', '--dry-run']), 0);
    });

    test('--name: exits 0', () async {
      expect(await cli.run(['init', '--name', 'CoolApp', '--dry-run']), 0);
    });

    test('--routing none: exits 0', () async {
      expect(await cli.run(['init', '--routing', 'none', '--dry-run']), 0);
    });

    test('--routing auto_route: exits 0', () async {
      expect(
        await cli.run(['init', '--routing', 'auto_route', '--dry-run']),
        0,
      );
    });

    test('--routing go_router: exits 0', () async {
      expect(await cli.run(['init', '--routing', 'go_router', '--dry-run']), 0);
    });

    test('--mock: exits 0', () async {
      expect(await cli.run(['init', '--mock', '--dry-run']), 0);
    });

    test('--prod: exits 0', () async {
      expect(await cli.run(['init', '--prod', '--dry-run']), 0);
    });

    test('--sentry: exits 0', () async {
      expect(await cli.run(['init', '--sentry', '--dry-run']), 0);
    });

    test('--overwrite: exits 0', () async {
      expect(await cli.run(['init', '--overwrite', '--dry-run']), 0);
    });

    test('all options combined: exits 0', () async {
      expect(
        await cli.run([
          'init',
          '--name',
          'SuperApp',
          '--routing',
          'auto_route',
          '--prod',
          '--sentry',
          '--overwrite',
          '--dry-run',
        ]),
        0,
      );
    });

    test('help exits 0', () async {
      expect(await cli.run(['init', '--help']), 0);
    });
  });
}
