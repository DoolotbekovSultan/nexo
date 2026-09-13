import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'nexo_usecase_annotation.dart';

/// Генератор реализации UseCase для build_runner.
///
/// Находит abstract class с аннотацией [@NexoUseCaseAnnotation] и генерирует
/// concrete implementation с конструктором и методом [execute].
///
/// ## Использование
///
/// Добавьте в `build.yaml`:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       nexo_generator:
///         enabled: true
/// ```
///
/// Или используйте в коде:
/// ```dart
/// Builder get nexoGenerator => SharedPartBuilder(
///       [NexoUseCaseGenerator()],
///       'nexo_generator',
///     );
/// ```
///
/// См. также: [NexoUseCaseAnnotation].
class NexoUseCaseGenerator
    extends GeneratorForAnnotation<NexoUseCaseAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@NexoUseCaseAnnotation只能标注在abstract class上',
        element: element,
      );
    }

    final classElement = element;
    if (!classElement.isAbstract) {
      throw InvalidGenerationSourceError(
        '@NexoUseCaseAnnotation只能标注在abstract class上',
        element: element,
      );
    }

    // Find the execute method
    final executeMethod = classElement.methods.firstWhere(
      (m) => m.name == 'execute',
      orElse: () => throw InvalidGenerationSourceError(
        'UseCase必须有execute方法',
        element: element,
      ),
    );

    // Get repository type from annotation
    final repoType = annotation.read('repo').typeValue;
    final repoTypeName = repoType.getDisplayString();

    // Get extra dependencies from annotation
    final extraDeps = annotation.read('extraDeps').listValue;

    final className = classElement.name;
    final implName = '${className}Impl';

    // Get return type
    final returnType = executeMethod.returnType.getDisplayString();

    // Build constructor parameters
    final constructorParams = StringBuffer();
    constructorParams.write('required NexoLogger logger');
    constructorParams.write(', required $repoTypeName repository');
    for (final dep in extraDeps) {
      final depType = dep.toStringValue();
      if (depType != null) {
        final paramName = _toCamelCase(depType);
        constructorParams.write(', required $depType $paramName');
      }
    }

    // Build field declarations
    final fieldDeclarations = StringBuffer();
    fieldDeclarations.writeln('  final $repoTypeName _repository;');
    for (final dep in extraDeps) {
      final depType = dep.toStringValue();
      if (depType != null) {
        fieldDeclarations.writeln(
          '  final $depType _${_toCamelCase(depType)};',
        );
      }
    }

    // Build constructor initializer list
    final initializerList = StringBuffer();
    initializerList.write('_repository = repository');
    for (final dep in extraDeps) {
      final depType = dep.toStringValue();
      if (depType != null) {
        initializerList.write(
          ', _${_toCamelCase(depType)} = ${_toCamelCase(depType)}',
        );
      }
    }

    // Build execute method body
    final executeBody = _buildExecuteBody(
      classElement,
      executeMethod,
      repoTypeName,
      returnType,
    );

    return '''
/// Реализация [$className], сгенерированная build_runner.
///
/// Не редактируйте этот файл вручную. Изменения будут перезаписаны
/// при следующем запуске build_runner.
@injectable
class $implName extends $className {
  $implName({
    $constructorParams,
  }) : $initializerList, super(logger);

$fieldDeclarations

  @override
  $executeBody
}
''';
  }

  String _buildExecuteBody(
    ClassElement classElement,
    MethodElement executeMethod,
    String repoTypeName,
    String returnType,
  ) {
    // Get the method name from the abstract class
    // Convention: execute method delegates to repository
    // e.g., execute(GetUserParams params) -> _repository.getUser(params.id)

    // Try to infer the repository method name
    final methodName = _inferRepositoryMethodName(classElement);

    // Build the call
    if (methodName != null) {
      // Try to infer the parameter access
      final paramAccess = _inferParameterAccess(executeMethod);
      if (paramAccess != null) {
        return 'Future<$returnType> execute(dynamic params) =>\n'
            '    _repository.$methodName($paramAccess);';
      }
    }

    // Fallback: just call repository with params
    return 'Future<$returnType> execute(dynamic params) =>\n'
        '    _repository.$methodName(params);';
  }

  String? _inferRepositoryMethodName(ClassElement classElement) {
    // Get the class name and try to infer the method name
    // e.g., GetUserUseCase -> getUser
    final className = classElement.name ?? '';
    if (className.endsWith('UseCase')) {
      final prefix = className.substring(0, className.length - 7);
      // Convert PascalCase to camelCase
      return '${prefix[0].toLowerCase()}${prefix.substring(1)}';
    }
    return null;
  }

  String? _inferParameterAccess(MethodElement executeMethod) {
    // Try to find a common parameter name like 'id', 'userId', etc.
    // In newer analyzer versions, parameters might be accessed differently
    // For now, return null to use fallback
    return null;
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return input;
    final parts = input.split('_');
    if (parts.length == 1) {
      return parts[0][0].toLowerCase() + parts[0].substring(1);
    }
    return parts[0].toLowerCase() +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}

/// Entry point for build_runner.
Builder nexoUseCaseBuilder(BuilderOptions options) =>
    SharedPartBuilder([NexoUseCaseGenerator()], 'nexo_usecase');
