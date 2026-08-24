import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';

void main() {
  group('requiredField', () {
    test('пустое и пробельное значение — ошибка', () {
      final validator = NexoValidators.requiredField();

      expect(validator(''), isNotNull);
      expect(validator('   '), isNotNull);
    });

    test('с именем поля подставляется в сообщение', () {
      expect(
        NexoValidators.requiredField('Email')(''),
        'Поле «Email» обязательно',
      );
      expect(NexoValidators.requiredField()(''), 'Поле обязательно');
    });

    test('непустое значение проходит', () {
      expect(NexoValidators.requiredField('Email')('a@b.c'), isNull);
    });
  });

  group('email', () {
    test('валидные адреса проходят', () {
      final validator = NexoValidators.email();
      expect(validator('user@example.com'), isNull);
      expect(validator('user.name+tag@sub.domain.io'), isNull);
    });

    test('мусор отклоняется', () {
      final validator = NexoValidators.email();
      expect(validator('not-an-email'), isNotNull);
      expect(validator('user@'), isNotNull);
      expect(validator('@domain.com'), isNotNull);
    });
  });

  group('phone', () {
    test('форматы с +, скобками, дефисами проходят', () {
      final validator = NexoValidators.phone();
      expect(validator('+996 555 12-34-56'), isNull);
      expect(validator('+7 (999) 123-45-67'), isNull);
      expect(validator('0555123456'), isNull);
    });

    test('буквы отклоняются', () {
      expect(NexoValidators.phone()('abc-def-ghij'), isNotNull);
    });
  });

  test('url принимает только http/https', () {
    final validator = NexoValidators.url();
    expect(validator('https://nexo.dev/docs'), isNull);
    expect(validator('http://localhost:8080'), isNull);
    expect(validator('ftp://files.example.com'), isNotNull);
    expect(validator('not a url'), isNotNull);
  });

  test('number понимает запятую как разделитель', () {
    final validator = NexoValidators.number();
    expect(validator('42'), isNull);
    expect(validator('3,14'), isNull);
    expect(validator('-0.5'), isNull);
    expect(validator('12abc'), isNotNull);
  });

  group('длина', () {
    test('minLength', () {
      final validator = NexoValidators.minLength(3, 'Логин');
      expect(validator('abcd'), isNull);
      expect(validator('ab'), '«Логин» слишком короткое');
    });

    test('maxLength', () {
      final validator = NexoValidators.maxLength(3, 'Логин');
      expect(validator('abc'), isNull);
      expect(validator('abcd'), '«Логин» слишком длинное');
    });
  });

  group('password', () {
    test('короткий пароль — tooShort', () {
      expect(NexoValidators.password(minLength: 8)('Ab1'), isNotNull);
    });

    test('без цифр или без букв — passwordTooWeak', () {
      final validator = NexoValidators.password(minLength: 4);
      expect(validator('abcdef'), isNotNull);
      expect(validator('123456'), isNotNull);
      expect(validator('abc123'), isNull);
      expect(
        validator('пароль123'),
        isNull,
        reason: 'кириллица считается буквами',
      );
    });

    test('requireDigit=false разрешает только буквы', () {
      final validator = NexoValidators.password(
        minLength: 4,
        requireDigit: false,
      );
      expect(validator('abcd'), isNull);
    });
  });

  test('compose возвращает первую ошибку по порядку', () {
    final validator = NexoValidators.compose([
      NexoValidators.requiredField('Email'),
      NexoValidators.email(),
    ]);

    expect(validator(''), 'Поле «Email» обязательно');
    expect(validator('nope'), isNotNull);
    expect(validator('user@example.com'), isNull);
  });

  test('необязательное поле валидируется одним правилом', () {
    final validator = NexoValidators.email();

    expect(validator(''), isNull, reason: 'пустое значение пропускается');
  });

  test('сообщения локализуются каталогом (EN)', () {
    final message = Failure.validation(
      type: ValidationFailure.invalidEmail,
    ).localizedMessage(const EnFailureUserMessages());

    expect(message, isNot(contains('Неверный')));
  });
}
