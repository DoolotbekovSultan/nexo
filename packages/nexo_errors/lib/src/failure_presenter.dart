import 'package:nexo_errors/src/failure.dart';

/// Тонкий слой между [Failure] и UI: тексты для Snackbar / диалога.
///
/// Сообщения для пользователя по-прежнему из [Failure.userMessage]; заголовок
/// диалога — короткий нейтральный вариант по [Failure.logCategory] (при
/// необходимости замените в приложении своим [FailurePresenter]).
abstract final class FailurePresenter {
  FailurePresenter._();

  /// Текст для Snackbar / баннера (полное пользовательское сообщение).
  static String snackbarMessage(Failure failure) => failure.userMessage;

  /// Короткий заголовок диалога (английский ярлык категории).
  static String dialogTitle(Failure failure) => switch (failure.logCategory) {
    'network' => 'Network',
    'http' => 'Server',
    'auth' => 'Account',
    'validation' => 'Validation',
    'storage' => 'Storage',
    'database' => 'Database',
    'cache' => 'Cache',
    'parse' => 'Data',
    'permission' => 'Permission',
    'platform' => 'Device',
    'file' => 'File',
    'location' => 'Location',
    'notification' => 'Notifications',
    'payment' => 'Payment',
    'sync' => 'Sync',
    _ => 'Something went wrong',
  };

  /// Основной текст диалога — то же, что и для snackbar.
  static String dialogBody(Failure failure) => failure.userMessage;

  /// Стабильный код для подзаголовка / «Подробнее» / логов в UI.
  static String technicalCode(Failure failure) => failure.code;
}
