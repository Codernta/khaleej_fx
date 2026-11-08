import '../core/gcc_country.dart';
import 'khaleej_id.dart';

/// Kingdom of Bahrain Central Population Registry number (بطاقة الهوية / رقم السجل السكاني - CPR).
///
/// Rules:
/// - Exactly 9 digits: `YYMMNNNNC`.
/// - YY: 2-digit birth year.
/// - MM: 2-digit birth month (01..12).
/// - NNNN: 4-digit sequence number.
/// - C: 1-digit checksum verified via Modulo 11 weighted algorithm.
class BahrainCpr extends KhaleejId {
  const BahrainCpr._({
    required super.raw,
    required super.isValid,
    this.birthMonth,
    this.birthYearPrefix,
    this.sequence,
    this.checkDigit,
    super.validationError,
  }) : super(country: GccCountry.bahrain);

  static const List<int> weights = [1, 2, 3, 4, 5, 6, 7, 8];

  /// Validates and parses a Bahrain CPR string.
  factory BahrainCpr.parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 9) {
      return BahrainCpr._(
        raw: cleaned,
        isValid: false,
        validationError: 'Bahrain CPR must be exactly 9 digits (got ${cleaned.length})',
      );
    }

    final yy = int.parse(cleaned.substring(0, 2));
    final mm = int.parse(cleaned.substring(2, 4));

    if (mm < 1 || mm > 12) {
      return BahrainCpr._(
        raw: cleaned,
        isValid: false,
        validationError: 'Invalid birth month in Bahrain CPR: $mm (must be 01..12)',
      );
    }

    // Modulo 11 verification
    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += int.parse(cleaned[i]) * weights[i];
    }
    final expectedCheckDigit = (sum % 11) % 10;
    final checkDigit = int.parse(cleaned[8]);

    if (checkDigit != expectedCheckDigit) {
      return BahrainCpr._(
        raw: cleaned,
        isValid: false,
        birthMonth: mm,
        birthYearPrefix: yy,
        sequence: cleaned.substring(4, 8),
        checkDigit: checkDigit,
        validationError:
            'Invalid Bahrain CPR check digit (expected $expectedCheckDigit, got $checkDigit)',
      );
    }

    return BahrainCpr._(
      raw: cleaned,
      isValid: true,
      birthMonth: mm,
      birthYearPrefix: yy,
      sequence: cleaned.substring(4, 8),
      checkDigit: checkDigit,
    );
  }

  /// 2-digit birth month (1..12).
  final int? birthMonth;

  /// 2-digit birth year prefix.
  final int? birthYearPrefix;

  /// 4-digit sequence number.
  final String? sequence;

  /// Check digit (9th digit).
  final int? checkDigit;

  @override
  String get formatted {
    if (raw.length != 9) return raw;
    return '${raw.substring(0, 4)} ${raw.substring(4, 8)} ${raw.substring(8, 9)}';
  }

  @override
  String mask({String maskChar = '*'}) {
    if (raw.length != 9) return maskChar * raw.length;
    // Format: 90*****34
    return '${raw.substring(0, 2)}${maskChar * 5}${raw.substring(7)}';
  }

  /// Computes the check digit for an 8-digit Bahrain CPR prefix.
  static int calculateCheckDigit(String prefix8) {
    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += int.parse(prefix8[i]) * weights[i];
    }
    return (sum % 11) % 10;
  }

  /// Validates a Bahrain CPR string.
  static bool validate(String input) => BahrainCpr.parse(input).isValid;
}
