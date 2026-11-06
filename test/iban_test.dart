import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('IbanValidator - ISO 13616 & ISO 7064 Mod 97-10', () {
    test('validates and parses authentic Saudi Arabia (SA) IBAN', () {
      // SAMA Al Rajhi Bank (80)
      const rawIban = 'SA0380000000608010167519';
      final result = IbanValidator.validate(rawIban);

      expect(result.isValid, isTrue);
      expect(result.country, GccCountry.saudiArabia);
      expect(result.checkDigits, '03');
      expect(result.bankCode, '80');
      expect(result.bankInfo, isNotNull);
      expect(result.bankInfo!.shortName, 'Al Rajhi');
      expect(result.bankInfo!.bic, 'RJHISARI');
      expect(result.accountNumber, '000000608010167519');
      expect(result.formatted, 'SA03 8000 0000 6080 1016 7519');
    });

    test('validates and parses UAE (AE) IBAN', () {
      // First Abu Dhabi Bank (035)
      // Generate valid check digits for AE, 035, account
      final checkDigits = IbanValidator.calculateCheckDigits(
        country: GccCountry.uae,
        bankCode: '035',
        accountNumber: '1234567890123456',
      );
      final aeIban = 'AE$checkDigits' '0351234567890123456';

      final result = IbanValidator.validate(aeIban);
      expect(result.isValid, isTrue);
      expect(result.country, GccCountry.uae);
      expect(result.bankCode, '035');
      expect(result.bankInfo!.shortName, 'FAB');
      expect(result.accountNumber, '1234567890123456');
    });

    test('validates and parses Kuwait (KW) IBAN (30 chars)', () {
      // National Bank of Kuwait (NBOK)
      final kwIban = IbanValidator.generateIban(
        country: GccCountry.kuwait,
        bankCode: 'NBOK',
        accountNumber: '0000000000001234567890',
      );
      expect(kwIban.length, 30);

      final result = IbanValidator.validate(kwIban);
      expect(result.isValid, isTrue);
      expect(result.country, GccCountry.kuwait);
      expect(result.bankCode, 'NBOK');
      expect(result.bankInfo!.shortName, 'NBK');
      expect(result.bankInfo!.bic, 'NBOKKWKW');
    });

    test('validates and parses Qatar (QA) IBAN (29 chars)', () {
      // Qatar National Bank (QNBA)
      final qaIban = IbanValidator.generateIban(
        country: GccCountry.qatar,
        bankCode: 'QNBA',
        accountNumber: '000000000001234567890',
      );
      expect(qaIban.length, 29);

      final result = IbanValidator.validate(qaIban);
      expect(result.isValid, isTrue);
      expect(result.country, GccCountry.qatar);
      expect(result.bankCode, 'QNBA');
      expect(result.bankInfo!.shortName, 'QNB');
    });

    test('validates and parses Bahrain (BH) IBAN (22 chars)', () {
      // National Bank of Bahrain (NBOB)
      final bhIban = IbanValidator.generateIban(
        country: GccCountry.bahrain,
        bankCode: 'NBOB',
        accountNumber: '00001234567890',
      );
      expect(bhIban.length, 22);

      final result = IbanValidator.validate(bhIban);
      expect(result.isValid, isTrue);
      expect(result.country, GccCountry.bahrain);
      expect(result.bankCode, 'NBOB');
      expect(result.bankInfo!.shortName, 'NBB');
    });

    test('validates and parses Oman (OM) IBAN (23 chars)', () {
      // Bank Muscat (BMU)
      final omIban = IbanValidator.generateIban(
        country: GccCountry.oman,
        bankCode: 'BMU',
        accountNumber: '0000123456789012',
      );
      expect(omIban.length, 23);

      final result = IbanValidator.validate(omIban);
      expect(result.isValid, isTrue);
      expect(result.country, GccCountry.oman);
      expect(result.bankCode, 'BMU');
      expect(result.bankInfo!.shortName, 'Bank Muscat');
    });

    test('rejects corrupted check digits (Mod 97 failure)', () {
      // Altered check digits
      const corrupted = 'SA9980000000608010167519';
      final result = IbanValidator.validate(corrupted);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Invalid ISO 7064 Mod 97-10 checksum'));
    });

    test('rejects incorrect length for country', () {
      const tooShort = 'SA03800000006080101675';
      final result = IbanValidator.validate(tooShort);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Invalid IBAN length'));
    });

    test('formats IBAN with 4-character spaces', () {
      expect(
        IbanValidator.format('SA0380000000608010167519'),
        'SA03 8000 0000 6080 1016 7519',
      );
    });

    test('constant-time confirmIban works correctly and ignores spacing', () {
      expect(
        IbanValidator.confirmIban(
          'SA03 8000 0000 6080 1016 7519',
          'SA0380000000608010167519',
        ),
        isTrue,
      );
      expect(
        IbanValidator.confirmIban(
          'SA03 8000 0000 6080 1016 7519',
          'SA03 8000 0000 6080 1016 7520',
        ),
        isFalse,
      );
    });
  });
}
