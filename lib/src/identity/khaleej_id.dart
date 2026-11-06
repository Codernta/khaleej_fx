import '../core/gcc_country.dart';
import 'bahrain_cpr.dart';
import 'emirates_id.dart';
import 'kuwait_civil_id.dart';
import 'oman_civil_id.dart';
import 'qatar_id.dart';
import 'saudi_id.dart';

/// Base class representing a National Identity or Civil Residency ID from a GCC state.
abstract class KhaleejId {
  const KhaleejId({
    required this.raw,
    required this.country,
    required this.isValid,
    this.validationError,
  });

  /// Sanitized raw numeric string without hyphens or spaces.
  final String raw;

  /// The GCC country issuing this national ID.
  final GccCountry country;

  /// Whether the ID satisfies structural, length, and checksum algorithms.
  final bool isValid;

  /// Explanatory error message if the ID is invalid, or null if valid.
  final String? validationError;

  /// Formatted representation according to the country's official convention.
  String get formatted;

  /// Unified factory to parse an ID string for a specific [country] or auto-detect.
  static KhaleejId parse(String input, {GccCountry? country}) {
    if (country != null) {
      switch (country) {
        case GccCountry.saudiArabia:
          return SaudiId.parse(input);
        case GccCountry.uae:
          return EmiratesId.parse(input);
        case GccCountry.kuwait:
          return KuwaitCivilId.parse(input);
        case GccCountry.qatar:
          return QatarId.parse(input);
        case GccCountry.bahrain:
          return BahrainCpr.parse(input);
        case GccCountry.oman:
          return OmanCivilId.parse(input);
      }
    }

    // Auto-detect based on format and length
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 15 && digits.startsWith('784')) {
      return EmiratesId.parse(input);
    }
    if (digits.length == 10 && (digits.startsWith('1') || digits.startsWith('2'))) {
      return SaudiId.parse(input);
    }
    if (digits.length == 12) {
      return KuwaitCivilId.parse(input);
    }
    if (digits.length == 11) {
      return QatarId.parse(input);
    }
    if (digits.length == 9) {
      return BahrainCpr.parse(input);
    }
    if (digits.length == 8 || digits.length == 7) {
      return OmanCivilId.parse(input);
    }

    // Fallback: default to Saudi ID parser if 10 digits, otherwise Emirates
    if (digits.length == 15) return EmiratesId.parse(input);
    return SaudiId.parse(input);
  }

  /// Validates an ID string against the given [country]'s rules.
  static bool validate(String input, GccCountry country) {
    return parse(input, country: country).isValid;
  }

  @override
  String toString() => formatted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhaleejId &&
          runtimeType == other.runtimeType &&
          raw == other.raw &&
          country == other.country;

  @override
  int get hashCode => Object.hash(raw, country);
}

/// Helper utility for Modulo 10 (Luhn) and Modulo 11 checksum algorithms.
class ChecksumUtils {
  const ChecksumUtils._();

  /// Calculates or verifies standard Luhn (Modulo 10) checksum.
  ///
  /// Traverses from right to left, doubling every second digit starting
  /// from the second-to-last digit. If doubled > 9, subtracts 9.
  /// Returns true if total sum % 10 == 0.
  static bool verifyLuhn(String digits) {
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) return false;

    var sum = 0;
    var alternate = false;

    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  /// Calculates the Luhn check digit for a given numeric [prefix].
  static int calculateLuhnCheckDigit(String prefix) {
    var sum = 0;
    var alternate = true;

    for (var i = prefix.length - 1; i >= 0; i--) {
      var n = int.parse(prefix[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    final rem = sum % 10;
    return (10 - rem) % 10;
  }
}
