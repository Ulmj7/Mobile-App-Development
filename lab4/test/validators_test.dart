import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/utils/validators.dart';

void main() {
  group('validateNewPassword', () {
    test('accepts a valid password', () {
      expect(validateNewPassword('Mobile318'), isNull);
      expect(validateNewPassword('abcdefg1'), isNull);
    });

    test('rejects short, digit-less, letter-less and spaced passwords', () {
      expect(validateNewPassword(null), 'Хамгийн багадаа 8 тэмдэгт');
      expect(validateNewPassword(''), 'Хамгийн багадаа 8 тэмдэгт');
      expect(validateNewPassword('Ab1'), 'Хамгийн багадаа 8 тэмдэгт');
      expect(validateNewPassword('Mobilepass'), 'Дор хаяж нэг тоо оруулна уу');
      expect(validateNewPassword('12345678'), 'Дор хаяж нэг үсэг оруулна уу');
      expect(validateNewPassword('Mobile 318'), 'Хоосон зай оруулж болохгүй');
    });

    test('exactly 8 characters is the minimum', () {
      expect(validateNewPassword('Abcdef1'), isNotNull);
      expect(validateNewPassword('Abcdefg1'), isNull);
    });
  });

  group('passwordStrength', () {
    test('empty is none', () {
      expect(passwordStrength(''), PasswordStrength.none);
    });

    test('short or single-class passwords are weak', () {
      expect(passwordStrength('abc1'), PasswordStrength.weak);
      expect(passwordStrength('abcdefgh'), PasswordStrength.weak);
    });

    test('anything under 8 characters is weak, even with every class', () {
      expect(passwordStrength('Ab1!'), PasswordStrength.weak);
      expect(passwordStrength('Ab1!xyz'), PasswordStrength.weak);
      expect(passwordStrength('Ab1!xyzw'), isNot(PasswordStrength.weak));
    });

    test('letters plus a digit, or mixed case, is medium', () {
      expect(passwordStrength('abcdefg1'), PasswordStrength.medium);
      expect(passwordStrength('Abcdefg1'), PasswordStrength.medium);
    });

    test('long mixed password with a symbol is strong', () {
      expect(passwordStrength('Mobile318-Travel!'), PasswordStrength.strong);
    });

    test('never decreases when a stronger character class is added', () {
      final order = PasswordStrength.values;
      var last = order.indexOf(passwordStrength('abcdefgh'));
      for (final next in [
        'abcdefg1',
        'Abcdefg1',
        'Abcdefg1!',
        'Abcdefg1!xyzw',
      ]) {
        final now = order.indexOf(passwordStrength(next));
        expect(now, greaterThanOrEqualTo(last), reason: next);
        last = now;
      }
    });
  });
}
