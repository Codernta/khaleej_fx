import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('SAMA Cybersecurity Framework PIN Policy (SamaPinValidator)', () {
    test('accepts strong financial PINs', () {
      final res4 = SamaPinValidator.validate(pin: '2849');
      expect(res4.isValid, isTrue);
      expect(res4.failureReasons, isEmpty);
      expect(res4.messageEn, contains('satisfies SAMA Cybersecurity'));

      final res6 = SamaPinValidator.validate(pin: '593817');
      expect(res6.isValid, isTrue);
    });

    test('rejects repeating identical digits (1111, 0000, 999999)', () {
      final res1 = SamaPinValidator.validate(pin: '1111');
      expect(res1.isValid, isFalse);
      expect(res1.failureReasons, contains(WeakPinReason.repeatedDigits));

      final res0 = SamaPinValidator.validate(pin: '000000');
      expect(res0.isValid, isFalse);
      expect(res0.failureReasons, contains(WeakPinReason.repeatedDigits));
    });

    test('rejects sequential ascending and descending digits (1234, 4321, 123456)', () {
      final resAsc = SamaPinValidator.validate(pin: '1234');
      expect(resAsc.isValid, isFalse);
      expect(resAsc.failureReasons, contains(WeakPinReason.sequentialDigits));

      final resDesc = SamaPinValidator.validate(pin: '4321');
      expect(resDesc.isValid, isFalse);
      expect(resDesc.failureReasons, contains(WeakPinReason.sequentialDigits));

      final res6 = SamaPinValidator.validate(pin: '654321');
      expect(res6.isValid, isFalse);
      expect(res6.failureReasons, contains(WeakPinReason.sequentialDigits));
    });

    test('rejects alternating repeating patterns (1212, 1010, 123123)', () {
      final resAlt4 = SamaPinValidator.validate(pin: '1212');
      expect(resAlt4.isValid, isFalse);
      expect(resAlt4.failureReasons, contains(WeakPinReason.alternatingPattern));

      final resAlt6 = SamaPinValidator.validate(pin: '123123');
      expect(resAlt6.isValid, isFalse);
      expect(resAlt6.failureReasons, contains(WeakPinReason.alternatingPattern));
    });

    test('rejects personal identity correlation (birth year, national ID, phone)', () {
      // Birth year 1995
      final resBirth = SamaPinValidator.validate(pin: '1995', birthYear: 1995);
      expect(resBirth.isValid, isFalse);
      expect(resBirth.failureReasons, contains(WeakPinReason.containsBirthDate));

      // National ID last 4 digits
      final resId = SamaPinValidator.validate(
        pin: '7519',
        nationalIdOrIqama: '1010107519',
      );
      expect(resId.isValid, isFalse);
      expect(resId.failureReasons, contains(WeakPinReason.matchesNationalId));

      // Mobile phone last 4 digits
      final resPhone = SamaPinValidator.validate(
        pin: '4567',
        phoneNumber: '0501234567',
      );
      expect(resPhone.isValid, isFalse);
      expect(resPhone.failureReasons, contains(WeakPinReason.matchesPhoneNumber));
    });

    test('rejects invalid length or non-numeric characters', () {
      final resShort = SamaPinValidator.validate(pin: '123');
      expect(resShort.isValid, isFalse);
      expect(resShort.failureReasons, contains(WeakPinReason.invalidLength));

      final resNonNum = SamaPinValidator.validate(pin: '12a4');
      expect(resNonNum.isValid, isFalse);
      expect(resNonNum.failureReasons, contains(WeakPinReason.nonNumeric));
    });
  });
}
