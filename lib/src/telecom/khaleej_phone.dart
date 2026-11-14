import '../core/gcc_country.dart';
import '../utils/numeral_converter.dart';
import 'gcc_carrier.dart';

/// Represents a parsed, validated, and normalized GCC mobile phone number.
///
/// Automatically identifies:
/// - GCC Member state (Saudi Arabia, UAE, Kuwait, Qatar, Bahrain, Oman)
/// - Telecom network carrier (STC, Mobily, Zain, e&, du, Ooredoo, Vodafone, Batelco, Omantel)
/// - E.164 standard formatting (e.g. `+966501234567`)
/// - Domestic national formatting (e.g. `050 123 4567`)
/// - Privacy-compliant PDPL masking (e.g. `+966 50 *** 4567`)
class KhaleejPhone {
  const KhaleejPhone._({
    required this.raw,
    required this.country,
    required this.isValid,
    required this.nationalSignificantNumber,
    this.carrier,
    this.validationError,
  });

  /// The original raw input string.
  final String raw;

  /// The detected GCC country.
  final GccCountry country;

  /// Whether the phone number satisfies country dialing and length rules.
  final bool isValid;

  /// The National Significant Number (NSN) excluding country calling code and trunk prefix '0'.
  final String nationalSignificantNumber;

  /// The identified mobile telecommunication network operator.
  final GccCarrier? carrier;

  /// Explanatory error message if invalid, or null if valid.
  final String? validationError;

  /// Formatted E.164 international standard representation (e.g. `+966501234567`).
  String get e164 {
    if (!isValid) return raw;
    return '+${country.phoneCountryCode}$nationalSignificantNumber';
  }

  /// Formatted national display representation (e.g. `050 123 4567` or `9123 4567`).
  String get national {
    if (!isValid) return raw;
    final nsn = nationalSignificantNumber;
    switch (country) {
      case GccCountry.saudiArabia:
        // KSA: 05X XXX XXXX (9 digits NSN starting with 5)
        return '0${nsn.substring(0, 2)} ${nsn.substring(2, 5)} ${nsn.substring(5)}';
      case GccCountry.uae:
        // UAE: 05X XXX XXXX (9 digits NSN starting with 5)
        return '0${nsn.substring(0, 2)} ${nsn.substring(2, 5)} ${nsn.substring(5)}';
      case GccCountry.kuwait:
      case GccCountry.qatar:
      case GccCountry.bahrain:
      case GccCountry.oman:
        // 8 digits NSN: XXXX XXXX
        if (nsn.length == 8) {
          return '${nsn.substring(0, 4)} ${nsn.substring(4)}';
        }
        return nsn;
    }
  }

  /// Formatted international grouped representation (e.g. `+966 50 123 4567`).
  String get internationalFormatted {
    if (!isValid) return raw;
    final code = country.phoneCountryCode;
    final nsn = nationalSignificantNumber;
    switch (country) {
      case GccCountry.saudiArabia:
      case GccCountry.uae:
        return '+$code ${nsn.substring(0, 2)} ${nsn.substring(2, 5)} ${nsn.substring(5)}';
      case GccCountry.kuwait:
      case GccCountry.qatar:
      case GccCountry.bahrain:
      case GccCountry.oman:
        if (nsn.length == 8) {
          return '+$code ${nsn.substring(0, 4)} ${nsn.substring(4)}';
        }
        return '+$code $nsn';
    }
  }

  /// Privacy-compliant masked representation (e.g. `+966 50 *** 4567`).
  String mask({String maskChar = '*'}) {
    if (!isValid) return raw;
    final code = country.phoneCountryCode;
    final nsn = nationalSignificantNumber;
    if (nsn.length < 6) return '+$code $nsn';
    final prefix = nsn.substring(0, 2);
    final suffix = nsn.substring(nsn.length - 4);
    final middle = maskChar * 3;
    return '+$code $prefix $middle $suffix';
  }

  /// Parses, validates, and identifies the carrier of a GCC phone number.
  factory KhaleejPhone.parse(
    String input, {
    GccCountry? defaultCountry,
  }) {
    var clean = NumeralConverter.toWesternArabic(input);
    clean = clean.replaceAll(RegExp(r'[\s\-().]'), '');

    if (clean.isEmpty) {
      return KhaleejPhone._(
        raw: input,
        country: defaultCountry ?? GccCountry.saudiArabia,
        isValid: false,
        nationalSignificantNumber: '',
        validationError: 'Phone number cannot be empty.',
      );
    }

    // Strip leading '+' or '00' international prefix
    if (clean.startsWith('+')) {
      clean = clean.substring(1);
    } else if (clean.startsWith('00')) {
      clean = clean.substring(2);
    }

    // Detect country by calling code
    GccCountry? detectedCountry;
    String nsn = clean;

    for (final c in GccCountry.values) {
      final code = c.phoneCountryCode;
      if (clean.startsWith(code)) {
        detectedCountry = c;
        nsn = clean.substring(code.length);
        break;
      }
    }

    detectedCountry ??= defaultCountry ?? GccCountry.saudiArabia;

    // Strip leading national trunk prefix '0' if present in NSN
    if (nsn.startsWith('0')) {
      nsn = nsn.substring(1);
    }

    final validationError = _validateNsn(detectedCountry, nsn);
    final isValid = validationError == null;
    final carrier = isValid ? _detectCarrier(detectedCountry, nsn) : null;

    return KhaleejPhone._(
      raw: input,
      country: detectedCountry,
      isValid: isValid,
      nationalSignificantNumber: nsn,
      carrier: carrier,
      validationError: validationError,
    );
  }

  static String? _validateNsn(GccCountry country, String nsn) {
    switch (country) {
      case GccCountry.saudiArabia:
        // SAMA / CST standard: 9 digits starting with 5 (e.g. 50XXXXXXX)
        if (nsn.length != 9) {
          return 'Saudi mobile numbers must have 9 digits after country code, received ${nsn.length}.';
        }
        if (!nsn.startsWith('5')) {
          return 'Saudi mobile numbers must begin with prefix 5 (or 05 domestically).';
        }
        return null;

      case GccCountry.uae:
        // TDRA standard: 9 digits starting with 5 (e.g. 50XXXXXXX, 54, 56, 52, 55, 58)
        if (nsn.length != 9) {
          return 'UAE mobile numbers must have 9 digits after country code, received ${nsn.length}.';
        }
        if (!nsn.startsWith('5')) {
          return 'UAE mobile numbers must begin with prefix 5 (or 05 domestically).';
        }
        return null;

      case GccCountry.kuwait:
        // CITRA standard: 8 digits starting with 5, 6, or 9
        if (nsn.length != 8) {
          return 'Kuwait mobile numbers must have 8 digits, received ${nsn.length}.';
        }
        if (!RegExp(r'^[569]').hasMatch(nsn)) {
          return 'Kuwait mobile numbers must begin with 5, 6, or 9.';
        }
        return null;

      case GccCountry.qatar:
        // CRA standard: 8 digits starting with 3, 5, 6, or 7
        if (nsn.length != 8) {
          return 'Qatar mobile numbers must have 8 digits, received ${nsn.length}.';
        }
        if (!RegExp(r'^[3567]').hasMatch(nsn)) {
          return 'Qatar mobile numbers must begin with 3, 5, 6, or 7.';
        }
        return null;

      case GccCountry.bahrain:
        // TRA standard: 8 digits starting with 3
        if (nsn.length != 8) {
          return 'Bahrain mobile numbers must have 8 digits, received ${nsn.length}.';
        }
        if (!nsn.startsWith('3')) {
          return 'Bahrain mobile numbers must begin with 3.';
        }
        return null;

      case GccCountry.oman:
        // TRA Oman standard: 8 digits starting with 7 or 9
        if (nsn.length != 8) {
          return 'Oman mobile numbers must have 8 digits, received ${nsn.length}.';
        }
        if (!RegExp(r'^[79]').hasMatch(nsn)) {
          return 'Oman mobile numbers must begin with 7 or 9.';
        }
        return null;
    }
  }

  static GccCarrier? _detectCarrier(GccCountry country, String nsn) {
    switch (country) {
      case GccCountry.saudiArabia:
        // NSN is 9 digits starting with 5
        if (nsn.startsWith('50') || nsn.startsWith('53') || nsn.startsWith('55')) {
          return GccCarrier.stcKsa;
        }
        if (nsn.startsWith('54') || nsn.startsWith('56')) {
          return GccCarrier.mobily;
        }
        if (nsn.startsWith('58') || nsn.startsWith('59')) {
          return GccCarrier.zainKsa;
        }
        if (nsn.startsWith('570') || nsn.startsWith('571') || nsn.startsWith('572')) {
          return GccCarrier.virginMobileKsa;
        }
        if (nsn.startsWith('574')) {
          return GccCarrier.salam;
        }
        if (nsn.startsWith('575') || nsn.startsWith('576')) {
          return GccCarrier.redBullMobile;
        }
        return GccCarrier.stcKsa; // General default in KSA

      case GccCountry.uae:
        if (nsn.startsWith('50') || nsn.startsWith('54') || nsn.startsWith('56')) {
          return GccCarrier.etisalatUae;
        }
        if (nsn.startsWith('52') || nsn.startsWith('55') || nsn.startsWith('58')) {
          return GccCarrier.du;
        }
        return GccCarrier.etisalatUae;

      case GccCountry.kuwait:
        if (nsn.startsWith('9')) return GccCarrier.zainKuwait;
        if (nsn.startsWith('6')) return GccCarrier.ooredooKuwait;
        if (nsn.startsWith('5')) return GccCarrier.stcKuwait;
        return null;

      case GccCountry.qatar:
        if (nsn.startsWith('7')) return GccCarrier.vodafoneQatar;
        if (nsn.startsWith('3') || nsn.startsWith('5') || nsn.startsWith('6')) {
          return GccCarrier.ooredooQatar;
        }
        return null;

      case GccCountry.bahrain:
        if (nsn.startsWith('38') || nsn.startsWith('39')) {
          return GccCarrier.batelco;
        }
        if (nsn.startsWith('36') || nsn.startsWith('37')) {
          return GccCarrier.zainBahrain;
        }
        if (nsn.startsWith('33') || nsn.startsWith('34')) {
          return GccCarrier.stcBahrain;
        }
        return GccCarrier.batelco;

      case GccCountry.oman:
        if (nsn.startsWith('91') ||
            nsn.startsWith('92') ||
            nsn.startsWith('93') ||
            nsn.startsWith('99')) {
          return GccCarrier.omantel;
        }
        if (nsn.startsWith('94') ||
            nsn.startsWith('95') ||
            nsn.startsWith('96')) {
          return GccCarrier.ooredooOman;
        }
        if (nsn.startsWith('71') || nsn.startsWith('72')) {
          return GccCarrier.vodafoneOman;
        }
        return GccCarrier.omantel;
    }
  }

  @override
  String toString() =>
      'KhaleejPhone($e164, country: ${country.iso2}, carrier: ${carrier?.nameEn}, valid: $isValid)';
}
