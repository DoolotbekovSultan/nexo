// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'nexo_usecase_annotation.dart';

/// Генератор реализации UseCase для build_runner.
///
/// Находит abstract class с аннотацией [@NexoUseCaseAnnotation] и генерирует
/// concrete implementation с конструктором и методом [execute].
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
    final methodName = _inferRepositoryMethodName(classElement);
    final executeBody = methodName != null
        ? 'Future<$returnType> execute(dynamic params) =>\n'
            '    _repository.$methodName(params);'
        : 'Future<$returnType> execute(dynamic params) =>\n'
            '    _repository.execute(params);';

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

  String? _inferRepositoryMethodName(ClassElement classElement) {
    final className = classElement.name;
    if (className.endsWith('UseCase')) {
      final prefix = className.substring(0, className.length - 7);
      return '${prefix[0].toLowerCase()}${prefix.substring(1)}';
    }
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
