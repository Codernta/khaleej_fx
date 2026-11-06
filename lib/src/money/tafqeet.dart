import 'khaleej_currency.dart';

/// Arabic grammatical cases affecting duals and plural suffix declensions.
enum GrammaticalCase {
  /// Nominative case (مرفوع - Marfoo): e.g. ألفان، مئتان، عشرون، ريالان.
  nominative,

  /// Accusative or Genitive case (منصوب أو مجرور - Mansoob / Majroor): e.g. ألفين، مئتين، عشرين، ريالين.
  accusativeOrGenitive,
}

/// Enterprise Tafqeet (number to words) engine supporting Arabic grammar rules
/// (dual forms, plurals, gender agreement, grammatical cases) and English conversion.
class Tafqeet {
  const Tafqeet._();

  // Arabic Digits (1-9) Masculine & Feminine
  static const Map<int, String> _unitsMasc = {
    1: 'واحد',
    2: 'اثنان',
    3: 'ثلاثة',
    4: 'أربعة',
    5: 'خمسة',
    6: 'ستة',
    7: 'سبعة',
    8: 'ثمانية',
    9: 'تسعة',
  };

  static const Map<int, String> _unitsMascMajroor = {
    1: 'واحد',
    2: 'اثنين',
    3: 'ثلاثة',
    4: 'أربعة',
    5: 'خمسة',
    6: 'ستة',
    7: 'سبعة',
    8: 'ثمانية',
    9: 'تسعة',
  };

  static const Map<int, String> _unitsFem = {
    1: 'واحدة',
    2: 'اثنتان',
    3: 'ثلاث',
    4: 'أربع',
    5: 'خمس',
    6: 'ست',
    7: 'سبع',
    8: 'ثمان',
    9: 'تسع',
  };

  static const Map<int, String> _unitsFemMajroor = {
    1: 'واحدة',
    2: 'اثنتين',
    3: 'ثلاث',
    4: 'أربع',
    5: 'خمس',
    6: 'ست',
    7: 'سبع',
    8: 'ثمان',
    9: 'تسع',
  };

  // Tens (20..90)
  static const Map<int, String> _tensMarfoo = {
    2: 'عشرون',
    3: 'ثلاثون',
    4: 'أربعون',
    5: 'خمسون',
    6: 'ستون',
    7: 'سبعون',
    8: 'ثمانون',
    9: 'تسعون',
  };

  static const Map<int, String> _tensMajroor = {
    2: 'عشرين',
    3: 'ثلاثين',
    4: 'أربعين',
    5: 'خمسين',
    6: 'ستين',
    7: 'سبعين',
    8: 'ثمانين',
    9: 'تسعين',
  };

  // Hundreds
  static const Map<int, String> _hundreds = {
    1: 'مائة',
    2: 'مئتان',
    3: 'ثلاثمائة',
    4: 'أربعمائة',
    5: 'خمسمائة',
    6: 'ستمائة',
    7: 'سبعمائة',
    8: 'ثمانمائة',
    9: 'تسعمائة',
  };

  static const Map<int, String> _hundredsMajroor = {
    1: 'مائة',
    2: 'مئتين',
    3: 'ثلاثمائة',
    4: 'أربعمائة',
    5: 'خمسمائة',
    6: 'ستمائة',
    7: 'سبعمائة',
    8: 'ثمانمائة',
    9: 'تسعمائة',
  };

  // English words dictionaries
  static const List<String> _enUnits = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _enTens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  /// Converts an integer [number] to Arabic words with exact grammatical rules.
  static String numberToWordsAr(
    BigInt number, {
    bool isFeminine = false,
    GrammaticalCase grammaticalCase = GrammaticalCase.nominative,
  }) {
    if (number == BigInt.zero) return 'صفر';
    if (number < BigInt.zero) {
      return 'سالب ${numberToWordsAr(number.abs(), isFeminine: isFeminine, grammaticalCase: grammaticalCase)}';
    }

    final isMarfoo = grammaticalCase == GrammaticalCase.nominative;
    final parts = <String>[];

    final trillion = BigInt.from(1000000000000);
    final billion = BigInt.from(1000000000);
    final million = BigInt.from(1000000);
    final thousand = BigInt.from(1000);

    var remaining = number;

    // Trillions
    if (remaining >= trillion) {
      final t = (remaining ~/ trillion).toInt();
      remaining = remaining % trillion;
      parts.add(_scaleToWordsAr(t, 'تريليون', isMarfoo ? 'تريليونان' : 'تريليونين', 'تريليونات', isMarfoo));
    }

    // Billions
    if (remaining >= billion) {
      final b = (remaining ~/ billion).toInt();
      remaining = remaining % billion;
      parts.add(_scaleToWordsAr(b, 'مليار', isMarfoo ? 'ملياران' : 'مليارين', 'مليارات', isMarfoo));
    }

    // Millions
    if (remaining >= million) {
      final m = (remaining ~/ million).toInt();
      remaining = remaining % million;
      parts.add(_scaleToWordsAr(m, 'مليون', isMarfoo ? 'مليونان' : 'مليونين', 'ملايين', isMarfoo));
    }

    // Thousands
    if (remaining >= thousand) {
      final k = (remaining ~/ thousand).toInt();
      remaining = remaining % thousand;
      parts.add(_scaleToWordsAr(k, 'ألف', isMarfoo ? 'ألفان' : 'ألفين', 'آلاف', isMarfoo));
    }

    // Remaining hundreds / tens / units (0..999)
    if (remaining > BigInt.zero) {
      parts.add(_chunkToWordsAr(
        remaining.toInt(),
        isFeminine: isFeminine,
        isMarfoo: isMarfoo,
      ));
    }

    return parts.join(' و');
  }

  static String _scaleToWordsAr(
    int scaleValue,
    String singular,
    String dual,
    String plural,
    bool isMarfoo,
  ) {
    if (scaleValue == 1) return singular;
    if (scaleValue == 2) return dual;
    if (scaleValue >= 3 && scaleValue <= 10) {
      final numWord = _chunkToWordsAr(scaleValue, isFeminine: true, isMarfoo: isMarfoo);
      return '$numWord $plural';
    }
    final numWord = _chunkToWordsAr(scaleValue, isFeminine: false, isMarfoo: isMarfoo);
    return '$numWord $singular';
  }

  static String _chunkToWordsAr(
    int n, {
    required bool isFeminine,
    required bool isMarfoo,
  }) {
    if (n == 0) return '';
    final parts = <String>[];

    final hundredsDigit = n ~/ 100;
    final tensAndUnits = n % 100;

    if (hundredsDigit > 0) {
      final hMap = isMarfoo ? _hundreds : _hundredsMajroor;
      parts.add(hMap[hundredsDigit]!);
    }

    if (tensAndUnits > 0) {
      if (tensAndUnits < 10) {
        final uMap = isFeminine
            ? (isMarfoo ? _unitsFem : _unitsFemMajroor)
            : (isMarfoo ? _unitsMasc : _unitsMascMajroor);
        parts.add(uMap[tensAndUnits]!);
      } else if (tensAndUnits == 10) {
        parts.add(isFeminine ? 'عشر' : 'عشرة');
      } else if (tensAndUnits == 11) {
        parts.add(isFeminine ? 'إحدى عشرة' : 'أحد عشر');
      } else if (tensAndUnits == 12) {
        if (isFeminine) {
          parts.add(isMarfoo ? 'اثنتا عشرة' : 'اثنتي عشرة');
        } else {
          parts.add(isMarfoo ? 'اثنا عشر' : 'اثني عشر');
        }
      } else if (tensAndUnits < 20) {
        // 13..19: first part opposes gender, second part matches gender
        final unitPart = tensAndUnits % 10;
        final uWord = isFeminine ? _unitsMasc[unitPart]! : _unitsFem[unitPart]!;
        final tenWord = isFeminine ? 'عشرة' : 'عشر';
        parts.add('$uWord $tenWord');
      } else {
        // 20..99
        final unitDigit = tensAndUnits % 10;
        final tenDigit = tensAndUnits ~/ 10;
        final tMap = isMarfoo ? _tensMarfoo : _tensMajroor;
        final tenWord = tMap[tenDigit]!;

        if (unitDigit == 0) {
          parts.add(tenWord);
        } else {
          final uMap = isFeminine
              ? (isMarfoo ? _unitsFem : _unitsFemMajroor)
              : (isMarfoo ? _unitsMasc : _unitsMascMajroor);
          final uWord = uMap[unitDigit]!;
          parts.add('$uWord و$tenWord');
        }
      }
    }

    return parts.join(' و');
  }

  /// Converts an integer [number] to English words.
  static String numberToWordsEn(BigInt number) {
    if (number == BigInt.zero) return 'Zero';
    if (number < BigInt.zero) {
      return 'Minus ${numberToWordsEn(number.abs())}';
    }

    final trillion = BigInt.from(1000000000000);
    final billion = BigInt.from(1000000000);
    final million = BigInt.from(1000000);
    final thousand = BigInt.from(1000);

    final parts = <String>[];
    var remaining = number;

    if (remaining >= trillion) {
      final t = (remaining ~/ trillion).toInt();
      remaining = remaining % trillion;
      parts.add('${_chunkToWordsEn(t)} Trillion');
    }

    if (remaining >= billion) {
      final b = (remaining ~/ billion).toInt();
      remaining = remaining % billion;
      parts.add('${_chunkToWordsEn(b)} Billion');
    }

    if (remaining >= million) {
      final m = (remaining ~/ million).toInt();
      remaining = remaining % million;
      parts.add('${_chunkToWordsEn(m)} Million');
    }

    if (remaining >= thousand) {
      final k = (remaining ~/ thousand).toInt();
      remaining = remaining % thousand;
      parts.add('${_chunkToWordsEn(k)} Thousand');
    }

    if (remaining > BigInt.zero) {
      parts.add(_chunkToWordsEn(remaining.toInt()));
    }

    return parts.join(' ');
  }

  static String _chunkToWordsEn(int n) {
    if (n == 0) return '';
    final parts = <String>[];

    final hundreds = n ~/ 100;
    final tensAndUnits = n % 100;

    if (hundreds > 0) {
      parts.add('${_enUnits[hundreds]} Hundred');
    }

    if (tensAndUnits > 0) {
      if (tensAndUnits < 20) {
        parts.add(_enUnits[tensAndUnits]);
      } else {
        final tens = tensAndUnits ~/ 10;
        final units = tensAndUnits % 10;
        if (units == 0) {
          parts.add(_enTens[tens]);
        } else {
          parts.add('${_enTens[tens]}-${_enUnits[units]}');
        }
      }
    }

    return parts.join(' ');
  }

  /// Converts a major amount and subunit amount to formal Arabic currency words.
  static String formatCurrencyAr({
    required BigInt majorAmount,
    required BigInt subunitAmount,
    required KhaleejCurrency currency,
    GrammaticalCase grammaticalCase = GrammaticalCase.nominative,
    bool includeLegalSuffix = true,
  }) {
    final isMarfoo = grammaticalCase == GrammaticalCase.nominative;
    final buffer = StringBuffer();

    // 1. Format Major Currency
    if (majorAmount > BigInt.zero || subunitAmount == BigInt.zero) {
      final majorWords = _formatMajorAmountWithCurrency(
        majorAmount,
        currency,
        isMarfoo,
        grammaticalCase,
      );
      buffer.write(majorWords);
    }

    // 2. Format Subunit Amount
    if (subunitAmount > BigInt.zero) {
      if (buffer.isNotEmpty) {
        buffer.write(' و');
      }
      final subunitWords = _formatSubunitAmountWithCurrency(
        subunitAmount,
        currency,
        isMarfoo,
        grammaticalCase,
      );
      buffer.write(subunitWords);
    }

    if (includeLegalSuffix) {
      buffer.write(' فقط لا غير');
    }

    return buffer.toString().trim();
  }

  static String _formatMajorAmountWithCurrency(
    BigInt amount,
    KhaleejCurrency currency,
    bool isMarfoo,
    GrammaticalCase grammaticalCase,
  ) {
    if (amount == BigInt.zero) {
      return 'صفر ${currency.nameAr}';
    }

    if (amount == BigInt.one) {
      return currency.nameAr;
    }

    if (amount == BigInt.two) {
      return isMarfoo ? currency.dualNameArMarfoo : currency.dualNameArMajroor;
    }

    final numWords = numberToWordsAr(
      amount,
      isFeminine: currency.isMajorFeminine,
      grammaticalCase: grammaticalCase,
    );

    final lastTwoDigits = (amount % BigInt.from(100)).toInt();
    if (lastTwoDigits >= 3 && lastTwoDigits <= 10) {
      return '$numWords ${currency.pluralNameAr}';
    } else if (lastTwoDigits >= 11 && lastTwoDigits <= 99) {
      // Mansoob singular
      return '$numWords ${currency.nameAr}';
    } else {
      return '$numWords ${currency.nameAr}';
    }
  }

  static String _formatSubunitAmountWithCurrency(
    BigInt amount,
    KhaleejCurrency currency,
    bool isMarfoo,
    GrammaticalCase grammaticalCase,
  ) {
    if (amount == BigInt.zero) {
      return '';
    }

    if (amount == BigInt.one) {
      return currency.subunitNameAr;
    }

    if (amount == BigInt.two) {
      return isMarfoo
          ? currency.subunitDualNameArMarfoo
          : currency.subunitDualNameArMajroor;
    }

    final numWords = numberToWordsAr(
      amount,
      isFeminine: currency.isSubunitFeminine,
      grammaticalCase: grammaticalCase,
    );

    final lastTwoDigits = (amount % BigInt.from(100)).toInt();
    if (lastTwoDigits >= 3 && lastTwoDigits <= 10) {
      return '$numWords ${currency.subunitPluralNameAr}';
    } else {
      return '$numWords ${currency.subunitNameAr}';
    }
  }

  /// Converts a major amount and subunit amount to formal English currency words.
  static String formatCurrencyEn({
    required BigInt majorAmount,
    required BigInt subunitAmount,
    required KhaleejCurrency currency,
    bool includeLegalSuffix = true,
  }) {
    final buffer = StringBuffer();

    if (majorAmount > BigInt.zero || subunitAmount == BigInt.zero) {
      final majorWords = numberToWordsEn(majorAmount);
      final currencyName =
          majorAmount == BigInt.one ? currency.nameEn : '${currency.nameEn}s';
      buffer.write('$majorWords $currencyName');
    }

    if (subunitAmount > BigInt.zero) {
      if (buffer.isNotEmpty) {
        buffer.write(' and ');
      }
      final subunitWords = numberToWordsEn(subunitAmount);
      final subunitName = subunitAmount == BigInt.one
          ? currency.subunitNameEn
          : '${currency.subunitNameEn}s';
      buffer.write('$subunitWords $subunitName');
    }

    if (includeLegalSuffix) {
      buffer.write(' only');
    }

    return buffer.toString().trim();
  }
}
