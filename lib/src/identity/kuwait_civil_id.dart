import '../core/gcc_country.dart';
import 'khaleej_id.dart';

/// State of Kuwait Civil ID (البطاقة المدنية الكويتية - PACI).
///
/// Rules:
/// - 12 digits: `CYYMMDDSSSSC`.
/// - C: Century indicator (2 for 1900-1999, 3 for 2000-2099).
/// - YYMMDD: Birth date (Year, Month, Day).
/// - SSSS: 4-digit sequence identifier.
/// - C: Check digit (12th digit).
///
/// Verification algorithm: Modulo 11 with weights:
/// `[2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]` applied to digits 0..10.
/// Sum `S = sum(digit[i] * weight[i])`. Remainder `R = S % 11`.
/// Expected check digit `C = (11 - R)`. If `R == 0`, `C = 0`. If `R == 1`, invalid per PACI.
class KuwaitCivilId extends KhaleejId {
  const KuwaitCivilId._({
    required super.raw,
    required super.isValid,
    this.birthDate,
    this.century,
    this.sequence,
    this.checkDigit,
    super.validationError,
  }) : super(country: GccCountry.kuwait);

  static const List<int> weights = [2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];

  /// Validates and parses a Kuwait Civil ID.
  factory KuwaitCivilId.parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 12) {
      return KuwaitCivilId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Kuwait Civil ID must be exactly 12 digits (got ${cleaned.length})',
      );
    }

    final centuryChar = cleaned[0];
    if (centuryChar != '2' && centuryChar != '3') {
      return KuwaitCivilId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Century indicator must be 2 (1900-1999) or 3 (2000-2099)',
      );
    }

    final century = centuryChar == '2' ? 1900 : 2000;
    final yy = int.parse(cleaned.substring(1, 3));
    final mm = int.parse(cleaned.substring(3, 5));
    final dd = int.parse(cleaned.substring(5, 7));
    final birthYear = century + yy;

    if (mm < 1 || mm > 12 || dd < 1 || dd > 31) {
      return KuwaitCivilId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Invalid birth date in Kuwait Civil ID (MM: $mm, DD: $dd)',
      );
    }

    DateTime? birthDate;
    try {
      birthDate = DateTime(birthYear, mm, dd);
    } catch (_) {
      return KuwaitCivilId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Invalid calendar date for birth date: $birthYear-$mm-$dd',
      );
    }

    // PACI Modulo 11 weighted check
    var sum = 0;
    for (var i = 0; i < 11; i++) {
      final digit = int.parse(cleaned[i]);
      sum += digit * weights[i];
    }

    final remainder = sum % 11;
    final int expectedCheckDigit;
    if (remainder == 0) {
      expectedCheckDigit = 0;
    } else if (remainder == 1) {
      // 11 - 1 = 10 (not a single decimal digit), invalid PACI remainder
      return KuwaitCivilId._(
        raw: cleaned,
        isValid: false,
        birthDate: birthDate,
        validationError: 'Invalid PACI Modulo 11 remainder (remainder=1 yields non-digit 10)',
      );
    } else {
      expectedCheckDigit = 11 - remainder;
    }

    final actualCheckDigit = int.parse(cleaned[11]);
    if (actualCheckDigit != expectedCheckDigit) {
      return KuwaitCivilId._(
        raw: cleaned,
        isValid: false,
        birthDate: birthDate,
        century: century,
        sequence: cleaned.substring(7, 11),
        checkDigit: actualCheckDigit,
        validationError:
            'Invalid Kuwait Civil ID check digit (expected $expectedCheckDigit, got $actualCheckDigit)',
      );
    }

    return KuwaitCivilId._(
      raw: cleaned,
      isValid: true,
      birthDate: birthDate,
      century: century,
      sequence: cleaned.substring(7, 11),
      checkDigit: actualCheckDigit,
    );
  }

  /// Extracted cardholder birth date.
  final DateTime? birthDate;

  /// Century base (1900 or 2000).
  final int? century;

  /// 4-digit sequence number.
  final String? sequence;

  /// Check digit (12th digit).
  final int? checkDigit;

  @override
  String get formatted {
    if (raw.length != 12) return raw;
    return '${raw.substring(0, 1)} ${raw.substring(1, 7)} ${raw.substring(7, 11)} ${raw.substring(11, 12)}';
  }

  /// Computes the PACI check digit for an 11-digit prefix. Returns null if remainder == 1.
  static int? calculateCheckDigit(String prefix11) {
    if (prefix11.length != 11 || !RegExp(r'^\d+$').hasMatch(prefix11)) return null;
    var sum = 0;
    for (var i = 0; i < 11; i++) {
      sum += int.parse(prefix11[i]) * weights[i];
    }
    final r = sum % 11;
    if (r == 0) return 0;
    if (r == 1) return null; // cannot issue
    return 11 - r;
  }

  /// Validates a Kuwait Civil ID.
  static bool validate(String input) => KuwaitCivilId.parse(input).isValid;
}
