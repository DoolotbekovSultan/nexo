import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';

import 'failure_support.dart';
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
///   Future<List<FilmDto>> list(String token, {String? q, int limit = 100}) {
///     return _ds.listFilms(token, q: q, limit: limit);
///   }
///
///   @override
///   Future<FilmDto> create(String token, Map<String, dynamic> body) {
///     return _ds.createFilm(token, body);
///   }
///
///   @override
///   Future<void> delete(String token, int id) {
///     return _ds.deleteFilm(token, id);
///   }
/// }
/// ```
abstract interface class NexoAdminRepository<T> {
  /// Загружает список сущностей.
  ///
  /// [token] — токен аутентификации.
  /// [q] — поисковый запрос (опционально).
  /// [limit] — максимальное количество элементов.
  Future<List<T>> list(String token, {String? q, int limit = 100});

  /// Создаёт новую сущность.
  ///
  /// [token] — токен аутентификации.
  /// [body] — данные новой сущности.
  Future<T> create(String token, Map<String, dynamic> body);

  /// Удаляет сущность по идентификатору.
  ///
  /// [token] — токен аутентификации.
  /// [id] — идентификатор сущности.
  Future<void> delete(String token, int id);
}

/// Гeneric CRUD BLoC для админ-панелей.
///
/// Наследует [NexoBloc] и предоставляет готовую реализацию загрузки,
/// поиска, создания и удаления сущностей. Пользователь определяет
/// только тип сущности и конфигурирует BLoC через параметры конструктора.
///
/// ## Параметры
///
/// - [T] — тип сущности (DTO).
///
/// ## Пример использования
///
/// ```dart
/// @injectable
/// class AdminFilmsBloc extends NexoAdminCrudBloc<AdminFilmDto> {
///   AdminFilmsBloc({
///     required AdminRepository repository,
///     required String token,
///   }) : super(repository: repository, token: token, path: 'films');
/// }
/// ```
///
/// ## Автоматические операции
///
/// - `on<LoadCrudData<T>>` — загрузка списка сущностей.
/// - `on<SearchCrudData<T>>` — поиск по списку.
/// - `on<CreateCrudEntity<T>>` — создание новой сущности.
/// - `on<DeleteCrudEntity<T>>` — удаление сущности по идентификатору.
///
/// См. также: [NexoCrudState], [NexoAdminRepository], [NexoBloc].
abstract class NexoAdminCrudBloc<T> extends NexoBloc<Object, NexoCrudState<T>> {
  /// Создаёт экземпляр [NexoAdminCrudBloc].
  ///
  /// [repository] — репозиторий для CRUD-операций.
  /// [token] — токен аутентификации.
  /// [path] — путь API (например, 'films', 'users').
  /// [limit] — максимальное количество элементов при загрузке (по умолчанию 100).
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

  Future<void> _onLoad(
    LoadCrudData<T> event,
    Emitter<NexoCrudState<T>> emit,
  ) async {
    emit(const NexoCrudLoading());
    try {
      final items = await repository.list(
        token,
        q: _lastSearchQuery,
        limit: limit,
      );
      emit(NexoCrudReady(items: items, search: _lastSearchQuery ?? ''));
    } on Failure catch (f) {
      emit(NexoCrudError(errorMessage: f.userMessage));
    } catch (e, s) {
      emit(NexoCrudError(errorMessage: toFailure(e, s).userMessage));
    }
  }

  Future<void> _onSearch(
    SearchCrudData<T> event,
    Emitter<NexoCrudState<T>> emit,
  ) async {
    _lastSearchQuery = event.query.isEmpty ? null : event.query;
    emit(const NexoCrudLoading());
    try {
      final items = await repository.list(
        token,
        q: _lastSearchQuery,
        limit: limit,
      );
      emit(NexoCrudReady(items: items, search: event.query));
    } on Failure catch (f) {
      emit(NexoCrudError(errorMessage: f.userMessage));
    } catch (e, s) {
      emit(NexoCrudError(errorMessage: toFailure(e, s).userMessage));
    }
  }

  Future<void> _onCreate(
    CreateCrudEntity<T> event,
    Emitter<NexoCrudState<T>> emit,
  ) async {
    final currentState = state;
    if (currentState is! NexoCrudReady<T>) return;

    await executeMutation(
      emit: emit,
      action: () => repository.create(token, event.body),
      onSuccess: () async {
        final items = await repository.list(
          token,
          q: _lastSearchQuery,
          limit: limit,
        );
        emit(NexoCrudReady(items: items, search: _lastSearchQuery ?? ''));
      },
      onError: (f) {
        emit(
          NexoCrudReady(
            items: currentState.items,
            search: currentState.search,
            feedbackMessage: f.userMessage,
            isFeedbackError: true,
          ),
        );
      },
    );
  }

  Future<void> _onDelete(
    DeleteCrudEntity<T> event,
    Emitter<NexoCrudState<T>> emit,
  ) async {
    final currentState = state;
    if (currentState is! NexoCrudReady<T>) return;

    await executeMutation(
      emit: emit,
      action: () => repository.delete(token, event.id),
      onSuccess: () async {
        final items = await repository.list(
          token,
          q: _lastSearchQuery,
          limit: limit,
        );
        emit(NexoCrudReady(items: items, search: _lastSearchQuery ?? ''));
      },
      onError: (f) {
        emit(
          NexoCrudReady(
            items: currentState.items,
            search: currentState.search,
            feedbackMessage: f.userMessage,
            isFeedbackError: true,
          ),
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
