/// Code generator for nexo package.
///
/// Генерирует реализации UseCase из аннотаций [@NexoUseCaseAnnotation].
///
/// ## Использование
///
/// 1. Добавьте зависимости:
/// ```yaml
/// dependencies:
///   nexo: ^0.0.6-beta.0
///   nexo_generator: ^0.0.6-beta.0
///
/// dev_dependencies:
///   build_runner: ^2.13.1
/// ```
///
/// 2. Запустите генерацию:
/// ```bash
/// dart run build_runner build --delete-conflicting-outputs
/// ```
library;

export 'src/nexo_usecase_annotation.dart';
export 'src/nexo_usecase_generator.dart' show nexoUseCaseBuilder;
