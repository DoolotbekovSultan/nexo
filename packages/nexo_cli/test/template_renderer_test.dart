import 'package:nexo_cli/src/name_utils.dart';
import 'package:nexo_cli/src/template_renderer.dart';
import 'package:test/test.dart';

void main() {
  test(
    'cubit template: AuthCubit, AuthEntity, no bool in async state usage',
    () {
      final names = NameUtils.fromFeatureInput('auth');
      final cubitOut = TemplateRenderer.render(
        'presentation/cubit/auth_cubit.dart',
        names,
      );
      expect(cubitOut, contains('class AuthCubit'));
      expect(cubitOut, contains('extends NexoCubit<AuthState>'));
      expect(cubitOut, contains('AuthEntity'));
      expect(cubitOut, isNot(contains('NexoAsyncState<bool>')));
      expect(cubitOut, isNot(contains('NexoAsyncIdle<bool>')));
      expect(cubitOut, isNot(contains('bool>')));

      final stateOut = TemplateRenderer.render(
        'presentation/cubit/auth_state.dart',
        names,
      );
      expect(
        stateOut,
        contains('typedef AuthState = NexoAsyncState<AuthEntity>'),
      );
      expect(stateOut, isNot(contains('bool')));
    },
  );

  test('substitutes lowerCamel for multi-segment snake (entity)', () {
    final names = NameUtils.fromFeatureInput('user_profile');
    final out = TemplateRenderer.render(
      'domain/entities/user_profile_entity.dart',
      names,
    );
    expect(out, contains('class UserProfileEntity'));
    expect(out, contains('final String id'));
  });
}
