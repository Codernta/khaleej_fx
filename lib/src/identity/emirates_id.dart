import '../core/gcc_country.dart';
import 'khaleej_id.dart';

/// United Arab Emirates National Identity Card (بطاقة الهوية الإماراتية).
///
/// Rules:
/// - 15 digits structured as `784-YYYY-XXXXXXX-C`.
/// - Starts with 784 (ISO numeric country code for UAE).
/// - 4-digit cardholder year of birth (YYYY).
/// - 7-digit sequential serial number (XXXXXXX).
/// - 1 Luhn (Modulo 10) check digit (C).
class EmiratesId extends KhaleejId {
  const EmiratesId._({
    required super.raw,
    required super.isValid,
    this.birthYear,
    this.serialNumber,
    this.checkDigit,
    super.validationError,
  }) : super(country: GccCountry.uae);

  /// Validates and parses an Emirates ID string.
  factory EmiratesId.parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 15) {
      return EmiratesId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Emirates ID must be exactly 15 digits (got ${cleaned.length})',
      );
    }

    if (!cleaned.startsWith('784')) {
      return EmiratesId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Emirates ID must begin with country code 784',
      );
    }

    final yearStr = cleaned.substring(3, 7);
    final birthYear = int.tryParse(yearStr);
    final currentYear = DateTime.now().year;
    if (birthYear == null || birthYear < 1900 || birthYear > currentYear + 1) {
      return EmiratesId._(
        raw: cleaned,
        isValid: false,
        birthYear: birthYear,
        validationError: 'Invalid cardholder birth year: $yearStr',
      );
    }

    final serial = cleaned.substring(7, 14);
    final checkDigit = int.tryParse(cleaned[14]);

    final isLuhnValid = ChecksumUtils.verifyLuhn(cleaned);
    if (!isLuhnValid) {
      return EmiratesId._(
        raw: cleaned,
        isValid: false,
        birthYear: birthYear,
        serialNumber: serial,
        checkDigit: checkDigit,
        validationError: 'Invalid Luhn (Modulo 10) check digit for Emirates ID',
      );
    }

    return EmiratesId._(
      raw: cleaned,
      isValid: true,
      birthYear: birthYear,
      serialNumber: serial,
      checkDigit: checkDigit,
    );
  }

  /// 4-digit cardholder year of birth.
  final int? birthYear;

  /// 7-digit sequence number.
  final String? serialNumber;

  /// Check digit (15th digit).
  final int? checkDigit;

  @override
  String get formatted {
    if (raw.length != 15) return raw;
    return '${raw.substring(0, 3)}-${raw.substring(3, 7)}-${raw.substring(7, 14)}-${raw.substring(14, 15)}';
  }

  @override
  String mask({String maskChar = '*'}) {
    if (raw.length != 15) return maskChar * raw.length;
    // Format: 784-****-***1234-1
    return '784-${maskChar * 4}-${maskChar * 3}${raw.substring(10, 14)}-${raw[14]}';
  }

  /// Validates a raw or hyphenated Emirates ID string.
  static bool validate(String input) => EmiratesId.parse(input).isValid;
}
