import '../core/gcc_country.dart';

/// Represents a national currency of the GCC member states.
enum KhaleejCurrency {
  /// Saudi Riyal (SAR / ر.س) - Subunit: Halala (1/100).
  sar(
    code: 'SAR',
    numericCode: '682',
    symbolEn: 'SAR',
    symbolAr: 'ر.س',
    decimals: 2,
    country: GccCountry.saudiArabia,
    nameEn: 'Saudi Riyal',
    nameAr: 'ريال سعودي',
    pluralNameAr: 'ريالات سعودية',
    dualNameArMarfoo: 'ريالان سعوديان',
    dualNameArMajroor: 'ريالين سعوديين',
    subunitNameEn: 'Halala',
    subunitNameAr: 'هللة',
    subunitPluralNameAr: 'هللات',
    subunitDualNameArMarfoo: 'هللتان',
    subunitDualNameArMajroor: 'هللتين',
    isSubunitFeminine: true,
    isMajorFeminine: false,
  ),

  /// UAE Dirham (AED / د.إ) - Subunit: Fils (1/100).
  aed(
    code: 'AED',
    numericCode: '784',
    symbolEn: 'AED',
    symbolAr: 'د.إ',
    decimals: 2,
    country: GccCountry.uae,
    nameEn: 'UAE Dirham',
    nameAr: 'درهم إماراتي',
    pluralNameAr: 'دراهم إماراتية',
    dualNameArMarfoo: 'درهمان إماراتيان',
    dualNameArMajroor: 'درهمين إماراتيين',
    subunitNameEn: 'Fils',
    subunitNameAr: 'فلس',
    subunitPluralNameAr: 'فلس',
    subunitDualNameArMarfoo: 'فلسان',
    subunitDualNameArMajroor: 'فلسين',
    isSubunitFeminine: false,
    isMajorFeminine: false,
  ),

  /// Kuwaiti Dinar (KWD / د.ك) - Subunit: Fils (1/1000).
  kwd(
    code: 'KWD',
    numericCode: '414',
    symbolEn: 'KWD',
    symbolAr: 'د.ك',
    decimals: 3,
    country: GccCountry.kuwait,
    nameEn: 'Kuwaiti Dinar',
    nameAr: 'دينار كويتي',
    pluralNameAr: 'دنانير كويتية',
    dualNameArMarfoo: 'ديناران كويتيان',
    dualNameArMajroor: 'دينارين كويتيين',
    subunitNameEn: 'Fils',
    subunitNameAr: 'فلس',
    subunitPluralNameAr: 'فلس',
    subunitDualNameArMarfoo: 'فلسان',
    subunitDualNameArMajroor: 'فلسين',
    isSubunitFeminine: false,
    isMajorFeminine: false,
  ),

  /// Qatari Riyal (QAR / ر.ق) - Subunit: Dirham (1/100).
  qar(
    code: 'QAR',
    numericCode: '634',
    symbolEn: 'QAR',
    symbolAr: 'ر.ق',
    decimals: 2,
    country: GccCountry.qatar,
    nameEn: 'Qatari Riyal',
    nameAr: 'ريال قطري',
    pluralNameAr: 'ريالات قطرية',
    dualNameArMarfoo: 'ريالان قطريان',
    dualNameArMajroor: 'ريالين قطريين',
    subunitNameEn: 'Dirham',
    subunitNameAr: 'درهم',
    subunitPluralNameAr: 'دراهم',
    subunitDualNameArMarfoo: 'درهمان',
    subunitDualNameArMajroor: 'درهمين',
    isSubunitFeminine: false,
    isMajorFeminine: false,
  ),

  /// Bahraini Dinar (BHD / د.ب) - Subunit: Fils (1/1000).
  bhd(
    code: 'BHD',
    numericCode: '048',
    symbolEn: 'BHD',
    symbolAr: 'د.ب',
    decimals: 3,
    country: GccCountry.bahrain,
    nameEn: 'Bahraini Dinar',
    nameAr: 'دينار بحريني',
    pluralNameAr: 'دنانير بحرينية',
    dualNameArMarfoo: 'ديناران بحرينيان',
    dualNameArMajroor: 'دينارين بحرينيين',
    subunitNameEn: 'Fils',
    subunitNameAr: 'فلس',
    subunitPluralNameAr: 'فلس',
    subunitDualNameArMarfoo: 'فلسان',
    subunitDualNameArMajroor: 'فلسين',
    isSubunitFeminine: false,
    isMajorFeminine: false,
  ),

  /// Omani Rial (OMR / ر.ع) - Subunit: Baisa (1/1000).
  omr(
    code: 'OMR',
    numericCode: '512',
    symbolEn: 'OMR',
    symbolAr: 'ر.ع',
    decimals: 3,
    country: GccCountry.oman,
    nameEn: 'Omani Rial',
    nameAr: 'ريال عماني',
    pluralNameAr: 'ريالات عمانية',
    dualNameArMarfoo: 'ريالان عمانيان',
    dualNameArMajroor: 'ريالين عمانيين',
    subunitNameEn: 'Baisa',
    subunitNameAr: 'بيسة',
    subunitPluralNameAr: 'بيسات',
    subunitDualNameArMarfoo: 'بيستان',
    subunitDualNameArMajroor: 'بيستين',
    isSubunitFeminine: true,
    isMajorFeminine: false,
  );

  const KhaleejCurrency({
    required this.code,
    required this.numericCode,
    required this.symbolEn,
    required this.symbolAr,
    required this.decimals,
    required this.country,
    required this.nameEn,
    required this.nameAr,
    required this.pluralNameAr,
    required this.dualNameArMarfoo,
    required this.dualNameArMajroor,
    required this.subunitNameEn,
    required this.subunitNameAr,
    required this.subunitPluralNameAr,
    required this.subunitDualNameArMarfoo,
    required this.subunitDualNameArMajroor,
    required this.isSubunitFeminine,
    required this.isMajorFeminine,
  });

  /// 3-letter ISO 4217 currency code.
  final String code;

  /// ISO 4217 3-digit numeric code.
  final String numericCode;

  /// Latin symbol / abbreviation.
  final String symbolEn;

  /// Arabic currency symbol.
  final String symbolAr;

  /// Minor unit decimal places (2 for SAR, AED, QAR; 3 for KWD, BHD, OMR).
  final int decimals;

  /// Associated GCC country.
  final GccCountry country;

  /// English currency name.
  final String nameEn;

  /// Arabic currency name in singular form.
  final String nameAr;

  /// Arabic currency name in plural form.
  final String pluralNameAr;

  /// Arabic dual form (مرفوع - Marfoo).
  final String dualNameArMarfoo;

  /// Arabic dual form (منصوب/مجرور - Mansoob/Majroor).
  final String dualNameArMajroor;

  /// English subunit name (e.g. Halala, Fils, Baisa).
  final String subunitNameEn;

  /// Arabic subunit name in singular form.
  final String subunitNameAr;

  /// Arabic subunit name in plural form.
  final String subunitPluralNameAr;

  /// Arabic subunit dual form (مرفوع).
  final String subunitDualNameArMarfoo;

  /// Arabic subunit dual form (منصوب/مجرور).
  final String subunitDualNameArMajroor;

  /// Whether the subunit noun in Arabic is grammatically feminine.
  final bool isSubunitFeminine;

  /// Whether the major currency noun in Arabic is grammatically feminine.
  final bool isMajorFeminine;

  /// Subunit factor (10^decimals, e.g. 100 for SAR, 1000 for KWD).
  int get subunitFactor {
    var factor = 1;
    for (var i = 0; i < decimals; i++) {
      factor *= 10;
    }
    return factor;
  }

  /// BigInt subunit factor.
  BigInt get subunitFactorBigInt => BigInt.from(subunitFactor);

  /// Find currency by ISO code or symbol.
  static KhaleejCurrency? fromCode(String code) {
    final clean = code.trim().toUpperCase();
    for (final c in KhaleejCurrency.values) {
      if (c.code == clean || c.numericCode == clean) {
        return c;
      }
    }
    // Also try Arabic symbol
    final arTrim = code.trim();
    for (final c in KhaleejCurrency.values) {
      if (c.symbolAr == arTrim || c.symbolEn.toUpperCase() == clean) {
        return c;
      }
    }
    return null;
  }

  /// Returns the currency for a given [GccCountry].
  static KhaleejCurrency forCountry(GccCountry country) {
    for (final c in KhaleejCurrency.values) {
      if (c.country == country) return c;
    }
    return KhaleejCurrency.sar;
  }
}
