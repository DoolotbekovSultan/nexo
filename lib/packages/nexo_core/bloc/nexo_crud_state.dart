/// Состояние CRUD-операций (загрузка, готово, ошибка).
///
/// Типизированное состояние [NexoCrudState] используется совместно с
/// [NexoAdminCrudBloc] для единообразного представления состояний
/// CRUD-операций в админ-интерфейсах.
///
/// ## Пример
///
/// ```dart
/// // Начальное состояние
/// const state = NexoCrudState<List<FilmDto>>.loading();
///
/// // Состояние с данными
/// final ready = NexoCrudState.ready(
///   items: films,
///   search: '',
/// );
///
/// // Состояние ошибки
/// final error = NexoCrudState.error(errorMessage: 'Network error');
/// ```
sealed class NexoCrudState<T> {
  const NexoCrudState();

  /// `true`, если состояние — загрузка.
  bool get isLoading => this is NexoCrudLoading<T>;

  /// `true`, если состояние — готово (данные загружены).
  bool get isReady => this is NexoCrudReady<T>;

  /// `true`, если состояние — ошибка.
  bool get isError => this is NexoCrudError<T>;
}

/// Состояние загрузки данных.
final class NexoCrudLoading<T> extends NexoCrudState<T> {
  const NexoCrudLoading();
}

/// Состояние готовности: данные загружены и доступны.
///
/// [items] — текущий список элементов.
/// [search] — текущий поисковый запрос.
/// [busy] — `true`, если выполняется мутация (создание/удаление).
/// [feedbackMessage] — сообщение для пользователя (успех/ошибка).
/// [isFeedbackError] — `true`, если feedbackMessage — сообщение об ошибке.
final class NexoCrudReady<T> extends NexoCrudState<T> {
  const NexoCrudReady({
    required this.items,
    this.search = '',
    this.busy = false,
    this.feedbackMessage,
    this.isFeedbackError = false,
  });

  /// Текущий список элементов.
  final List<T> items;

  /// Текущий поисковый запрос.
  final String search;

  /// `true`, если выполняется мутация (создание/удаление).
  final bool busy;

  /// Сообщение для пользователя (успех/ошибка).
  final String? feedbackMessage;

  /// `true`, если feedbackMessage — сообщение об ошибке.
  final bool isFeedbackError;

  /// Создаёт копию с указанными изменениями.
  NexoCrudReady<T> copyWith({
    List<T>? items,
    String? search,
    bool? busy,
    String? feedbackMessage,
    bool? isFeedbackError,
    bool clearFeedback = false,
  }) {
    return NexoCrudReady<T>(
      items: items ?? this.items,
      search: search ?? this.search,
      busy: busy ?? this.busy,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      isFeedbackError: clearFeedback
          ? false
          : (isFeedbackError ?? this.isFeedbackError),
    );
  }
}

/// Состояние ошибки.
///
/// [errorMessage] — описание ошибки для пользователя.
final class NexoCrudError<T> extends NexoCrudState<T> {
  const NexoCrudError({required this.errorMessage});

  /// Описание ошибки для пользователя.
  final String errorMessage;
}
