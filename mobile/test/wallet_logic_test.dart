import 'package:flutter_test/flutter_test.dart';
import 'package:nur_pay/core/input/amount_editor.dart';
import 'package:nur_pay/core/money.dart';
import 'package:nur_pay/features/wallet/domain/entities/nur_pay_qr.dart';

void main() {
  group('Money', () {
    test('форматирует с пробелом между тысячами и запятой', () {
      expect(Money.major(1240).formatted, '1 240,00');
      expect(Money.major(48.5).formatted, '48,50');
      expect(Money.major(0).formatted, '0,00');
    });

    test('разбирает то, что набрано на клавиатуре', () {
      expect(Money.parse('48,5'), Money.major(48.5));
      expect(Money.parse('1 240,00'), Money.major(1240));
      expect(Money.parse(''), Money.zero);
    });

    test('знак зависит от направления операции', () {
      expect(Money.major(120).signed(incoming: true), '+120,00');
      expect(Money.major(48.5).signed(incoming: false), '−48,50');
    });
  });

  group('AmountEditor', () {
    test('набор цифр и запятой', () {
      final editor = AmountEditor()
        ..push('4')
        ..push('8')
        ..push(',')
        ..push('5');
      expect(editor.display, '48,5');
      expect(editor.value, Money.major(48.5));
    });

    test('не пускает вторую запятую и третий знак после неё', () {
      final editor = AmountEditor()
        ..push('1')
        ..push(',')
        ..push('2')
        ..push('5')
        ..push(',')
        ..push('9');
      expect(editor.display, '1,25');
    });

    test('лидирующий ноль заменяется, а не наращивается', () {
      final editor = AmountEditor()
        ..push('0')
        ..push('5');
      expect(editor.display, '5');
    });
  });

  group('DigitsEditor', () {
    test('группирует код активации по четыре', () {
      final editor = DigitsEditor(length: 12);
      for (final digit in '482073151129'.split('')) {
        editor.push(digit);
      }
      expect(editor.grouped, '4820 7315 1129');
      expect(editor.isComplete, isTrue);
    });

    test('не принимает цифры сверх длины', () {
      final editor = DigitsEditor(length: 4, initial: '1234')..push('5');
      expect(editor.digits, '1234');
    });
  });

  group('QR-код', () {
    const userId = '6902ef65-b544-41f9-bd99-01fcd5adae1a';
    const secret = 'testsecret';

    test('постоянный код переживает кодирование и чтение', () {
      const source = StaticQr(publicQrUuid: 'ca3ce193-70ce-49b1-aa54-d67d');
      final parsed = NurPayQr.tryParse(source.encode());

      expect(parsed, isA<StaticQr>());
      expect((parsed! as StaticQr).publicQrUuid, source.publicQrUuid);
    });

    test('платёжный код переживает кодирование и чтение', () {
      final source = PaymentQr.sign(
        userId: userId,
        maxAmount: Money.major(50),
        paymentSecret: secret,
      );
      final parsed = NurPayQr.tryParse(source.encode())! as PaymentQr;

      expect(parsed.userId, userId);
      expect(parsed.maxAmount, Money.major(50));
      expect(parsed.nonce, source.nonce);
      expect(parsed.hash, source.hash);
    });

    test('nonce — uuid v7: в нём лежит время выпуска', () {
      final qr = PaymentQr.sign(
        userId: userId,
        maxAmount: Money.major(50),
        paymentSecret: secret,
      );
      // 13-й символ uuid — номер версии.
      expect(qr.nonce[14], '7');
    });

    test('подпись совпадает с эталоном бэкенда', () {
      // Значение посчитано HMAC-SHA256 по строке
      // «<user_id>.<max_amount>.<nonce>» — той же, что проверяет сервер.
      const nonce = '019978ab-cdef-7123-8456-0123456789ab';
      expect(
        PaymentQr.signature(
          userId: userId,
          maxAmount: Money.major(50),
          nonce: nonce,
          paymentSecret: secret,
        ),
        'cde509cf25c303a134b1117cb8cf8fcf762f8b8e99b59e0adb167f817d55ff3f',
      );
    });

    test('чужой код не принимается', () {
      expect(NurPayQr.tryParse('https://example.com'), isNull);
      expect(NurPayQr.tryParse('просто текст'), isNull);
    });
  });
}
