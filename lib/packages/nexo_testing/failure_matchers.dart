import 'package:matcher/matcher.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';

/// Матчер: ошибка с ожидаемым стабильным кодом ([Failure.code]).
///
/// ```dart
/// expect(failure, failureWithCode('http.unauthorized'));
/// ```
Matcher failureWithCode(String code) =>
    isA<Failure>().having((f) => f.code, 'code', code);

/// Матчер: ошибка с ожидаемым пользовательским сообщением ([Failure.userMessage]).
Matcher failureWithUserMessage(String message) =>
    isA<Failure>().having((f) => f.userMessage, 'userMessage', message);
