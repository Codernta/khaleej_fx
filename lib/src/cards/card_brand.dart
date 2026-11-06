import '../core/gcc_country.dart';

/// GCC domestic payment card switch / clearing scheme.
enum GccDomesticSwitch {
  /// Saudi Arabia's national payment network (مدى - Mada).
  mada(
    country: GccCountry.saudiArabia,
    nameEn: 'Mada',
    nameAr: 'مدى',
  ),

  /// UAE's national domestic card scheme (جيوان - Jaywan / Mercury).
  jaywan(
    country: GccCountry.uae,
    nameEn: 'Jaywan',
    nameAr: 'جيوان',
  ),

  /// Kuwait's national banking network (كي نت - KNET).
  knet(
    country: GccCountry.kuwait,
    nameEn: 'KNET',
    nameAr: 'كي نت',
  ),

  /// Kingdom of Bahrain's national switch (بنفت - Benefit).
  benefit(
    country: GccCountry.bahrain,
    nameEn: 'Benefit',
    nameAr: 'بنفت',
  ),

  /// State of Qatar's national debit card scheme (هميان - Himyan / NAPS).
  himyan(
    country: GccCountry.qatar,
    nameEn: 'Himyan / NAPS',
    nameAr: 'هميان',
  ),

  /// Sultanate of Oman's national debit switch (عمان نت - OmanNet).
  omanNet(
    country: GccCountry.oman,
    nameEn: 'OmanNet',
    nameAr: 'عُمان نت',
  ),

  /// None (standard international card without GCC domestic co-badging).
  none(
    country: null,
    nameEn: 'International',
    nameAr: 'دولي',
  );

  const GccDomesticSwitch({
    required this.country,
    required this.nameEn,
    required this.nameAr,
  });

  final GccCountry? country;
  final String nameEn;
  final String nameAr;
}

/// Payment card brands, including global networks and GCC domestic schemes.
enum CardBrand {
  /// Saudi domestic debit / co-badged scheme.
  mada(displayName: 'Mada', isDomesticGcc: true),

  /// UAE national card scheme.
  jaywan(displayName: 'Jaywan', isDomesticGcc: true),

  /// Kuwait national debit scheme.
  knet(displayName: 'KNET', isDomesticGcc: true),

  /// Bahrain national debit scheme.
  benefit(displayName: 'Benefit', isDomesticGcc: true),

  /// Qatar national debit scheme.
  himyan(displayName: 'Himyan', isDomesticGcc: true),

  /// Oman national debit scheme.
  omanNet(displayName: 'OmanNet', isDomesticGcc: true),

  /// Visa International.
  visa(displayName: 'Visa', isDomesticGcc: false),

  /// Mastercard Worldwide.
  mastercard(displayName: 'Mastercard', isDomesticGcc: false),

  /// American Express.
  americanExpress(displayName: 'American Express', isDomesticGcc: false),

  /// Discover Network.
  discover(displayName: 'Discover', isDomesticGcc: false),

  /// Unknown card brand.
  unknown(displayName: 'Unknown', isDomesticGcc: false);

  const CardBrand({
    required this.displayName,
    required this.isDomesticGcc,
  });

  final String displayName;
  final bool isDomesticGcc;
}
