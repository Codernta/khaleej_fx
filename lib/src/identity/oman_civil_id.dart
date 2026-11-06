import '../core/gcc_country.dart';
import 'khaleej_id.dart';

/// Sultanate of Oman Civil ID (البطاقة المدنية العمانية / الرقم المدني).
///
/// Rules:
/// - 8-digit Civil Number (issued by Royal Oman Police).
/// - If 7 digits, standardly padded to 8 digits with a leading zero.
class OmanCivilId extends KhaleejId {
  const OmanCivilId._({
    required super.raw,
    required super.isValid,
    super.validationError,
  }) : super(country: GccCountry.oman);

  /// Validates and parses an Omani Civil ID string.
  factory OmanCivilId.parse(String input) {
    var cleaned = input.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length == 7) {
      cleaned = '0$cleaned';
    }

    if (cleaned.length != 8) {
      return OmanCivilId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Oman Civil ID must be 7 or 8 digits (got ${cleaned.length})',
      );
    }

    if (cleaned == '00000000') {
      return OmanCivilId._(
        raw: cleaned,
        isValid: false,
        validationError: 'Oman Civil ID cannot be all zeros',
      );
    }

    return OmanCivilId._(
      raw: cleaned,
      isValid: true,
    );
  }

  @override
  String get formatted {
    if (raw.length != 8) return raw;
    return '${raw.substring(0, 4)} ${raw.substring(4, 8)}';
  }

  /// Validates an Omani Civil ID string.
  static bool validate(String input) => OmanCivilId.parse(input).isValid;
}
