import '../core/gcc_country.dart';
import 'saudi_700.dart';
import 'saudi_cr.dart';
import 'uae_trn.dart';

/// Type of GCC Business or Corporate Identifier.
enum KhaleejBusinessIdType {
  /// Saudi Commercial Registration (السجل التجاري - 10 digits).
  saudiCr,

  /// Saudi 700 Unified National Establishment Number (الرقم الموحد 700).
  saudi700,

  /// UAE Tax Registration Number (FTA TRN - 15 digits).
  uaeTrn,

  /// Other or unrecognized business entity identifier.
  unknown,
}

/// Unified parser and discriminator for GCC Commercial & Business Identifiers.
class KhaleejBusinessId {
  const KhaleejBusinessId._({
    required this.raw,
    required this.type,
    required this.country,
    required this.isValid,
    this.saudiCr,
    this.saudi700,
    this.uaeTrn,
    this.validationError,
  });

  /// Sanitized raw numeric identifier.
  final String raw;

  /// Identified business ID type.
  final KhaleejBusinessIdType type;

  /// Associated GCC country.
  final GccCountry country;

  /// Whether the business identifier is structurally valid.
  final bool isValid;

  /// Concrete parsed [SaudiCr] if [type] is [KhaleejBusinessIdType.saudiCr].
  final SaudiCr? saudiCr;

  /// Concrete parsed [Saudi700Number] if [type] is [KhaleejBusinessIdType.saudi700].
  final Saudi700Number? saudi700;

  /// Concrete parsed [UaeTrn] if [type] is [KhaleejBusinessIdType.uaeTrn].
  final UaeTrn? uaeTrn;

  /// Explanatory error message if invalid.
  final String? validationError;

  /// Formatted representation according to the specific entity type standard.
  String get formatted {
    if (saudiCr != null) return saudiCr!.formatted;
    if (saudi700 != null) return saudi700!.formatted;
    if (uaeTrn != null) return uaeTrn!.formatted;
    return raw;
  }

  /// Privacy-compliant masked representation.
  String mask({String maskChar = '*'}) {
    if (saudiCr != null) return saudiCr!.mask(maskChar: maskChar);
    if (saudi700 != null) return saudi700!.mask(maskChar: maskChar);
    if (uaeTrn != null) return uaeTrn!.mask(maskChar: maskChar);
    return raw;
  }

  /// Parses and auto-detects or validates a GCC corporate identifier.
  factory KhaleejBusinessId.parse(
    String input, {
    GccCountry? country,
    KhaleejBusinessIdType? expectedType,
  }) {
    final clean = input.replaceAll(RegExp(r'\D'), '');

    if (expectedType != null) {
      switch (expectedType) {
        case KhaleejBusinessIdType.saudiCr:
          final cr = SaudiCr.parse(clean);
          return KhaleejBusinessId._(
            raw: clean,
            type: KhaleejBusinessIdType.saudiCr,
            country: GccCountry.saudiArabia,
            isValid: cr.isValid,
            saudiCr: cr,
            validationError: cr.validationError,
          );
        case KhaleejBusinessIdType.saudi700:
          final s700 = Saudi700Number.parse(clean);
          return KhaleejBusinessId._(
            raw: clean,
            type: KhaleejBusinessIdType.saudi700,
            country: GccCountry.saudiArabia,
            isValid: s700.isValid,
            saudi700: s700,
            validationError: s700.validationError,
          );
        case KhaleejBusinessIdType.uaeTrn:
          final trn = UaeTrn.parse(clean);
          return KhaleejBusinessId._(
            raw: clean,
            type: KhaleejBusinessIdType.uaeTrn,
            country: GccCountry.uae,
            isValid: trn.isValid,
            uaeTrn: trn,
            validationError: trn.validationError,
          );
        case KhaleejBusinessIdType.unknown:
          break;
      }
    }

    // Auto-detect by length and known prefixes
    if (clean.length == 15 && clean.startsWith('100')) {
      final trn = UaeTrn.parse(clean);
      return KhaleejBusinessId._(
        raw: clean,
        type: KhaleejBusinessIdType.uaeTrn,
        country: GccCountry.uae,
        isValid: trn.isValid,
        uaeTrn: trn,
        validationError: trn.validationError,
      );
    }

    if (clean.length == 10 && clean.startsWith('700')) {
      final s700 = Saudi700Number.parse(clean);
      return KhaleejBusinessId._(
        raw: clean,
        type: KhaleejBusinessIdType.saudi700,
        country: GccCountry.saudiArabia,
        isValid: s700.isValid,
        saudi700: s700,
        validationError: s700.validationError,
      );
    }

    if (clean.length == 10) {
      final cr = SaudiCr.parse(clean);
      return KhaleejBusinessId._(
        raw: clean,
        type: KhaleejBusinessIdType.saudiCr,
        country: GccCountry.saudiArabia,
        isValid: cr.isValid,
        saudiCr: cr,
        validationError: cr.validationError,
      );
    }

    return KhaleejBusinessId._(
      raw: clean,
      type: KhaleejBusinessIdType.unknown,
      country: country ?? GccCountry.saudiArabia,
      isValid: false,
      validationError:
          'Unrecognized GCC business identifier format or length (${clean.length} digits).',
    );
  }

  @override
  String toString() =>
      'KhaleejBusinessId(type: $type, formatted: $formatted, valid: $isValid)';
}
