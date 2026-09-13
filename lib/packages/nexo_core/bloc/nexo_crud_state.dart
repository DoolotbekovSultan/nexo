/// Состояние CRUD-операций (загрузка, готово, ошибка).
///
/// Типизированное состояние [NexoCrudState] используется с BLoC
/// для единообразного представления состояний CRUD-операций.
///
/// ## Параметры
///
/// - [T] — тип элементов (DTO).
/// - [F] — тип feedback (например, ваш кастомный `AdminFeedback`).
///
/// ## Пример
///
/// ```dart
/// // С кастомным feedback:
/// typedef FilmCrudState = NexoCrudState<FilmDto, AdminFeedback>;
///
/// // Готовое состояние:
/// final ready = NexoCrudState.ready(
///   items: films,
///   feedback: AdminFeedback.success('Загружено'),
/// );
/// ```
sealed class NexoCrudState<T, F> {
  const NexoCrudState();

  /// `true`, если состояние — загрузка.
  bool get isLoading => this is NexoCrudLoading<T, F>;

  /// `true`, если состояние — готово (данные загружены).
  bool get isReady => this is NexoCrudReady<T, F>;

  /// `true`, если состояние — ошибка.
  bool get isError => this is NexoCrudError<T, F>;
}

/// Состояние загрузки данных.
final class NexoCrudLoading<T, F> extends NexoCrudState<T, F> {
  const NexoCrudLoading();
}

/// Состояние готовности: данные загружены и доступны.
///
/// [items] — текущий список элементов.
/// [search] — текущий поисковый запрос.
/// [busy] — `true`, если выполняется мутация (создание/удаление).
/// [feedback] —eneric feedback (успех/ошибка).
final class NexoCrudReady<T, F> extends NexoCrudState<T, F> {
  const NexoCrudReady({
    required this.items,
    this.search = '',
    this.busy = false,
    this.feedback,
  });

  /// Текущий список элементов.
  final List<T> items;

  /// Текущий поисковый запрос.
  final String search;

  /// `true`, если выполняется мутация (создание/удаление).
  final bool busy;

  /// Feedback (успех/ошибка) — generic тип.
  final F? feedback;

  /// Создаёт копию с указанными изменениями.
  NexoCrudReady<T, F> copyWith({
    List<T>? items,
    String? search,
    bool? busy,
    F? feedback,
    bool clearFeedback = false,
  }) {
    return NexoCrudReady<T, F>(
      items: items ?? this.items,
      search: search ?? this.search,
      busy: busy ?? this.busy,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}

/// Состояние ошибки.
///
/// [errorMessage] — описание ошибки для пользователя.
final class NexoCrudError<T, F> extends NexoCrudState<T, F> {
  const NexoCrudError({required this.errorMessage});

  /// Описание ошибки для пользователя.
  final String errorMessage;
}
