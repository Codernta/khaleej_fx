import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('Saudi Commercial Registration (SaudiCr)', () {
    test('validates authentic Saudi CR numbers with known city codes', () {
      final crRiyadh = SaudiCr.parse('1010123456');
      expect(crRiyadh.isValid, isTrue);
      expect(crRiyadh.cityCode, equals('1010'));
      expect(crRiyadh.cityNameEn, equals('Riyadh'));
      expect(crRiyadh.cityNameAr, equals('الرياض'));
      expect(crRiyadh.formatted, equals('1010-123456'));
      expect(crRiyadh.mask(), equals('1010****56'));

      final crJeddah = SaudiCr.parse('4030999888');
      expect(crJeddah.isValid, isTrue);
      expect(crJeddah.cityNameEn, equals('Jeddah'));

      final crDammam = SaudiCr.parse('2050111222');
      expect(crDammam.isValid, isTrue);
      expect(crDammam.cityNameEn, equals('Dammam'));
    });

    test('rejects CR with invalid length or repeating digits', () {
      final shortCr = SaudiCr.parse('1010123');
      expect(shortCr.isValid, isFalse);
      expect(shortCr.validationError, contains('10 numeric digits'));

      final repeatedCr = SaudiCr.parse('1111111111');
      expect(repeatedCr.isValid, isFalse);
      expect(repeatedCr.validationError, contains('repeated identical digits'));
    });
  });

  group('Saudi 700 Number (Saudi700Number)', () {
    test('validates authentic Saudi 700 Unified Establishment Numbers', () {
      final s700 = Saudi700Number.parse('7001234567');
      expect(s700.isValid, isTrue);
      expect(s700.formatted, equals('700 123 4567'));
      expect(s700.mask(), equals('700****567'));
    });

    test('rejects 700 numbers not starting with 700 or having invalid length', () {
      final wrongPrefix = Saudi700Number.parse('8001234567');
      expect(wrongPrefix.isValid, isFalse);
      expect(wrongPrefix.validationError, contains('prefix 700'));

      final allZeros = Saudi700Number.parse('7000000000');
      expect(allZeros.isValid, isFalse);
    });
  });

  group('UAE Tax Registration Number (UaeTrn)', () {
    test('validates authentic UAE FTA 15-digit TRNs', () {
      final trn = UaeTrn.parse('100123456780003');
      expect(trn.isValid, isTrue);
      expect(trn.formatted, equals('100 1234 5678 0003'));
      expect(trn.formattedWithHyphens, equals('100-1234-5678-0003'));
      expect(trn.mask(), equals('100-****-****-0003'));
    });

    test('rejects TRNs not starting with 100 or not ending with 3', () {
      final wrongPrefix = UaeTrn.parse('200123456780003');
      expect(wrongPrefix.isValid, isFalse);

      final wrongSuffix = UaeTrn.parse('100123456780004');
      expect(wrongSuffix.isValid, isFalse);
    });
  });

  group('KhaleejBusinessId Unified Discriminator', () {
    test('auto-detects entity types by structure', () {
      final b1 = KhaleejBusinessId.parse('100123456780003');
      expect(b1.type, equals(KhaleejBusinessIdType.uaeTrn));
      expect(b1.country, equals(GccCountry.uae));
      expect(b1.isValid, isTrue);

      final b2 = KhaleejBusinessId.parse('7009876543');
      expect(b2.type, equals(KhaleejBusinessIdType.saudi700));
      expect(b2.country, equals(GccCountry.saudiArabia));
      expect(b2.isValid, isTrue);

      final b3 = KhaleejBusinessId.parse('1010654321');
      expect(b3.type, equals(KhaleejBusinessIdType.saudiCr));
      expect(b3.country, equals(GccCountry.saudiArabia));
      expect(b3.isValid, isTrue);
    });
  });
}
