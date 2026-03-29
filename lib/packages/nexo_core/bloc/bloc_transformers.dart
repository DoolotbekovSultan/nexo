import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<E> restartableTransformer<E>() {
  return (events, mapper) => restartable<E>().call(events, mapper);
}

EventTransformer<E> droppableTransformer<E>() {
  return (events, mapper) => droppable<E>().call(events, mapper);
}

EventTransformer<E> sequentialTransformer<E>() {
  return (events, mapper) => sequential<E>().call(events, mapper);
}

EventTransformer<E> concurrentTransformer<E>() {
  return (events, mapper) => concurrent<E>().call(events, mapper);
}

EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) {
    return restartable<E>().call(events.debounce(duration), mapper);
  };
}
