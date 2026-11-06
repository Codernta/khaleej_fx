import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('KhaleejPiiRedactor - PDPL Compliance', () {
    test('redacts Emirates ID in free text', () {
      const text = 'User holds Emirates ID 784-1990-1234567-1 for verification.';
      final redacted = KhaleejPiiRedactor.redactText(text);

      expect(redacted, contains('[REDACTED_EMIRATES_ID]'));
      expect(redacted.contains('784-1990-1234567-1'), isFalse);
    });

    test('redacts Saudi Citizen ID and Iqama in free text', () {
      const text = 'Saudi Citizen 1010101010 and Resident 2345678901 requested support.';
      final redacted = KhaleejPiiRedactor.redactText(text);

      expect(redacted, contains('[REDACTED_CITIZEN_ID]'));
      expect(redacted, contains('[REDACTED_IQAMA]'));
      expect(redacted.contains('1010101010'), isFalse);
      expect(redacted.contains('2345678901'), isFalse);
    });

    test('redacts GCC IBAN preserving country prefix and last 4', () {
      const text = 'Transfer to SA0380000000608010167519 immediately.';
      final redacted = KhaleejPiiRedactor.redactText(text);

      expect(redacted, contains('[REDACTED_IBAN_SA_...7519]'));
      expect(redacted.contains('60801016'), isFalse);
    });

    test('redacts payment card PANs with Luhn check', () {
      const panPrefix = '417633000000000';
      final check = ChecksumUtils.calculateLuhnCheckDigit(panPrefix);
      final pan = '$panPrefix$check';

      final text = 'Charged Mada card $pan for purchase.';
      final redacted = KhaleejPiiRedactor.redactText(text);

      expect(redacted, contains('[REDACTED_CARD_Mada_...'));
      expect(redacted.contains('417633000000'), isFalse);
    });

    test('redacts GCC phone numbers', () {
      const text = 'Call client on +966 50 123 4567 or +971 50 987 6543.';
      final redacted = KhaleejPiiRedactor.redactText(text);

      expect(redacted, contains('[REDACTED_PHONE]'));
    });

    test('recursively sanitizes nested Maps and sensitive keys', () {
      final payload = {
        'user': {
          'name': 'Ahmed Al-Mansoor',
          'national_id': '1010101010',
          'phone': '+966501234567',
        },
        'payment': {
          'iban': 'SA0380000000608010167519',
          'cvv': '789',
          'pin': '1234',
        },
        'tags': ['fintech', 'gcc', 'Transfer to SA0380000000608010167519'],
      };

      final sanitized = KhaleejPiiRedactor.sanitizeData(payload);

      expect(sanitized['user']['name'], 'Ahmed Al-Mansoor');
      expect(sanitized['user']['national_id'], '[REDACTED_CITIZEN_ID]');
      expect(sanitized['user']['phone'], '[REDACTED_PHONE]');
      expect(sanitized['payment']['cvv'], '[PROTECTED_FIELD]');
      expect(sanitized['payment']['pin'], '[PROTECTED_FIELD]');
      expect(sanitized['tags'][2], contains('[REDACTED_IBAN_SA_...7519]'));
    });
  });
}
