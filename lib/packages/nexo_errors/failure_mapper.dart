import 'package:nexo/packages/nexo_errors/mappers/platfrom_failure_mapper.dart';

import 'failure.dart';
import 'mappers/common_failure_mapper.dart';
import 'mappers/dio_failure_mapper.dart';
import 'mappers/domain_exception_failure_mapper.dart';
import 'mappers/drift_failure_mapper.dart';
import 'mappers/failure_sub_mapper.dart';
import 'mappers/file_system_failure_mapper.dart';
import 'mappers/firebase_auth_failure_mapper.dart';
import 'mappers/firebase_messaging_failure_mapper.dart';
import 'mappers/hive_failure_mapper.dart';
import 'mappers/isar_failure_mapper.dart';

final class FailureMapper {
  const FailureMapper._();

  static const List<FailureSubMapper> _mappers = [
    DomainExceptionFailureMapper(),
    FirebaseAuthFailureMapper(),
    FirebaseMessagingFailureMapper(),
    DioFailureMapper(),
    PlatformFailureMapper(),
    HiveFailureMapper(),
    IsarFailureMapper(),
    DriftFailureMapper(),
    FileSystemFailureMapper(),
    CommonFailureMapper(),
  ];

  static Failure from(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    for (final mapper in _mappers) {
      final failure = mapper.tryMap(error, stackTrace);
      if (failure != null) return failure;
    }

    return Failure.unknown(
      error: error,
      stackTrace: stackTrace,
      message: error.toString(),
    );
  }
}

extension FailureMapperX on Object {
  Failure toFailure([StackTrace? stackTrace]) {
    return FailureMapper.from(this, stackTrace);
  }
}
