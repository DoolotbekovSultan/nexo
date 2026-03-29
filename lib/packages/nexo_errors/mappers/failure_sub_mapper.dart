import '../failure.dart';

abstract interface class FailureSubMapper {
  const FailureSubMapper();

  Failure? tryMap(Object error, [StackTrace? stackTrace]);
}
