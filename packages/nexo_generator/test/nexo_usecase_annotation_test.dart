import 'package:test/test.dart';
import 'package:nexo_generator/nexo_generator.dart';

void main() {
  group('NexoUseCaseAnnotation', () {
    test('creates annotation with defaults', () {
      const annotation = NexoUseCaseAnnotation();
      expect(annotation.repo, isNull);
      expect(annotation.extraDeps, isEmpty);
    });

    test('creates annotation with repo', () {
      const annotation = NexoUseCaseAnnotation(repo: String);
      expect(annotation.repo, String);
      expect(annotation.extraDeps, isEmpty);
    });

    test('creates annotation with extraDeps', () {
      const annotation = NexoUseCaseAnnotation(extraDeps: [String, int]);
      expect(annotation.repo, isNull);
      expect(annotation.extraDeps, [String, int]);
    });

    test('creates annotation with repo and extraDeps', () {
      const annotation = NexoUseCaseAnnotation(repo: String, extraDeps: [int]);
      expect(annotation.repo, String);
      expect(annotation.extraDeps, [int]);
    });
  });
}
