import '../core/gcc_country.dart';
import 'khaleej_id.dart';

/// State of Qatar Identity Card (البطاقة الشخصية القطرية - QID).
///
/// Rules:
/// - 11 digits: `CYYNNNXXXXC`.
/// - C: Century indicator (2 for 1900-1999, 3 for 2000-2099).
/// - YY: 2-digit birth year.
/// - NNN: 3-digit ISO numeric nationality code (e.g. 634 for Qatari).
/// - XXXX: 4-digit sequential serial.
/// - C: 1-digit checksum.
class QatarId extends KhaleejId {
  const QatarId._({
    required super.raw,
    required super.isValid,
    this.birthYear,
    this.nationalityCode,
    this.serialNumber,
    this.checkDigit,
    super.validationError,
  }) : super(country: GccCountry.qatar);

  static const List<int> weights = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  /// Validates and parses a Qatar ID string.
  factory QatarId.parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 11) {
      return QatarId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Qatar ID must be exactly 11 digits (got ${cleaned.length})',
      );
    }

    final centuryChar = cleaned[0];
    if (centuryChar != '2' && centuryChar != '3') {
      return QatarId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Century indicator must be 2 (1900-1999) or 3 (2000-2099)',
      );
    }

    final centuryBase = centuryChar == '2' ? 1900 : 2000;
    final yy = int.parse(cleaned.substring(1, 3));
    final birthYear = centuryBase + yy;
    final nationalityCode = cleaned.substring(3, 6);
    final serialNumber = cleaned.substring(6, 10);
    final checkDigit = int.parse(cleaned[10]);

    // Modulo 11 verification
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += int.parse(cleaned[i]) * weights[i];
    }
    final expectedCheckDigit = (sum % 11) % 10;

    if (checkDigit != expectedCheckDigit) {
      return QatarId._(
        raw: cleaned,
        isValid: false,
        birthYear: birthYear,
        nationalityCode: nationalityCode,
        serialNumber: serialNumber,
        checkDigit: checkDigit,
        validationError:
            'Invalid Qatar ID check digit (expected $expectedCheckDigit, got $checkDigit)',
      );
    }

    return QatarId._(
      raw: cleaned,
      isValid: true,
      birthYear: birthYear,
      nationalityCode: nationalityCode,
      serialNumber: serialNumber,
      checkDigit: checkDigit,
    );
  }

  /// 4-digit cardholder birth year.
  final int? birthYear;

  /// 3-digit ISO numeric country code for nationality (e.g. '634' for Qatar).
  final String? nationalityCode;

  /// Whether the cardholder is a Qatari citizen (nationality code '634').
  bool get isQatariCitizen => nationalityCode == '634';

  /// 4-digit serial number.
  final String? serialNumber;

  /// Check digit (11th digit).
  final int? checkDigit;

  @override
  String get formatted {
    if (raw.length != 11) return raw;
    return '${raw.substring(0, 3)} ${raw.substring(3, 6)} ${raw.substring(6, 11)}';
  }

  @override
  String mask({String maskChar = '*'}) {
    if (raw.length != 11) return maskChar * raw.length;
    // Format: 2********34
    return '${raw[0]}${maskChar * 8}${raw.substring(9)}';
  }

  /// Computes the check digit for a 10-digit Qatar ID prefix.
  static int calculateCheckDigit(String prefix10) {
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += int.parse(prefix10[i]) * weights[i];
    }
    return (sum % 11) % 10;
  }

  /// Validates a Qatar ID string.
  static bool validate(String input) => QatarId.parse(input).isValid;
}
