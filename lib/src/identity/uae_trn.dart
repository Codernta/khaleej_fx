import '../core/gcc_country.dart';

/// Represents a UAE Federal Tax Authority (FTA) Tax Registration Number (TRN / رقم التسجيل الضريبي).
///
/// Mandatory for UAE Corporate Tax and Value Added Tax (VAT) reporting.
/// A valid TRN consists of 15 numeric digits starting with `100` and typically ending in `3`
/// (standard VAT registrant check suffix `00003`).
class UaeTrn {
  const UaeTrn._({
    required this.raw,
    required this.isValid,
    this.validationError,
  });

  /// The raw 15-digit TRN string.
  final String raw;

  /// Whether the TRN satisfies FTA structure and length rules.
  final bool isValid;

  /// Explanatory error message if invalid, or null if valid.
  final String? validationError;

  /// Issuing country (always UAE).
  GccCountry get country => GccCountry.uae;

  /// Formatted TRN with standard FTA 3-4-4-4 spacing (e.g. `100 1234 5678 0003`).
  String get formatted {
    if (raw.length != 15) return raw;
    return '${raw.substring(0, 3)} ${raw.substring(3, 7)} ${raw.substring(7, 11)} ${raw.substring(11)}';
  }

  /// Formatted TRN with hyphens (e.g. `100-1234-5678-0003`).
  String get formattedWithHyphens {
    if (raw.length != 15) return raw;
    return '${raw.substring(0, 3)}-${raw.substring(3, 7)}-${raw.substring(7, 11)}-${raw.substring(11)}';
  }

  /// Returns a privacy-compliant masked representation (e.g. `100-****-****-0003`).
  String mask({String maskChar = '*'}) {
    if (raw.length != 15) return raw;
    return '${raw.substring(0, 3)}-${maskChar * 4}-${maskChar * 4}-${raw.substring(11)}';
  }

  /// Parses and validates a UAE Tax Registration Number (TRN).
  factory UaeTrn.parse(String input) {
    final clean = input.replaceAll(RegExp(r'\D'), '');

    if (clean.length != 15) {
      return UaeTrn._(
        raw: clean,
        isValid: false,
        validationError:
            'UAE TRN must be exactly 15 numeric digits, received ${clean.length}.',
      );
    }

    if (!clean.startsWith('100')) {
      return UaeTrn._(
        raw: clean,
        isValid: false,
        validationError:
            'UAE TRN issued by the Federal Tax Authority must begin with prefix 100.',
      );
    }

    if (!clean.endsWith('3')) {
      return UaeTrn._(
        raw: clean,
        isValid: false,
        validationError:
            'UAE TRN must end with standard tax registrant checksum digit 3.',
      );
    }

    return UaeTrn._(
      raw: clean,
      isValid: true,
    );
  }

  @override
  String toString() => 'UaeTrn($formatted, valid: $isValid)';
}
