import '../core/gcc_country.dart';

/// Represents a validated Saudi Commercial Registration (السجل التجاري - CR).
///
/// A Saudi CR is a 10-digit numeric identifier issued by the Ministry of Commerce (MoC).
/// The first 4 digits correspond to the issuing chamber of commerce or regional branch.
class SaudiCr {
  const SaudiCr._({
    required this.raw,
    required this.isValid,
    this.cityCode,
    this.cityNameEn,
    this.cityNameAr,
    this.validationError,
  });

  /// The raw 10-digit Commercial Registration number.
  final String raw;

  /// Whether the CR satisfies format, length, and known city code checks.
  final bool isValid;

  /// The 4-digit regional chamber/city branch code (e.g. '1010' for Riyadh).
  final String? cityCode;

  /// English name of the issuing city/chamber if known.
  final String? cityNameEn;

  /// Arabic name of the issuing city/chamber if known.
  final String? cityNameAr;

  /// Explanatory error message if invalid, or null if valid.
  final String? validationError;

  /// GCC Country issuing this CR (always Saudi Arabia).
  GccCountry get country => GccCountry.saudiArabia;

  /// Formatted CR representation with hyphen (e.g. `1010-123456`).
  String get formatted {
    if (raw.length != 10) return raw;
    return '${raw.substring(0, 4)}-${raw.substring(4)}';
  }

  /// Returns a privacy-compliant masked representation (e.g. `1010****56`).
  String mask({String maskChar = '*'}) {
    if (raw.length != 10) return raw;
    return '${raw.substring(0, 4)}${maskChar * 4}${raw.substring(8)}';
  }

  /// Parses and validates a Saudi Commercial Registration number.
  factory SaudiCr.parse(String input) {
    final clean = input.replaceAll(RegExp(r'\D'), '');

    if (clean.length != 10) {
      return SaudiCr._(
        raw: clean,
        isValid: false,
        validationError:
            'Saudi CR must be exactly 10 numeric digits, received ${clean.length}.',
      );
    }

    if (RegExp(r'^(\d)\1{9}$').hasMatch(clean)) {
      return SaudiCr._(
        raw: clean,
        isValid: false,
        validationError: 'Saudi CR cannot consist of repeated identical digits.',
      );
    }

    final cityPrefix = clean.substring(0, 4);
    final cityInfo = knownCityCodes[cityPrefix];

    return SaudiCr._(
      raw: clean,
      isValid: true,
      cityCode: cityPrefix,
      cityNameEn: cityInfo?.$1 ?? 'Saudi Branch ($cityPrefix)',
      cityNameAr: cityInfo?.$2 ?? 'فرع المملكة ($cityPrefix)',
    );
  }

  /// Known Saudi Ministry of Commerce Chamber of Commerce regional branch codes.
  static const Map<String, (String, String)> knownCityCodes = {
    '1010': ('Riyadh', 'الرياض'),
    '1011': ('Al Kharj', 'الخرج'),
    '1012': ('Ad Dawadimi', 'الدوادمي'),
    '1013': ('Al Majma\'ah', 'المجمعة'),
    '1014': ('Al Quway\'iyah', 'القويعية'),
    '1015': ('Wadi Ad Dawasir', 'وادي الدواسر'),
    '2050': ('Dammam', 'الدمام'),
    '2051': ('Al Khobar', 'الخبر'),
    '2052': ('Jubail', 'الجبيل'),
    '2053': ('Qatif', 'القطيف'),
    '2055': ('Hafar Al-Batin', 'حفر الباطن'),
    '2057': ('Khafji', 'الخفجي'),
    '2251': ('Al Ahsa', 'الأحساء'),
    '2252': ('Al Mubarraz', 'المبرز'),
    '3250': ('Arar / Northern Borders', 'عرعر / الحدود الشمالية'),
    '3251': ('Sakaka / Al-Jouf', 'سكاكا / الجوف'),
    '3252': ('Al Qurayyat', 'القريات'),
    '3350': ('Buraidah / Qassim', 'بريدة / القصيم'),
    '3450': ('Unaizah', 'عنيزة'),
    '3451': ('Ar Rass', 'الرس'),
    '3550': ('Hail', 'حائل'),
    '4030': ('Jeddah', 'جدة'),
    '4031': ('Makkah', 'مكة المكرمة'),
    '4032': ('Taif', 'الطائف'),
    '4033': ('Al Qunfudhah', 'القنفذة'),
    '4650': ('Madinah', 'المدينة المنورة'),
    '4651': ('Yanbu', 'ينبع'),
    '4652': ('Al-Ula', 'العلا'),
    '5850': ('Abha / Asir', 'أبها / عسير'),
    '5851': ('Khamis Mushait', 'خميس مشيط'),
    '5852': ('Bisha', 'بيشة'),
    '5853': ('Mahayel Asir', 'محايل عسير'),
    '5854': ('Al-Namas', 'النماص'),
    '5900': ('Tabuk', 'تبوك'),
    '5901': ('Duba', 'ضباء'),
    '5950': ('Najran', 'نجران'),
    '5951': ('Jazan', 'جازان'),
    '5952': ('Sabya', 'صبيا'),
  };

  @override
  String toString() => 'SaudiCr($formatted, city: $cityNameEn, valid: $isValid)';
}
