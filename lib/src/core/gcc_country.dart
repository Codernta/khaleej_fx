/// GCC Member States and Country Metadata.
library;

/// Represents one of the six Gulf Cooperation Council (GCC) member states.
enum GccCountry {
  /// Kingdom of Saudi Arabia (المملكة العربية السعودية)
  saudiArabia(
    iso2: 'SA',
    iso3: 'SAU',
    numericCode: '682',
    dialCode: '+966',
    flagEmoji: '🇸🇦',
    nameEn: 'Saudi Arabia',
    nameAr: 'المملكة العربية السعودية',
    currencyCode: 'SAR',
    ibanLength: 24,
  ),

  /// United Arab Emirates (الإمارات العربية المتحدة)
  uae(
    iso2: 'AE',
    iso3: 'ARE',
    numericCode: '784',
    dialCode: '+971',
    flagEmoji: '🇦🇪',
    nameEn: 'United Arab Emirates',
    nameAr: 'الإمارات العربية المتحدة',
    currencyCode: 'AED',
    ibanLength: 23,
  ),

  /// State of Kuwait (دولة الكويت)
  kuwait(
    iso2: 'KW',
    iso3: 'KWT',
    numericCode: '414',
    dialCode: '+965',
    flagEmoji: '🇰🇼',
    nameEn: 'Kuwait',
    nameAr: 'الكويت',
    currencyCode: 'KWD',
    ibanLength: 30,
  ),

  /// State of Qatar (دولة قطر)
  qatar(
    iso2: 'QA',
    iso3: 'QAT',
    numericCode: '634',
    dialCode: '+974',
    flagEmoji: '🇶🇦',
    nameEn: 'Qatar',
    nameAr: 'قطر',
    currencyCode: 'QAR',
    ibanLength: 29,
  ),

  /// Kingdom of Bahrain (مملكة البحرين)
  bahrain(
    iso2: 'BH',
    iso3: 'BHR',
    numericCode: '048',
    dialCode: '+973',
    flagEmoji: '🇧🇭',
    nameEn: 'Bahrain',
    nameAr: 'البحرين',
    currencyCode: 'BHD',
    ibanLength: 22,
  ),

  /// Sultanate of Oman (سلطنة عمان)
  oman(
    iso2: 'OM',
    iso3: 'OMN',
    numericCode: '512',
    dialCode: '+968',
    flagEmoji: '🇴🇲',
    nameEn: 'Oman',
    nameAr: 'عُمان',
    currencyCode: 'OMR',
    ibanLength: 23,
  );

  const GccCountry({
    required this.iso2,
    required this.iso3,
    required this.numericCode,
    required this.dialCode,
    required this.flagEmoji,
    required this.nameEn,
    required this.nameAr,
    required this.currencyCode,
    required this.ibanLength,
  });

  /// ISO 3166-1 alpha-2 code (e.g. 'SA').
  final String iso2;

  /// ISO 3166-1 alpha-3 code (e.g. 'SAU').
  final String iso3;

  /// ISO 3166-1 numeric code (e.g. '682').
  final String numericCode;

  /// International phone dial code with plus sign (e.g. '+966').
  final String dialCode;

  /// Unicode flag emoji (e.g. '🇸🇦').
  final String flagEmoji;

  /// Country name in English.
  final String nameEn;

  /// Country name in Arabic.
  final String nameAr;

  /// Default currency code (e.g. 'SAR').
  final String currencyCode;

  /// Standard IBAN character length.
  final int ibanLength;

  /// Numeric telephone calling code digits without '+' (e.g. '966' for KSA).
  String get phoneCountryCode => dialCode.replaceAll('+', '');

  /// Finds a [GccCountry] by its ISO2, ISO3, or numeric code (case-insensitive).
  static GccCountry? fromCode(String code) {
    final clean = code.trim().toUpperCase();
    for (final c in GccCountry.values) {
      if (c.iso2 == clean || c.iso3 == clean || c.numericCode == clean) {
        return c;
      }
    }
    return null;
  }

  /// Finds a [GccCountry] by its phone dial code (e.g. '+966' or '966').
  static GccCountry? fromDialCode(String dial) {
    var clean = dial.trim();
    if (!clean.startsWith('+')) {
      clean = '+$clean';
    }
    for (final c in GccCountry.values) {
      if (c.dialCode == clean) {
        return c;
      }
    }
    return null;
  }
}
