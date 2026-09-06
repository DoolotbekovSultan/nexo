import 'package:nexo_cli/src/feature_plan.dart';
import 'package:nexo_cli/src/name_utils.dart';
import 'package:nexo_cli/src/template_renderer.dart';
import 'package:test/test.dart';

void main() {
  const defaultOptions = FeatureOptions(
    presentationOnly: false,
    presentationStyle: PresentationStyle.cubit,
    freezed: true,
    injectable: true,
    mapper: true,
    mock: true,
    local: false,
    preferences: false,
    ui: false,
    extensions: false,
    tests: false,
    dryRun: false,
    overwrite: false,
    crudOperations: {'get'},
    isList: true,
  );

  group('entity templates', () {
    test('freezed entity', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/entities/auth_entity.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@freezed'));
      expect(out, contains('class AuthEntity'));
      expect(out, contains("part 'auth_entity.freezed.dart'"));
    });

    test('plain entity', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/entities/auth_entity.dart',
        names,
        defaultOptions.copyWith(freezed: false),
      );
      expect(out, isNot(contains('@freezed')));
      expect(out, contains('class AuthEntity'));
      expect(out, isNot(contains('.freezed.dart')));
    });

    test('entity with JSON fields', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/entities/auth_entity.dart',
        names,
        defaultOptions.copyWith(
          jsonFields: {'id': 'String', 'name': 'String', 'age': 'int'},
        ),
      );
      // Freezed uses named params without final/semicolons in factory
      expect(out, contains('String id,'));
      expect(out, contains('String name,'));
      expect(out, contains('int age,'));
    });
  });

  group('model templates', () {
    test('freezed model', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/models/auth_model.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@freezed'));
      expect(out, contains('class AuthModel'));
      expect(out, contains('fromJson'));
      expect(out, contains('.g.dart'));
    });

    test('plain model', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/models/auth_model.dart',
        names,
        defaultOptions.copyWith(freezed: false),
      );
      expect(out, isNot(contains('@freezed')));
      expect(out, contains('class AuthModel'));
      expect(out, contains('fromJson'));
    });

    test('model with JSON fields', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/models/auth_model.dart',
        names,
        defaultOptions.copyWith(
          jsonFields: {'id': 'String', 'title': 'String', 'count': 'int'},
        ),
      );
      // Freezed uses named params without final/semicolons in factory
      expect(out, contains('String id,'));
      expect(out, contains('String title,'));
      expect(out, contains('int count,'));
    });
  });

  group('datasource templates', () {
    test('remote datasource interface', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/datasources/i_remote_auth_data_source.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('abstract interface class IRemoteAuthDataSource'));
    });

    test('local datasource interface', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/datasources/i_local_auth_data_source.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('abstract interface class ILocalAuthDataSource'));
    });

    test('remote datasource impl', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/datasources/auth_remote_datasource.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@LazySingleton'));
      expect(out, contains('class AuthRemoteDataSource'));
      expect(out, contains('extends BaseRemoteDataSource'));
    });

    test('mock remote datasource', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/datasources/mock_auth_remote_data_source.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@LazySingleton'));
      expect(out, contains('class MockAuthRemoteDataSource'));
      expect(out, contains('TODO'));
    });
  });

  group('mapper template', () {
    test('mapper extension', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/mappers/auth_mapper.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('extension AuthMapper on AuthModel'));
      expect(out, contains('AuthEntity toDomain()'));
      expect(out, contains('extension AuthListMapper'));
    });

    test('mapper with JSON fields', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/mappers/auth_mapper.dart',
        names,
        defaultOptions.copyWith(jsonFields: {'id': 'String', 'name': 'String'}),
      );
      expect(out, contains('id: id'));
      expect(out, contains('name: name'));
    });
  });

  group('repository templates', () {
    test('repository interface', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/repositories/i_auth_repository.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('abstract interface class IAuthRepository'));
    });

    test('repository impl', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/repositories/auth_repository.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@LazySingleton'));
      expect(out, contains('class AuthRepository'));
      expect(out, contains('implements IAuthRepository'));
    });

    test('repository impl has @Named when mock is enabled', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/repositories/auth_repository.dart',
        names,
        defaultOptions.copyWith(mock: true),
      );
      expect(out, contains("@Named('prod')"));
    });

    test('repository impl has no @Named when mock is disabled', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/repositories/auth_repository.dart',
        names,
        defaultOptions.copyWith(mock: false),
      );
      expect(out, isNot(contains('@Named')));
    });
  });

  group('usecase template', () {
    test('usecase', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/usecases/get_auth_usecase.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@injectable'));
      expect(out, contains('class GetAuthUseCase'));
      expect(out, contains('extends NexoUseCase'));
    });
  });

  group('state templates', () {
    test('freezed state', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/cubit/auth_state.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@freezed'));
      expect(out, contains('class AuthState'));
      expect(out, contains('AuthState.loading()'));
      expect(out, contains('AuthState.success('));
      expect(out, contains('AuthState.error('));
    });

    test('plain state', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/cubit/auth_state.dart',
        names,
        defaultOptions.copyWith(freezed: false),
      );
      expect(out, isNot(contains('@freezed')));
      expect(out, contains('typedef AuthState = NexoAsyncState'));
    });
  });

  group('cubit templates', () {
    test('cubit', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/cubit/auth_cubit.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@injectable'));
      expect(out, contains('class AuthCubit'));
      expect(out, contains('extends NexoCubit<AuthState>'));
    });

    test('list cubit', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/cubit/auth_cubit.dart',
        names,
        defaultOptions.copyWith(presentationStyle: PresentationStyle.listCubit),
      );
      expect(out, contains('@injectable'));
      expect(out, contains('class AuthCubit'));
      expect(out, contains('extends NexoCubit'));
      expect(out, contains('load()'));
    });
  });

  group('bloc templates', () {
    test('bloc', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/bloc/auth_bloc.dart',
        names,
        defaultOptions.copyWith(presentationStyle: PresentationStyle.bloc),
      );
      expect(out, contains('@injectable'));
      expect(out, contains('class AuthBloc'));
      expect(out, contains('extends NexoBloc'));
    });

    test('event', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/bloc/auth_event.dart',
        names,
        defaultOptions.copyWith(presentationStyle: PresentationStyle.bloc),
      );
      expect(out, contains('@freezed'));
      expect(out, contains('class AuthEvent'));
      expect(out, contains('AuthEvent.load()'));
    });
  });

  group('request templates', () {
    test('create request freezed', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'models/requests/create_auth_request.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@freezed'));
      expect(out, contains('class CreateAuthRequest'));
    });

    test('update request freezed', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'models/requests/update_auth_request.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('@freezed'));
      expect(out, contains('class UpdateAuthRequest'));
    });

    test('request with JSON fields', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'models/requests/create_auth_request.dart',
        names,
        defaultOptions.copyWith(jsonFields: {'id': 'String', 'name': 'String'}),
      );
      // Freezed uses named params without final/semicolons in factory
      expect(out, contains('String id,'));
      expect(out, contains('String name,'));
    });
  });

  group('parameter templates', () {
    test('create params', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/parameters/create_auth_params.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class CreateAuthParams'));
    });

    test('update params', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/parameters/update_auth_params.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class UpdateAuthParams'));
    });
  });

  group('CRUD usecases template', () {
    test('crud usecases', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/usecases/auth_usecases.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class CreateAuthUseCase'));
      expect(out, contains('class UpdateAuthUseCase'));
      expect(out, contains('class DeleteAuthUseCase'));
    });
  });

  group('preferences template', () {
    test('preferences', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'data/auth_preferences.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class AuthPreferences'));
      expect(out, contains('SharedPreferences'));
    });
  });

  group('extensions template', () {
    test('extensions', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'domain/entities/auth_extensions.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('extension AuthExtensions on AuthEntity'));
    });
  });

  group('screen template', () {
    test('screen', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/auth_screen.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class AuthScreen'));
      expect(out, contains('StatelessWidget'));
    });
  });

  group('UI templates', () {
    test('page', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/pages/auth_page.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class AuthPage'));
      expect(out, contains('StatelessWidget'));
    });

    test('widget', () {
      final names = NameUtils.fromFeatureInput('auth');
      final out = TemplateRenderer.render(
        'presentation/widgets/auth_widget.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class AuthWidget'));
      expect(out, contains('StatelessWidget'));
    });
  });

  group('substitutions', () {
    test('substitutes lowerCamel for multi-segment snake', () {
      final names = NameUtils.fromFeatureInput('user_profile');
      final out = TemplateRenderer.render(
        'domain/entities/user_profile_entity.dart',
        names,
        defaultOptions,
      );
      expect(out, contains('class UserProfileEntity'));
    });
  });
}
