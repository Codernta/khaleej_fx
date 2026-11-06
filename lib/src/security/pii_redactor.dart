import '../cards/card_validator.dart';

/// Personal Identifiable Information (PII) redaction engine in compliance with
/// the Saudi Personal Data Protection Law (PDPL) and UAE Data Protection Law.
///
/// Scans arbitrary text, logs, and nested JSON/Maps to redact:
/// - National IDs (Saudi Citizen ID, Iqama, Emirates ID, Kuwait Civil ID, Qatar ID, Bahrain CPR)
/// - GCC IBANs
/// - Payment Card Primary Account Numbers (PAN)
/// - Security Codes (CVV / CVC)
/// - GCC Mobile Numbers
class KhaleejPiiRedactor {
  const KhaleejPiiRedactor._();

  // Regular expressions
  static final RegExp _emiratesIdPattern = RegExp(
    r'\b784[-\s]?\d{4}[-\s]?\d{7}[-\s]?\d\b',
  );

  static final RegExp _saudiIdPattern = RegExp(
    r'\b[12]\d{9}\b',
  );

  static final RegExp _kuwaitCivilIdPattern = RegExp(
    r'\b[23]\d{11}\b',
  );

  static final RegExp _qatarIdPattern = RegExp(
    r'\b[23]\d{10}\b',
  );

  static final RegExp _bahrainCprPattern = RegExp(
    r'\b\d{2}(0[1-9]|1[0-2])\d{5}\b',
  );

  static final RegExp _gccIbanPattern = RegExp(
    r'\b(SA\d{22}|AE\d{21}|KW\d{28}|QA\d{27}|BH\d{20}|OM\d{21})\b',
    caseSensitive: false,
  );

  static final RegExp _panPattern = RegExp(
    r'\b(?:\d{4}[ -]\d{4}[ -]\d{4}[ -]\d{1,7}|\d{13,19})\b',
  );

  static final RegExp _gccPhonePattern = RegExp(
    r'(?:\+(?:966|971|965|974|973|968)|\b05|\b(?:966|971|965|974|973|968))\s?\d{1,3}[ -]?\d{3,4}[ -]?\d{3,4}\b',
  );

  static final Set<String> _sensitiveKeys = {
    'cvv',
    'cvc',
    'security_code',
    'securitycode',
    'pin',
    'otp',
    'password',
    'secret',
    'private_key',
    'token',
    'card_number',
    'pan',
  };

  /// Redacts PII in a given raw [text] string.
  static String redactText(String text) {
    if (text.isEmpty) return text;

    var sanitized = text;

    // 1. Redact Emirates ID
    sanitized = sanitized.replaceAllMapped(_emiratesIdPattern, (m) {
      return '[REDACTED_EMIRATES_ID]';
    });

    // 2. Redact GCC IBANs
    sanitized = sanitized.replaceAllMapped(_gccIbanPattern, (m) {
      final iban = m.group(0)!;
      final country = iban.substring(0, 2).toUpperCase();
      final last4 = iban.substring(iban.length - 4);
      return '[REDACTED_IBAN_${country}_...$last4]';
    });

    // 3. Redact Credit/Debit Card PANs (confirm with Luhn)
    sanitized = sanitized.replaceAllMapped(_panPattern, (m) {
      final raw = m.group(0)!;
      final clean = raw.replaceAll(RegExp(r'\D'), '');
      if (clean.length >= 13 && clean.length <= 19) {
        final result = CardValidator.validate(clean);
        if (result.isValidLuhn) {
          final last4 = clean.substring(clean.length - 4);
          return '[REDACTED_CARD_${result.brand.displayName}_...$last4]';
        }
      }
      return raw;
    });

    // 4. Redact Saudi ID & Iqama (10 digits starting with 1 or 2)
    sanitized = sanitized.replaceAllMapped(_saudiIdPattern, (m) {
      final id = m.group(0)!;
      final type = id.startsWith('1') ? 'CITIZEN_ID' : 'IQAMA';
      return '[REDACTED_$type]';
    });

    // 5. Redact Kuwait Civil ID
    sanitized = sanitized.replaceAllMapped(_kuwaitCivilIdPattern, (m) {
      return '[REDACTED_KUWAIT_CIVIL_ID]';
    });

    // 6. Redact Qatar ID
    sanitized = sanitized.replaceAllMapped(_qatarIdPattern, (m) {
      return '[REDACTED_QATAR_ID]';
    });

    // 7. Redact Bahrain CPR
    sanitized = sanitized.replaceAllMapped(_bahrainCprPattern, (m) {
      return '[REDACTED_BAHRAIN_CPR]';
    });

    // 8. Redact Phone numbers
    sanitized = sanitized.replaceAllMapped(_gccPhonePattern, (m) {
      return '[REDACTED_PHONE]';
    });

    return sanitized;
  }

  /// Recursively sanitizes nested dynamic data (Maps, Lists, and primitive values).
  static dynamic sanitizeData(dynamic data) {
    if (data is Map) {
      final result = <String, dynamic>{};
      for (final entry in data.entries) {
        final keyStr = entry.key.toString();
        final lowerKey = keyStr.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

        if (_sensitiveKeys.contains(lowerKey)) {
          result[keyStr] = '[PROTECTED_FIELD]';
        } else {
          result[keyStr] = sanitizeData(entry.value);
        }
      }
      return result;
    } else if (data is List) {
      return data.map((item) => sanitizeData(item)).toList();
    } else if (data is String) {
      return redactText(data);
    } else {
      return data;
    }
  }
}
