import 'package:nexo_cli/nexo_cli.dart' as cli;
import 'package:test/test.dart';

void main() {
  group('runNexoCli feature', () {
    test('default: cubit on, exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--dry-run']), 0);
    });

    test('bloc: --bloc exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--bloc', '--dry-run']), 0);
    });

    test('cubit: --cubit exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--cubit', '--dry-run']), 0);
    });

    test('list-cubit: --list-cubit exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--list-cubit', '--dry-run']),
        0,
      );
    });

    test('both bloc and cubit: exits 64', () async {
      expect(await cli.run(['feature', 'auth', '--bloc', '--cubit']), 64);
    });

    test('--freezed: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--freezed', '--dry-run']), 0);
    });

    test('--no-freezed: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--no-freezed', '--dry-run']),
        0,
      );
    });

    test('--injectable: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--injectable', '--dry-run']),
        0,
      );
    });

    test('--no-injectable: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--no-injectable', '--dry-run']),
        0,
      );
    });

    test('--mapper: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--mapper', '--dry-run']), 0);
    });

    test('--mock: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--mock', '--dry-run']), 0);
    });

    test('--local: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--local', '--dry-run']), 0);
    });

    test('--preferences: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--preferences', '--dry-run']),
        0,
      );
    });

    test('--extensions: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--extensions', '--dry-run']),
        0,
      );
    });

    test('--ui: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--ui', '--dry-run']), 0);
    });

    test('--tests: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--tests', '--dry-run']), 0);
    });

    test('--presentation-only: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--presentation-only', '--dry-run']),
        0,
      );
    });

    test('--presentation-only with --bloc: exits 64', () async {
      expect(
        await cli.run(['feature', 'auth', '--presentation-only', '--bloc']),
        64,
      );
    });

    test('missing feature name exits 64', () async {
      expect(await cli.run(['feature']), 64);
    });

    // CRUD tests
    test('--get: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--get', '--dry-run']), 0);
    });

    test('--create: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--create', '--dry-run']), 0);
    });

    test('--update: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--update', '--dry-run']), 0);
    });

    test('--delete: exits 0', () async {
      expect(await cli.run(['feature', 'auth', '--delete', '--dry-run']), 0);
    });

    test('--get --create --update --delete: exits 0', () async {
      expect(
        await cli.run([
          'feature',
          'auth',
          '--get',
          '--create',
          '--update',
          '--delete',
          '--dry-run',
        ]),
        0,
      );
    });

    // JSON tests
    test('--json with valid JSON: exits 0', () async {
      expect(
        await cli.run([
          'feature',
          'auth',
          '--json',
          '{"id": "String", "name": "String"}',
          '--dry-run',
        ]),
        0,
      );
    });

    test('--json with invalid JSON: exits 64', () async {
      expect(
        await cli.run(['feature', 'auth', '--json', 'not-json', '--dry-run']),
        64,
      );
    });

    // List/single tests
    test('--list true: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--list', 'true', '--dry-run']),
        0,
      );
    });

    test('--list false: exits 0', () async {
      expect(
        await cli.run(['feature', 'auth', '--list', 'false', '--dry-run']),
        0,
      );
    });

    test('all options combined: exits 0', () async {
      expect(
        await cli.run([
          'feature',
          'auth',
          '--bloc',
          '--freezed',
          '--injectable',
          '--mapper',
          '--mock',
          '--local',
          '--preferences',
          '--extensions',
          '--ui',
          '--tests',
          '--get',
          '--create',
          '--update',
          '--delete',
          '--list',
          'true',
          '--dry-run',
        ]),
        0,
      );
    });

    test('--root exits 0', () async {
      expect(
        await cli.run([
          'feature',
          'auth',
          '--root',
          'lib/presentation',
          '--dry-run',
        ]),
        0,
      );
    });
  });
}
