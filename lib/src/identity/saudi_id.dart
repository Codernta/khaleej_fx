import '../core/gcc_country.dart';
import 'khaleej_id.dart';

/// Type of Saudi National Identification.
enum SaudiIdType {
  /// Saudi Citizen National ID (starts with 1).
  citizen,

  /// Resident / Iqama Permit (starts with 2).
  residentIqama,

  /// Unknown or invalid identifier type.
  unknown,
}

/// Saudi Arabia National ID (الهوية الوطنية) and Resident Iqama (الإقامة).
///
/// Rules:
/// - Exactly 10 digits.
/// - Must begin with 1 (Citizen) or 2 (Resident Iqama).
/// - Validated with standard Luhn (Modulo 10) checksum.
class SaudiId extends KhaleejId {
  const SaudiId._({
    required super.raw,
    required super.isValid,
    required this.idType,
    super.validationError,
  }) : super(country: GccCountry.saudiArabia);

  /// Validates and parses a Saudi National ID or Iqama string.
  factory SaudiId.parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 10) {
      return SaudiId._(
        raw: cleaned,
        isValid: false,
        idType: SaudiIdType.unknown,
        validationError: 'Saudi ID must be exactly 10 digits (got ${cleaned.length})',
      );
    }

    final firstChar = cleaned[0];
    final SaudiIdType idType;
    if (firstChar == '1') {
      idType = SaudiIdType.citizen;
    } else if (firstChar == '2') {
      idType = SaudiIdType.residentIqama;
    } else {
      return SaudiId._(
        raw: cleaned,
        isValid: false,
        idType: SaudiIdType.unknown,
        validationError: 'Saudi ID must start with 1 (Citizen) or 2 (Iqama)',
      );
    }

    final isLuhnValid = ChecksumUtils.verifyLuhn(cleaned);
    if (!isLuhnValid) {
      return SaudiId._(
        raw: cleaned,
        isValid: false,
        idType: idType,
        validationError: 'Invalid Luhn (Modulo 10) checksum for Saudi ID',
      );
    }

    return SaudiId._(
      raw: cleaned,
      isValid: true,
      idType: idType,
    );
  }

  /// Whether this is a Saudi Citizen ID (starts with 1).
  final SaudiIdType idType;

  /// Check digit (10th digit).
  int? get checkDigit => raw.length == 10 ? int.tryParse(raw[9]) : null;

  @override
  String get formatted {
    if (raw.length != 10) return raw;
    // Standard 10-digit format
    return '${raw.substring(0, 1)} ${raw.substring(1, 5)} ${raw.substring(5, 10)}';
  }

  /// Validates a raw Saudi ID string.
  static bool validate(String input) => SaudiId.parse(input).isValid;
}
