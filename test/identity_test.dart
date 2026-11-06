import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('SaudiId & Iqama (KSA)', () {
    test('validates valid 10-digit Saudi Citizen ID using Luhn', () {
      // Calculate a valid Luhn for prefix starting with 1
      const prefix = '101010101';
      final checkDigit = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final validId = '$prefix$checkDigit';

      final result = SaudiId.parse(validId);
      expect(result.isValid, isTrue);
      expect(result.idType, SaudiIdType.citizen);
      expect(result.checkDigit, checkDigit);
      expect(SaudiId.validate(validId), isTrue);
    });

    test('validates valid 10-digit Resident Iqama starting with 2', () {
      const prefix = '234567890';
      final checkDigit = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final validIqama = '$prefix$checkDigit';

      final result = SaudiId.parse(validIqama);
      expect(result.isValid, isTrue);
      expect(result.idType, SaudiIdType.residentIqama);
    });

    test('rejects IDs not starting with 1 or 2', () {
      final invalid = SaudiId.parse('3010101010');
      expect(invalid.isValid, isFalse);
      expect(invalid.validationError, contains('must start with 1 (Citizen) or 2 (Iqama)'));
    });

    test('rejects incorrect Luhn checksum', () {
      const prefix = '101010101';
      final checkDigit = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final wrongCheckDigit = (checkDigit + 1) % 10;
      final invalid = SaudiId.parse('$prefix$wrongCheckDigit');
      expect(invalid.isValid, isFalse);
      expect(invalid.validationError, contains('Invalid Luhn'));
    });

    test('rejects invalid length', () {
      expect(SaudiId.parse('12345').isValid, isFalse);
      expect(SaudiId.parse('12345678901').isValid, isFalse);
    });
  });

  group('EmiratesId (UAE)', () {
    test('validates and formats valid Emirates ID', () {
      // 784 + YYYY (1990) + 7 serial digits (1234567) + Luhn check digit
      const prefix = '78419901234567';
      final checkDigit = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final validRaw = '$prefix$checkDigit';
      final formatted = '784-1990-1234567-$checkDigit';

      final result = EmiratesId.parse(formatted);
      expect(result.isValid, isTrue);
      expect(result.birthYear, 1990);
      expect(result.serialNumber, '1234567');
      expect(result.checkDigit, checkDigit);
      expect(result.formatted, formatted);
      expect(EmiratesId.validate(validRaw), isTrue);
    });

    test('rejects IDs not starting with 784', () {
      final result = EmiratesId.parse('785-1990-1234567-1');
      expect(result.isValid, isFalse);
      expect(result.validationError, contains('must begin with country code 784'));
    });

    test('rejects invalid birth year', () {
      final result = EmiratesId.parse('784-1800-1234567-1');
      expect(result.isValid, isFalse);
      expect(result.validationError, contains('Invalid cardholder birth year'));
    });
  });

  group('KuwaitCivilId (KWT)', () {
    test('validates valid Kuwait Civil ID using PACI Modulo 11 weights', () {
      // 2 (century) + 900515 (1990-05-15) + 1234 (serial) = 11 digits
      const prefix = '29005151234';
      final checkDigit = KuwaitCivilId.calculateCheckDigit(prefix);
      expect(checkDigit, isNotNull);

      final validCivilId = '$prefix$checkDigit';
      final result = KuwaitCivilId.parse(validCivilId);
      expect(result.isValid, isTrue);
      expect(result.century, 1900);
      expect(result.birthDate, DateTime(1990, 5, 15));
      expect(result.checkDigit, checkDigit);
      expect(KuwaitCivilId.validate(validCivilId), isTrue);
    });

    test('rejects invalid birth date', () {
      // Invalid month 13
      final result = KuwaitCivilId.parse('290131512340');
      expect(result.isValid, isFalse);
      expect(result.validationError, contains('Invalid birth date'));
    });

    test('rejects incorrect check digit', () {
      const prefix = '29005151234';
      final checkDigit = KuwaitCivilId.calculateCheckDigit(prefix)!;
      final wrong = (checkDigit + 1) % 10;
      final result = KuwaitCivilId.parse('$prefix$wrong');
      expect(result.isValid, isFalse);
      expect(result.validationError, contains('Invalid Kuwait Civil ID check digit'));
    });
  });

  group('QatarId (QAT)', () {
    test('validates valid Qatar ID', () {
      // 2 (century 1900) + 90 (1990) + 634 (Qatar nationality) + 1234 (serial) = 10 digits
      const prefix = '2906341234';
      final checkDigit = QatarId.calculateCheckDigit(prefix);
      final validQid = '$prefix$checkDigit';

      final result = QatarId.parse(validQid);
      expect(result.isValid, isTrue);
      expect(result.birthYear, 1990);
      expect(result.nationalityCode, '634');
      expect(result.isQatariCitizen, isTrue);
      expect(result.checkDigit, checkDigit);
      expect(QatarId.validate(validQid), isTrue);
    });
  });

  group('BahrainCpr (BHR)', () {
    test('validates valid Bahrain CPR', () {
      // YY (90) + MM (06) + NNNN (1234) = 8 digits
      const prefix = '90061234';
      final checkDigit = BahrainCpr.calculateCheckDigit(prefix);
      final validCpr = '$prefix$checkDigit';

      final result = BahrainCpr.parse(validCpr);
      expect(result.isValid, isTrue);
      expect(result.birthMonth, 6);
      expect(result.birthYearPrefix, 90);
      expect(result.checkDigit, checkDigit);
      expect(BahrainCpr.validate(validCpr), isTrue);
    });

    test('rejects invalid month in Bahrain CPR', () {
      final result = BahrainCpr.parse('901412345');
      expect(result.isValid, isFalse);
      expect(result.validationError, contains('Invalid birth month'));
    });
  });

  group('OmanCivilId (OMN)', () {
    test('validates and normalizes 7-8 digit Omani Civil Number', () {
      final res8 = OmanCivilId.parse('12345678');
      expect(res8.isValid, isTrue);
      expect(res8.raw, '12345678');

      // 7 digits padded to 8 digits with leading zero
      final res7 = OmanCivilId.parse('1234567');
      expect(res7.isValid, isTrue);
      expect(res7.raw, '01234567');
    });

    test('rejects invalid Omani Civil Numbers', () {
      expect(OmanCivilId.parse('00000000').isValid, isFalse);
      expect(OmanCivilId.parse('1234').isValid, isFalse);
    });
  });

  group('KhaleejId Unified Parser', () {
    test('auto-detects ID by format and country', () {
      // Saudi
      const ksaPrefix = '101010101';
      final ksaCheck = ChecksumUtils.calculateLuhnCheckDigit(ksaPrefix);
      final ksaId = KhaleejId.parse('$ksaPrefix$ksaCheck');
      expect(ksaId, isA<SaudiId>());
      expect(ksaId.country, GccCountry.saudiArabia);

      // UAE
      const uaePrefix = '78419901234567';
      final uaeCheck = ChecksumUtils.calculateLuhnCheckDigit(uaePrefix);
      final uaeId = KhaleejId.parse('784-1990-1234567-$uaeCheck');
      expect(uaeId, isA<EmiratesId>());
      expect(uaeId.country, GccCountry.uae);
    });
  });
}
