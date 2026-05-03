import 'package:dartz/dartz.dart';

import 'package:nexo/packages/nexo_errors/failure.dart';

export 'package:dartz/dartz.dart' show Either, Left, Right;

/// Shorthand for [Either] of [Failure] — удобнее в сигнатурах публичного API.
typedef Result<T> = Either<Failure, T>;

/// Поток результатов с тем же смыслом, что и [Result].
typedef StreamResult<T> = Stream<Result<T>>;
