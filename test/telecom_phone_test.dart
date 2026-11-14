import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('GCC Telecom Carrier & Phone Intelligence (KhaleejPhone)', () {
    test('identifies Saudi carriers and formats cleanly', () {
      // STC 050
      final stcPhone = KhaleejPhone.parse('+966501234567');
      expect(stcPhone.isValid, isTrue);
      expect(stcPhone.country, equals(GccCountry.saudiArabia));
      expect(stcPhone.carrier, equals(GccCarrier.stcKsa));
      expect(stcPhone.e164, equals('+966501234567'));
      expect(stcPhone.national, equals('050 123 4567'));
      expect(stcPhone.internationalFormatted, equals('+966 50 123 4567'));
      expect(stcPhone.mask(), equals('+966 50 *** 4567'));

      // Mobily 054
      final mobilyPhone = KhaleejPhone.parse('0549876543', defaultCountry: GccCountry.saudiArabia);
      expect(mobilyPhone.isValid, isTrue);
      expect(mobilyPhone.carrier, equals(GccCarrier.mobily));

      // Zain 058
      final zainPhone = KhaleejPhone.parse('00966581112233');
      expect(zainPhone.isValid, isTrue);
      expect(zainPhone.carrier, equals(GccCarrier.zainKsa));

      // Virgin Mobile 0570
      final virginPhone = KhaleejPhone.parse('+966570123456');
      expect(virginPhone.isValid, isTrue);
      expect(virginPhone.carrier, equals(GccCarrier.virginMobileKsa));
    });

    test('identifies UAE carriers and formats cleanly', () {
      // e& / Etisalat 050
      final etisalat = KhaleejPhone.parse('+971501234567');
      expect(etisalat.isValid, isTrue);
      expect(etisalat.country, equals(GccCountry.uae));
      expect(etisalat.carrier, equals(GccCarrier.etisalatUae));
      expect(etisalat.national, equals('050 123 4567'));

      // du 055
      final duPhone = KhaleejPhone.parse('0559876543', defaultCountry: GccCountry.uae);
      expect(duPhone.isValid, isTrue);
      expect(duPhone.carrier, equals(GccCarrier.du));
    });

    test('identifies Kuwait, Qatar, Bahrain, and Oman carriers', () {
      // Kuwait Zain (9)
      final kwPhone = KhaleejPhone.parse('+96591234567');
      expect(kwPhone.isValid, isTrue);
      expect(kwPhone.carrier, equals(GccCarrier.zainKuwait));

      // Qatar Ooredoo (5)
      final qaPhone = KhaleejPhone.parse('+97451234567');
      expect(qaPhone.isValid, isTrue);
      expect(qaPhone.carrier, equals(GccCarrier.ooredooQatar));

      // Bahrain Batelco (39)
      final bhPhone = KhaleejPhone.parse('+97339123456');
      expect(bhPhone.isValid, isTrue);
      expect(bhPhone.carrier, equals(GccCarrier.batelco));

      // Oman Omantel (91)
      final omPhone = KhaleejPhone.parse('+96891234567');
      expect(omPhone.isValid, isTrue);
      expect(omPhone.carrier, equals(GccCarrier.omantel));
    });

    test('normalizes Arabic-Indic numerals in phone numbers', () {
      final arabicPhone = KhaleejPhone.parse('٠٥٠١٢٣٤٥٦٧', defaultCountry: GccCountry.saudiArabia);
      expect(arabicPhone.isValid, isTrue);
      expect(arabicPhone.e164, equals('+966501234567'));
    });

    test('rejects numbers with invalid lengths or prefixes', () {
      final invalidSaudi = KhaleejPhone.parse('+966401234567'); // Starts with 4 instead of 5
      expect(invalidSaudi.isValid, isFalse);

      final tooShort = KhaleejPhone.parse('+96650123');
      expect(tooShort.isValid, isFalse);
    });
  });
}
