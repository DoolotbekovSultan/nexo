import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

/// Трансформер: отменяет предыдущую обработку события при новом.
///
/// Если новое событие поступает до завершения предыдущего,
/// предыдущее отменяется и обрабатывается только последнее.
///
/// ## Пример
///
/// ```dart
/// bloc_concurrency.restartableTransformer<Event>();
/// // или
/// EventTransformer<Event> transformer = restartableTransformer();
/// ```
EventTransformer<E> restartableTransformer<E>() {
  return (events, mapper) => restartable<E>().call(events, mapper);
}

/// Трансформер: отбрасывает новые события во время обработки.
///
/// Если событие обрабатывается, новые события игнорируются
/// до завершения текущей операции.
EventTransformer<E> droppableTransformer<E>() {
  return (events, mapper) => droppable<E>().call(events, mapper);
}

/// Трансформер: обрабатывает события строго по очереди.
///
/// Каждое событие ждёт завершения предыдущего. Подходит для операций,
/// которые должны выполняться последовательно (записи в БД и т.д.).
EventTransformer<E> sequentialTransformer<E>() {
  return (events, mapper) => sequential<E>().call(events, mapper);
}

/// Трансформер: обрабатывает события параллельно.
///
/// Все события обрабатываются одновременно без ожидания завершения
/// предыдущих. Подходит для независимых операций.
EventTransformer<E> concurrentTransformer<E>() {
  return (events, mapper) => concurrent<E>().call(events, mapper);
}

/// Трансформер: debounced restartable.
///
/// Объединяет события в течение [duration] и обрабатывает только последнее.
/// Если новое событие поступает во время обработки, предыдущее отменяется.
///
/// [duration] — окно объединения событий.
///
/// ## Пример
///
/// ```dart
/// // Поиск с debounce 300мс
/// on<SearchEvent>(
///   _onSearch,
///   transformer: debounceRestartable(Duration(milliseconds: 300)),
/// );
/// ```
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) {
    return restartable<E>().call(events.debounce(duration), mapper);
  };
}
