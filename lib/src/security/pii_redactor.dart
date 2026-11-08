import '../banking/iban_validator.dart';
import '../cards/card_validator.dart';
import '../utils/numeral_converter.dart';

/// Personal Identifiable Information (PII) redaction engine in compliance with
/// the Saudi Personal Data Protection Law (PDPL) and UAE Data Protection Law.
///
/// Scans arbitrary text, logs, and nested JSON/Maps to redact:
/// - National IDs (Saudi Citizen ID, Iqama, Emirates ID, Kuwait Civil ID, Qatar ID, Bahrain CPR, Oman Civil ID)
/// - GCC IBANs (both continuous and spaced/formatted)
/// - Payment Card Primary Account Numbers (PAN)
/// - Security Codes (CVV / CVC)
/// - GCC Mobile Numbers (international and domestic formats)
/// - Email addresses
/// - Sensitive API keys, session tokens, passwords, and private keys
///
/// Fully supports both Western Arabic (`0-9`) and Eastern Arabic-Indic numerals (`٠-٩`).
class KhaleejPiiRedactor {
  const KhaleejPiiRedactor._();

  // Regular expressions supporting Western and Arabic-Indic numerals
  static final RegExp _emiratesIdPattern = RegExp(
    r'(?<![0-9\u0660-\u0669\u06F0-\u06F9])(?:784|٧٨٤)[-\s]?[0-9\u0660-\u0669\u06F0-\u06F9]{4}[-\s]?[0-9\u0660-\u0669\u06F0-\u06F9]{7}[-\s]?[0-9\u0660-\u0669\u06F0-\u06F9](?![0-9\u0660-\u0669\u06F0-\u06F9])',
  );

  static final RegExp _saudiIdPattern = RegExp(
    r'(?<![0-9\u0660-\u0669\u06F0-\u06F9])(?:[12]|١|٢)[0-9\u0660-\u0669\u06F0-\u06F9]{9}(?![0-9\u0660-\u0669\u06F0-\u06F9])',
  );

  static final RegExp _kuwaitCivilIdPattern = RegExp(
    r'(?<![0-9\u0660-\u0669\u06F0-\u06F9])(?:[23]|٢|٣)[0-9\u0660-\u0669\u06F0-\u06F9]{11}(?![0-9\u0660-\u0669\u06F0-\u06F9])',
  );

  static final RegExp _qatarIdPattern = RegExp(
    r'(?<![0-9\u0660-\u0669\u06F0-\u06F9])(?:[23]|٢|٣)[0-9\u0660-\u0669\u06F0-\u06F9]{10}(?![0-9\u0660-\u0669\u06F0-\u06F9])',
  );

  static final RegExp _bahrainCprPattern = RegExp(
    r'(?<![0-9\u0660-\u0669\u06F0-\u06F9])[0-9\u0660-\u0669\u06F0-\u06F9]{2}(?:0[1-9]|1[0-2]|٠[١-٩]|١[٠-٢])[0-9\u0660-\u0669\u06F0-\u06F9]{5}(?![0-9\u0660-\u0669\u06F0-\u06F9])',
  );

  static final RegExp _omanCivilIdContextPattern = RegExp(
    r'(?:civil[\s_-]?id|oman[\s_-]?id|الرقم[\s_-]?المدني|بطاقة[\s_-]?مدنية)\s*[:#-]?\s*([0-9\u0660-\u0669\u06F0-\u06F9]{7,8})(?![0-9\u0660-\u0669\u06F0-\u06F9])',
    caseSensitive: false,
  );

  // Matches continuous or spaced/grouped GCC IBANs
  static final RegExp _gccIbanPattern = RegExp(
    r'(?<![A-Za-z0-9])(SA|AE|KW|QA|BH|OM)[\s-]?[0-9\u0660-\u0669\u06F0-\u06F9]{2}(?:[\s-]?[0-9\u0660-\u0669\u06F0-\u06F9]{2,4}){4,8}(?![0-9\u0660-\u0669\u06F0-\u06F9])',
    caseSensitive: false,
  );

  static final RegExp _panPattern = RegExp(
    r'\b(?:\d{4}[ -]\d{4}[ -]\d{4}[ -]\d{1,7}|\d{13,19})\b',
  );

  static final RegExp _gccPhonePattern = RegExp(
    r'(?:\+(?:966|971|965|974|973|968)|\b05|\b(?:966|971|965|974|973|968)|(?:\+?(?:٩٦٦|٩٧١|٩٦٥|٩٧٤|٩٧٣|٩٦٨))|٠٥)\s?[0-9\u0660-\u0669\u06F0-\u06F9]{1,3}[ -]?[0-9\u0660-\u0669\u06F0-\u06F9]{3,4}[ -]?[0-9\u0660-\u0669\u06F0-\u06F9]{3,4}\b',
  );

  static final RegExp _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  );

  static final Set<String> _sensitiveKeys = {
    // Payment Credentials
    'cvv',
    'cvc',
    'cvv2',
    'cvc2',
    'securitycode',
    'security_code',
    'pin',
    'pincode',
    'pin_code',
    'otp',
    'passcode',
    'cardnumber',
    'card_number',
    'pan',

    // Authentication & Secret Tokens
    'password',
    'secret',
    'secretkey',
    'secret_key',
    'serverkey',
    'server_key',
    'clientsecret',
    'client_secret',
    'apikey',
    'api_key',
    'token',
    'accesstoken',
    'access_token',
    'authtoken',
    'auth_token',
    'refreshtoken',
    'refresh_token',
    'authorization',
    'bearer',
    'privatekey',
    'private_key',
    'privkey',
    'encryptionkey',
    'encryption_key',
    'sharedsecret',
    'session',
    'sessionid',
    'session_id',
    'cookie',
    'jwt',
    'certificate',

    // Sensitive Identifiers & Security Keys
    'ssn',
    'taxid',
    'tax_id',
    'vatnumber',
    'vat_number',
    'email',
    'emailaddress',
  };

  /// Redacts PII in a given raw [text] string.
  static String redactText(String text) {
    if (text.isEmpty) return text;

    var sanitized = text;

    // 1. Redact Emails
    sanitized = sanitized.replaceAllMapped(_emailPattern, (m) {
      return '[REDACTED_EMAIL]';
    });

    // 2. Redact Emirates ID
    sanitized = sanitized.replaceAllMapped(_emiratesIdPattern, (m) {
      return '[REDACTED_EMIRATES_ID]';
    });

    // 3. Redact GCC IBANs (both formatted with spaces and continuous)
    sanitized = sanitized.replaceAllMapped(_gccIbanPattern, (m) {
      final matchStr = m.group(0)!;
      final western = NumeralConverter.toWesternArabic(matchStr);
      final clean = western.replaceAll(RegExp(r'\s+|-'), '').toUpperCase();
      final country = clean.substring(0, 2);
      final expectedLength = IbanValidator.gccIbanLengths[country];

      if (expectedLength != null && clean.length == expectedLength) {
        final last4 = clean.substring(clean.length - 4);
        return '[REDACTED_IBAN_${country}_...$last4]';
      }
      return matchStr;
    });

    // 4. Redact Credit/Debit Card PANs (confirm with Luhn)
    sanitized = sanitized.replaceAllMapped(_panPattern, (m) {
      final raw = m.group(0)!;
      final western = NumeralConverter.toWesternArabic(raw);
      final clean = western.replaceAll(RegExp(r'\D'), '');
      if (clean.length >= 13 && clean.length <= 19) {
        final result = CardValidator.validate(clean);
        if (result.isValidLuhn) {
          final last4 = clean.substring(clean.length - 4);
          return '[REDACTED_CARD_${result.brand.displayName}_...$last4]';
        }
      }
      return raw;
    });

    // 5. Redact Oman Civil ID with context prefix
    sanitized = sanitized.replaceAllMapped(_omanCivilIdContextPattern, (m) {
      return '${m.group(0)!.substring(0, m.group(0)!.indexOf(m.group(1)!))}[REDACTED_OMAN_CIVIL_ID]';
    });

    // 6. Redact Saudi ID & Iqama (10 digits starting with 1 or 2, in Western or Arabic numerals)
    sanitized = sanitized.replaceAllMapped(_saudiIdPattern, (m) {
      final id = NumeralConverter.toWesternArabic(m.group(0)!);
      final type = id.startsWith('1') ? 'CITIZEN_ID' : 'IQAMA';
      return '[REDACTED_$type]';
    });

    // 7. Redact Kuwait Civil ID
    sanitized = sanitized.replaceAllMapped(_kuwaitCivilIdPattern, (m) {
      return '[REDACTED_KUWAIT_CIVIL_ID]';
    });

    // 8. Redact Qatar ID
    sanitized = sanitized.replaceAllMapped(_qatarIdPattern, (m) {
      return '[REDACTED_QATAR_ID]';
    });

    // 9. Redact Bahrain CPR
    sanitized = sanitized.replaceAllMapped(_bahrainCprPattern, (m) {
      return '[REDACTED_BAHRAIN_CPR]';
    });

    // 10. Redact Phone numbers
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
