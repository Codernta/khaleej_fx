import '../core/gcc_country.dart';

/// Represents a Saudi 700 Unified National Number for Establishments (الرقم الموحد 700).
///
/// Issued by the Ministry of Commerce and utilized across SAMA, ZATCA, Qiwa,
/// and GOSI as the primary corporate identifier for all companies, institutions,
/// and government entities operating in Saudi Arabia.
class Saudi700Number {
  const Saudi700Number._({
    required this.raw,
    required this.isValid,
    this.validationError,
  });

  /// The raw 10-digit number starting with '700'.
  final String raw;

  /// Whether the number satisfies the 10-digit structure and '700' prefix.
  final bool isValid;

  /// Explanatory error message if invalid, or null if valid.
  final String? validationError;

  /// Issuing country (always Saudi Arabia).
  GccCountry get country => GccCountry.saudiArabia;

  /// Formatted representation in 3-3-4 groups (e.g. `700 123 4567`).
  String get formatted {
    if (raw.length != 10) return raw;
    return '${raw.substring(0, 3)} ${raw.substring(3, 6)} ${raw.substring(6)}';
  }

  /// Returns a privacy-compliant masked representation (e.g. `700****567`).
  String mask({String maskChar = '*'}) {
    if (raw.length != 10) return raw;
    return '${raw.substring(0, 3)}${maskChar * 4}${raw.substring(7)}';
  }

  /// Parses and validates a Saudi 700 Unified Establishment Number.
  factory Saudi700Number.parse(String input) {
    final clean = input.replaceAll(RegExp(r'\D'), '');

    if (clean.length != 10) {
      return Saudi700Number._(
        raw: clean,
        isValid: false,
        validationError:
            'Saudi 700 number must be exactly 10 numeric digits, received ${clean.length}.',
      );
    }

    if (!clean.startsWith('700')) {
      return Saudi700Number._(
        raw: clean,
        isValid: false,
        validationError:
            'Saudi 700 establishment number must begin with prefix 700.',
      );
    }

    if (clean == '7000000000') {
      return const Saudi700Number._(
        raw: '7000000000',
        isValid: false,
        validationError: 'Saudi 700 number cannot consist solely of trailing zeros.',
      );
    }

    return Saudi700Number._(
      raw: clean,
      isValid: true,
    );
  }

  @override
  String toString() => 'Saudi700Number($formatted, valid: $isValid)';
}
