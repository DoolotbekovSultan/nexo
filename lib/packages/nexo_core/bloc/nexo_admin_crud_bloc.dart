import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

import 'nexo_bloc.dart';
import 'nexo_crud_state.dart';

/// Интерфейс репозитория для CRUD-операций в админ-панели.
///
/// Определяет минимальный набор методов для работы со списком сущностей:
/// загрузка, поиск, создание и удаление.
///
/// ## Параметры
///
/// - [T] — тип сущности (DTO).
///
/// ## Пример реализации
///
/// ```dart
/// @LazySingleton(as: IFilmRepository)
/// class FilmRepository implements IFilmRepository {
///   FilmRepository(this._ds);
///   final IRemoteFilmDataSource _ds;
///
///   @override
///   Future<Result<List<FilmDto>>> list(String token, {String? q, int limit = 100}) {
///     return _ds.listFilms(token, q: q, limit: limit);
///   }
///
///   @override
///   Future<Result<FilmDto>> create(String token, Map<String, dynamic> body) {
///     return _ds.createFilm(token, body);
///   }
///
///   @override
///   Future<Result<void>> delete(String token, int id) {
///     return _ds.deleteFilm(token, id);
///   }
/// }
/// ```
abstract interface class NexoAdminRepository<T> {
  /// Загружает список сущностей.
  Future<Result<List<T>>> list(String token, {String? q, int limit = 100});

  /// Создаёт новую сущность.
  Future<Result<T>> create(String token, Map<String, dynamic> body);

  /// Удаляет сущность по идентификатору.
  Future<Result<void>> delete(String token, int id);
}

/// Generic CRUD BLoC для админ-панелей.
///
/// Наследует [NexoBloc] и предоставляет готовую реализацию загрузки,
/// поиска, создания и удаления сущностей. Работает с кастомным feedback
/// через generic параметр [F].
///
/// ## Параметры
///
/// - [T] — тип сущности (DTO).
/// - [F] — тип feedback (например, ваш `AdminFeedback`).
///
/// ## Пример использования
///
/// ```dart
/// @injectable
/// class AdminFilmsBloc extends NexoAdminCrudBloc<FilmDto, AdminFeedback> {
///   AdminFilmsBloc({
///     required FilmRepository repository,
///     required String token,
///   }) : super(
///     repository: repository,
///     token: token,
///     path: 'films',
///   );
/// }
/// ```
///
/// См. также: [NexoCrudState], [NexoAdminRepository], [NexoBloc].
abstract class NexoAdminCrudBloc<T, F>
    extends NexoBloc<Object, NexoCrudState<T, F>> {
  /// Создаёт экземпляр [NexoAdminCrudBloc].
  ///
  /// [repository] — репозиторий для CRUD-операций.
  /// [token] — токен аутентификации.
  /// [path] — путь API (например, 'films', 'users').
  /// [limit] — максимальное количество элементов при загрузке.
  NexoAdminCrudBloc({
    required this.repository,
    required this.token,
    required this.path,
    this.limit = 100,
  }) : super(const NexoCrudLoading()) {
    on<LoadCrudData<T>>(_onLoad);
    on<SearchCrudData<T>>(_onSearch);
    on<CreateCrudEntity<T>>(_onCreate);
    on<DeleteCrudEntity<T>>(_onDelete);
  }

  /// Репозиторий для CRUD-операций.
  final NexoAdminRepository<T> repository;

  /// Токен аутентификации.
  final String token;

  /// Путь API (например, 'films', 'users').
  final String path;

  /// Максимальное количество элементов при загрузке.
  final int limit;

  String? _lastSearchQuery;

  /// Создаёт feedback для успешной операции.
  ///
  /// Переопределите для своего типа feedback.
  F buildSuccessFeedback(String message);

  /// Создаёт feedback для ошибки.
  ///
  /// Переопределите для своего типа feedback.
  F buildErrorFeedback(String message);

  Future<void> _onLoad(
    LoadCrudData<T> event,
    Emitter<NexoCrudState<T, F>> emit,
  ) async {
    emit(const NexoCrudLoading());
    final result = await repository.list(
      token,
      q: _lastSearchQuery,
      limit: limit,
    );
    result.fold(
      onFailure: (f) => emit(NexoCrudError(errorMessage: f.userMessage)),
      onSuccess: (items) =>
          emit(NexoCrudReady(items: items, search: _lastSearchQuery ?? '')),
    );
  }

  Future<void> _onSearch(
    SearchCrudData<T> event,
    Emitter<NexoCrudState<T, F>> emit,
  ) async {
    _lastSearchQuery = event.query.isEmpty ? null : event.query;
    emit(const NexoCrudLoading());
    final result = await repository.list(
      token,
      q: _lastSearchQuery,
      limit: limit,
    );
    result.fold(
      onFailure: (f) => emit(NexoCrudError(errorMessage: f.userMessage)),
      onSuccess: (items) =>
          emit(NexoCrudReady(items: items, search: event.query)),
    );
  }

  Future<void> _onCreate(
    CreateCrudEntity<T> event,
    Emitter<NexoCrudState<T, F>> emit,
  ) async {
    final currentState = state;
    if (currentState is! NexoCrudReady<T, F>) return;

    await executeMutation(
      emit: emit,
      action: () => repository.create(token, event.body),
      onSuccess: (_) async {
        final result = await repository.list(
          token,
          q: _lastSearchQuery,
          limit: limit,
        );
        result.fold(
          onFailure: (f) => emit(NexoCrudError(errorMessage: f.userMessage)),
          onSuccess: (items) => emit(
            NexoCrudReady(
              items: items,
              search: _lastSearchQuery ?? '',
              feedback: buildSuccessFeedback('Создано'),
            ),
          ),
        );
      },
      onError: (f) {
        emit(
          currentState.copyWith(feedback: buildErrorFeedback(f.userMessage)),
        );
      },
    );
  }

  Future<void> _onDelete(
    DeleteCrudEntity<T> event,
    Emitter<NexoCrudState<T, F>> emit,
  ) async {
    final currentState = state;
    if (currentState is! NexoCrudReady<T, F>) return;

    await executeMutation(
      emit: emit,
      action: () => repository.delete(token, event.id),
      onSuccess: (_) async {
        final result = await repository.list(
          token,
          q: _lastSearchQuery,
          limit: limit,
        );
        result.fold(
          onFailure: (f) => emit(NexoCrudError(errorMessage: f.userMessage)),
          onSuccess: (items) => emit(
            NexoCrudReady(
              items: items,
              search: _lastSearchQuery ?? '',
              feedback: buildSuccessFeedback('Удалено'),
            ),
          ),
        );
      },
      onError: (f) {
        emit(
          currentState.copyWith(feedback: buildErrorFeedback(f.userMessage)),
        );
      },
    );
  }
}

/// Событие загрузки данных.
final class LoadCrudData<T> {
  const LoadCrudData();
}

/// Событие поиска по списку.
final class SearchCrudData<T> {
  const SearchCrudData(this.query);

  /// Поисковый запрос.
  final String query;
}

/// Событие создания новой сущности.
final class CreateCrudEntity<T> {
  const CreateCrudEntity(this.body);

  /// Данные новой сущности.
  final Map<String, dynamic> body;
}

/// Событие удаления сущности по идентификатору.
final class DeleteCrudEntity<T> {
  const DeleteCrudEntity(this.id);

  /// Идентификатор сущности.
  final int id;
}
