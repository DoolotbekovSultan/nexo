# nexo_errors_firebase

Firebase Auth and Messaging failure mappers for nexo_errors.

Part of the [nexo](https://github.com/DoolotbekovSultan/nexo) toolkit.

## Installation

```yaml
dependencies:
  nexo_errors_firebase: ^0.1.0
```

Or use the umbrella package:

```yaml
dependencies:
  nexo: ^0.1.0
```

## Usage

```dart
import 'package:nexo_errors_firebase/nexo_errors_firebase.dart';

final mapper = FailureMapper(
  extraMappers: [FirebaseAuthFailureMapper(), FirebaseMessagingFailureMapper()],
);
```

## License

See [LICENSE](../../LICENSE).
