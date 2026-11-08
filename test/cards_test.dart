import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('Payment Cards & GCC Domestic Switches', () {
    test('detects and validates Saudi Mada card with Luhn', () {
      // 417633 is a known Saudi Mada BIN
      const prefix = '417633000000000';
      final check = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final pan = '$prefix$check';

      final result = CardValidator.validate(pan);
      expect(result.isValid, isTrue);
      expect(result.isValidLuhn, isTrue);
      expect(result.brand, CardBrand.mada);
      expect(result.domesticSwitch, GccDomesticSwitch.mada);
      expect(result.issuingCountry, GccCountry.saudiArabia);
    });

    test('detects UAE Jaywan / Mercury domestic card', () {
      const prefix = '654321000000000';
      final check = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final pan = '$prefix$check';

      final result = CardValidator.validate(pan);
      expect(result.isValid, isTrue);
      expect(result.brand, CardBrand.jaywan);
      expect(result.domesticSwitch, GccDomesticSwitch.jaywan);
      expect(result.issuingCountry, GccCountry.uae);
    });

    test('detects Kuwait KNET domestic debit card', () {
      const prefix = '589160000000000';
      final check = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final pan = '$prefix$check';

      final result = CardValidator.validate(pan);
      expect(result.isValid, isTrue);
      expect(result.brand, CardBrand.knet);
      expect(result.domesticSwitch, GccDomesticSwitch.knet);
      expect(result.issuingCountry, GccCountry.kuwait);
    });

    test('detects Bahrain Benefit domestic debit card', () {
      const prefix = '508123000000000';
      final check = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final pan = '$prefix$check';

      final result = CardValidator.validate(pan);
      expect(result.isValid, isTrue);
      expect(result.brand, CardBrand.benefit);
      expect(result.domesticSwitch, GccDomesticSwitch.benefit);
      expect(result.issuingCountry, GccCountry.bahrain);
    });

    test('detects Qatar Himyan domestic card', () {
      const prefix = '500109000000000';
      final check = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final pan = '$prefix$check';

      final result = CardValidator.validate(pan);
      expect(result.isValid, isTrue);
      expect(result.brand, CardBrand.himyan);
      expect(result.domesticSwitch, GccDomesticSwitch.himyan);
      expect(result.issuingCountry, GccCountry.qatar);
    });

    test('detects Oman OmanNet domestic card', () {
      const prefix = '508170000000000';
      final check = ChecksumUtils.calculateLuhnCheckDigit(prefix);
      final pan = '$prefix$check';

      final result = CardValidator.validate(pan);
      expect(result.isValid, isTrue);
      expect(result.brand, CardBrand.omanNet);
      expect(result.domesticSwitch, GccDomesticSwitch.omanNet);
      expect(result.issuingCountry, GccCountry.oman);
    });

    test('detects international Visa and Mastercard', () {
      // Visa
      const visaPrefix = '400000123456789';
      final visaCheck = ChecksumUtils.calculateLuhnCheckDigit(visaPrefix);
      final visaPan = '$visaPrefix$visaCheck';
      final visaResult = CardValidator.validate(visaPan);
      expect(visaResult.brand, CardBrand.visa);

      // Mastercard
      const mcPrefix = '550000123456789';
      final mcCheck = ChecksumUtils.calculateLuhnCheckDigit(mcPrefix);
      final mcPan = '$mcPrefix$mcCheck';
      final mcResult = CardValidator.validate(mcPan);
      expect(mcResult.brand, CardBrand.mastercard);
    });

    test('rejects card failing Luhn check', () {
      const badPan = '4176330000000009'; // Invalid check digit
      final result = CardValidator.validate(badPan);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Invalid Luhn'));
    });
  });

  group('PCI DSS 4.0 Compliant Card Masking', () {
    test('standard masking preserves last 4 digits only', () {
      final masked = CardMasker.mask(
        '4176330000001234',
        preserveBin: false,
        maskChar: 'X',
        delimiter: ' ',
      );
      expect(masked, 'XXXX XXXX XXXX 1234');
    });

    test('preserveBin preserves first 6 digits (BIN) and last 4 digits', () {
      final masked = CardMasker.mask(
        '4176330000001234',
        preserveBin: true,
        maskChar: 'X',
        delimiter: ' ',
      );
      expect(masked, '4176 33XX XXXX 1234');
    });

    test('custom delimiter and mask char (*)', () {
      final masked = CardMasker.mask(
        '4176330000001234',
        preserveBin: true,
        maskChar: '*',
        delimiter: '-',
      );
      expect(masked, '4176-33**-****-1234');
    });

    test('masks short tokens and CVVs without exposing plaintext', () {
      expect(CardMasker.mask('1234', maskChar: 'X'), 'XXXX');
      expect(CardMasker.mask('123', maskChar: 'X'), 'XXX');
      expect(CardMasker.maskCvv('789'), '•••');
      expect(CardMasker.maskCvv('1234', maskChar: '*'), '****');
    });
  });
}
