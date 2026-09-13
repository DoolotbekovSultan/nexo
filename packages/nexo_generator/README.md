# nexo_generator

Code generator for [nexo](https://github.com/DoolotbekovSultan/nexo) package.

Generates UseCase implementations from `@NexoUseCaseAnnotation`.

## Installation

```yaml
dependencies:
  nexo: ^0.0.6-beta.0

dev_dependencies:
  nexo_generator: ^0.0.6-beta.0
  build_runner: ^2.13.1
```

## Usage

1. Annotate your UseCase:

```dart
import 'package:nexo/nexo_core.dart';

@NexoUseCaseAnnotation(repo: IUserRepository)
abstract class GetUserUseCase {
  Future<User> execute(GetUserParams params);
}
```

2. Run build_runner:

```bash
dart run build_runner build --delete-conflicting-outputs
```

3. Generated implementation:

```dart
@injectable
class GetUserUseCaseImpl extends NexoUseCase<User, GetUserParams> {
  GetUserUseCaseImpl({
    required NexoLogger logger,
    required IUserRepository repository,
  }) : _repository = repository, super(logger);

  final IUserRepository _repository;

  @override
  Future<User> execute(dynamic params) =>
      _repository.getUser(params);
}
```

## License

See [LICENSE](https://github.com/DoolotbekovSultan/nexo/blob/main/LICENSE).
