import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper.dart';

extension FailureMapperExtension on Object {
  Failure toFailure([StackTrace? stackTrace]) {
    return FailureMapper.from(this, stackTrace);
  }
}
