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

    test('redacts national IDs in Arabic-Indic numerals', () {
      const textArabic = 'المواطن ١٠١٠١٠١٠١٠ وهوية مقيم ٢٣٤٥٦٧٨٩٠١ والهوية ٧٨٤-١٩٩٠-١٢٣٤٥٦٧-١';
      final redacted = KhaleejPiiRedactor.redactText(textArabic);

      expect(redacted, contains('[REDACTED_CITIZEN_ID]'));
      expect(redacted, contains('[REDACTED_IQAMA]'));
      expect(redacted, contains('[REDACTED_EMIRATES_ID]'));
    });

    test('redacts GCC IBAN preserving country prefix and last 4, both spaced and continuous', () {
      // Continuous
      const text1 = 'Transfer to SA0380000000608010167519 immediately.';
      final redacted1 = KhaleejPiiRedactor.redactText(text1);
      expect(redacted1, contains('[REDACTED_IBAN_SA_...7519]'));
      expect(redacted1.contains('60801016'), isFalse);

      // Formatted with spaces
      const text2 = 'Invoice paid via SA03 8000 0000 6080 1016 7519 on Tuesday.';
      final redacted2 = KhaleejPiiRedactor.redactText(text2);
      expect(redacted2, contains('[REDACTED_IBAN_SA_...7519]'));
      expect(redacted2.contains('6080 1016'), isFalse);
    });

    test('redacts email addresses per PDPL regulations', () {
      const text = 'Send contract to ahmed.almansoor@fintech.sa or info@gcc-pay.ae';
      final redacted = KhaleejPiiRedactor.redactText(text);

      expect(redacted, contains('[REDACTED_EMAIL]'));
      expect(redacted.contains('ahmed.almansoor@fintech.sa'), isFalse);
      expect(redacted.contains('info@gcc-pay.ae'), isFalse);
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

    test('redacts Oman Civil ID with context prefix', () {
      const text = 'Omani resident Civil ID: 12345678 entered premises.';
      final redacted = KhaleejPiiRedactor.redactText(text);

      expect(redacted, contains('[REDACTED_OMAN_CIVIL_ID]'));
      expect(redacted.contains('12345678'), isFalse);
    });

    test('recursively sanitizes nested Maps, API keys, tokens, and sensitive headers', () {
      final payload = {
        'user': {
          'name': 'Ahmed Al-Mansoor',
          'national_id': '1010101010',
          'phone': '+966501234567',
          'email': 'ahmed@example.com',
        },
        'payment': {
          'iban': 'SA0380000000608010167519',
          'cvv': '789',
          'pin': '1234',
        },
        'security': {
          'api_key': 'ak_live_abcdef123456',
          'access_token': 'eyJh...token',
          'client_secret': 'cs_live_secret_key',
          'authorization': 'Bearer my_secret_bearer',
        },
        'tags': ['fintech', 'gcc', 'Transfer to SA03 8000 0000 6080 1016 7519'],
      };

      final sanitized = KhaleejPiiRedactor.sanitizeData(payload);

      expect(sanitized['user']['name'], 'Ahmed Al-Mansoor');
      expect(sanitized['user']['national_id'], '[REDACTED_CITIZEN_ID]');
      expect(sanitized['user']['phone'], '[REDACTED_PHONE]');
      expect(sanitized['user']['email'], '[PROTECTED_FIELD]');
      expect(sanitized['payment']['cvv'], '[PROTECTED_FIELD]');
      expect(sanitized['payment']['pin'], '[PROTECTED_FIELD]');
      expect(sanitized['security']['api_key'], '[PROTECTED_FIELD]');
      expect(sanitized['security']['access_token'], '[PROTECTED_FIELD]');
      expect(sanitized['security']['client_secret'], '[PROTECTED_FIELD]');
      expect(sanitized['security']['authorization'], '[PROTECTED_FIELD]');
      expect(sanitized['tags'][2], contains('[REDACTED_IBAN_SA_...7519]'));
    });
  });
}
