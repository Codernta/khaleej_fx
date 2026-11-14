import '../core/gcc_country.dart';

/// Major mobile telecommunications network operators across the 6 GCC member states.
enum GccCarrier {
  // --- Saudi Arabia 🇸🇦 ---
  /// STC (Saudi Telecom Company / شركة الاتصالات السعودية).
  stcKsa(
    country: GccCountry.saudiArabia,
    nameEn: 'STC',
    nameAr: 'إس تي سي',
    brandColorHex: 0xFF4F008C,
  ),

  /// Mobily (Etihad Etisalat / موبايلي).
  mobily(
    country: GccCountry.saudiArabia,
    nameEn: 'Mobily',
    nameAr: 'موبايلي',
    brandColorHex: 0xFF00A3E0,
  ),

  /// Zain KSA (زين السعودية).
  zainKsa(
    country: GccCountry.saudiArabia,
    nameEn: 'Zain KSA',
    nameAr: 'زين السعودية',
    brandColorHex: 0xFF1B365D,
  ),

  /// Virgin Mobile KSA (فيرجن موبايل).
  virginMobileKsa(
    country: GccCountry.saudiArabia,
    nameEn: 'Virgin Mobile KSA',
    nameAr: 'فيرجن موبايل',
    brandColorHex: 0xFFE10A0A,
  ),

  /// Salam Mobile (سلام).
  salam(
    country: GccCountry.saudiArabia,
    nameEn: 'Salam Mobile',
    nameAr: 'سلام موبايل',
    brandColorHex: 0xFF00B0B9,
  ),

  /// Red Bull Mobile KSA.
  redBullMobile(
    country: GccCountry.saudiArabia,
    nameEn: 'Red Bull Mobile',
    nameAr: 'ريد بُل موبايل',
    brandColorHex: 0xFFED1C24,
  ),

  // --- United Arab Emirates 🇦🇪 ---
  /// e& (formerly Etisalat / اتصالات).
  etisalatUae(
    country: GccCountry.uae,
    nameEn: 'e& (Etisalat)',
    nameAr: 'اتصالات (e&)',
    brandColorHex: 0xFF719E19,
  ),

  /// du (Emirates Integrated Telecommunications Company / دو).
  du(
    country: GccCountry.uae,
    nameEn: 'du',
    nameAr: 'دو',
    brandColorHex: 0xFF00A9E0,
  ),

  /// Virgin Mobile UAE.
  virginMobileUae(
    country: GccCountry.uae,
    nameEn: 'Virgin Mobile UAE',
    nameAr: 'فيرجن موبايل الإمارات',
    brandColorHex: 0xFFE10A0A,
  ),

  // --- Kuwait 🇰🇼 ---
  /// Zain Kuwait (زين الكويت).
  zainKuwait(
    country: GccCountry.kuwait,
    nameEn: 'Zain Kuwait',
    nameAr: 'زين الكويت',
    brandColorHex: 0xFF1B365D,
  ),

  /// Ooredoo Kuwait (أوريدو الكويت).
  ooredooKuwait(
    country: GccCountry.kuwait,
    nameEn: 'Ooredoo Kuwait',
    nameAr: 'أوريدو الكويت',
    brandColorHex: 0xFFED1C24,
  ),

  /// stc Kuwait (إس تي سي الكويت).
  stcKuwait(
    country: GccCountry.kuwait,
    nameEn: 'stc Kuwait',
    nameAr: 'إس تي سي الكويت',
    brandColorHex: 0xFF4F008C,
  ),

  // --- Qatar 🇶🇦 ---
  /// Ooredoo Qatar (أوريدو قطر).
  ooredooQatar(
    country: GccCountry.qatar,
    nameEn: 'Ooredoo Qatar',
    nameAr: 'أوريدو قطر',
    brandColorHex: 0xFFED1C24,
  ),

  /// Vodafone Qatar (فودافون قطر).
  vodafoneQatar(
    country: GccCountry.qatar,
    nameEn: 'Vodafone Qatar',
    nameAr: 'فودافون قطر',
    brandColorHex: 0xFFE60000,
  ),

  // --- Bahrain 🇧🇭 ---
  /// Batelco (بتلكو - Bahrain Telecommunications Company).
  batelco(
    country: GccCountry.bahrain,
    nameEn: 'Batelco',
    nameAr: 'بتلكو',
    brandColorHex: 0xFFE30613,
  ),

  /// Zain Bahrain (زين البحرين).
  zainBahrain(
    country: GccCountry.bahrain,
    nameEn: 'Zain Bahrain',
    nameAr: 'زين البحرين',
    brandColorHex: 0xFF1B365D,
  ),

  /// stc Bahrain (إس تي سي البحرين).
  stcBahrain(
    country: GccCountry.bahrain,
    nameEn: 'stc Bahrain',
    nameAr: 'إس تي سي البحرين',
    brandColorHex: 0xFF4F008C,
  ),

  // --- Oman 🇴🇲 ---
  /// Omantel (عمانتل - Oman Telecommunications Company).
  omantel(
    country: GccCountry.oman,
    nameEn: 'Omantel',
    nameAr: 'عمانتل',
    brandColorHex: 0xFF003399,
  ),

  /// Ooredoo Oman (أوريدو عمان).
  ooredooOman(
    country: GccCountry.oman,
    nameEn: 'Ooredoo Oman',
    nameAr: 'أوريدو عمان',
    brandColorHex: 0xFFED1C24,
  ),

  /// Vodafone Oman (فودافون عمان).
  vodafoneOman(
    country: GccCountry.oman,
    nameEn: 'Vodafone Oman',
    nameAr: 'فودافون عمان',
    brandColorHex: 0xFFE60000,
  );

  const GccCarrier({
    required this.country,
    required this.nameEn,
    required this.nameAr,
    required this.brandColorHex,
  });

  /// Associated GCC country.
  final GccCountry country;

  /// English trade name.
  final String nameEn;

  /// Arabic trade name.
  final String nameAr;

  /// Official brand primary color hex code.
  final int brandColorHex;
}
