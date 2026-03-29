import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';

mixin FailureSupport {
  Failure toFailure(Object error, StackTrace stackTrace) {
    return error is Failure ? error : error.toFailure(stackTrace);
  }
}
