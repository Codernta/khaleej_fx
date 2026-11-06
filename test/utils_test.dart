import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('ArabicNormalizer', () {
    test('strips Tashkeel diacritics', () {
      const text = 'مَرْحَبًا بِكُمْ فِي مَمْلَكَةِ الْخَلِيجِ';
      expect(ArabicNormalizer.stripTashkeel(text), 'مرحبا بكم في مملكة الخليج');
    });

    test('strips Tatweel (Kashida)', () {
      const text = 'ريـــــال';
      expect(ArabicNormalizer.stripTatweel(text), 'ريال');
    });

    test('normalizes Alef, Yaa, and Taa Marbuta', () {
      const text = 'أَحْمَدُ إِبْرَاهِيمَ اشْتَرَى سَيَّارَةً';
      final normalized = ArabicNormalizer.normalize(text);
      expect(normalized, 'احمد ابراهيم اشتري سياره');
    });
  });

  group('NumeralConverter', () {
    test('converts Western digits to Arabic-Indic digits', () {
      expect(NumeralConverter.toArabicIndic('1234567890'), '١٢٣٤٥٦٧٨٩٠');
      expect(
        NumeralConverter.toArabicIndic('Total: 1,250.50 SAR', convertSeparators: true),
        'Total: ١٬٢٥٠٫٥٠ SAR',
      );
    });

    test('converts Arabic-Indic digits to Western digits', () {
      expect(NumeralConverter.toWesternArabic('١٢٣٤٥٦٧٨٩٠'), '1234567890');
      expect(
        NumeralConverter.toWesternArabic('المبلغ: ١٬٢٥٠٫٥٠ ر.س', convertSeparators: true),
        'المبلغ: 1,250.50 ر.س',
      );
    });
  });

  group('AddressValidator', () {
    test('validates Saudi SPL Short Address (4 uppercase letters + 4 digits)', () {
      expect(AddressValidator.validateSplShortAddress('RRRD2929'), isTrue);
      expect(AddressValidator.validateSplShortAddress('blda8825'), isTrue); // case-insensitive
      expect(AddressValidator.validateSplShortAddress('RRD2929'), isFalse); // only 3 letters
      expect(AddressValidator.validateSplShortAddress('RRRD292'), isFalse); // only 3 digits
    });

    test('validates Saudi 5-digit postal code', () {
      expect(AddressValidator.validateSaudiPostalCode('12233'), isTrue);
      expect(AddressValidator.validateSaudiPostalCode('99999'), isFalse); // starts with 9
      expect(AddressValidator.validateSaudiPostalCode('123'), isFalse);
    });

    test('validates and formats UAE Makani 10-digit code', () {
      expect(AddressValidator.validateUaeMakani('30032 95320'), isTrue);
      expect(AddressValidator.validateUaeMakani('3003295320'), isTrue);
      expect(AddressValidator.validateUaeMakani('30032-95320'), isTrue);
      expect(AddressValidator.formatUaeMakani('3003295320'), '30032 95320');
      expect(AddressValidator.validateUaeMakani('12345'), isFalse);
    });

    test('validates Qatar Blue Plate address', () {
      expect(
        AddressValidator.validateQatarBluePlate(
          zone: 23,
          street: 840,
          building: 56,
        ),
        isTrue,
      );

      final parsed = AddressValidator.parseQatarBluePlate('23/840/56');
      expect(parsed, isNotNull);
      expect(parsed!['zone'], 23);
      expect(parsed['street'], 840);
      expect(parsed['building'], 56);

      expect(AddressValidator.parseQatarBluePlate('150/840/56'), isNull); // Zone > 99
    });
  });
}
