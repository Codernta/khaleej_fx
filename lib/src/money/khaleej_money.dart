import '../utils/numeral_converter.dart';
import 'khaleej_currency.dart';
import 'tafqeet.dart';

/// An immutable, high-precision monetary value for GCC currencies.
///
/// Internal representation is held in integer sub-units (`BigInt`) to eliminate
/// floating-point inaccuracies in financial calculations (e.g., 100 Halalas = 1 SAR,
/// 1000 Fils = 1 KWD).
class KhaleejMoney implements Comparable<KhaleejMoney> {
  /// Constructs a [KhaleejMoney] instance with a specified count of [totalSubunits].
  const KhaleejMoney.fromSubunits(this.totalSubunits, this.currency);

  /// Constructs a [KhaleejMoney] from integer [subunits].
  KhaleejMoney.fromIntSubunits(int subunits, this.currency)
      : totalSubunits = BigInt.from(subunits);

  /// Constructs a [KhaleejMoney] from major units (e.g. 100.50 SAR -> 10050 Halalas).
  factory KhaleejMoney.fromMajor(num amount, KhaleejCurrency currency) {
    final factor = currency.subunitFactor;
    // Round to avoid IEEE 754 precision issues like 100.50 * 100 = 10049.999999999998
    final rounded = (amount * factor).round();
    return KhaleejMoney.fromSubunits(BigInt.from(rounded), currency);
  }

  /// Constructs a zero amount for the given [currency].
  factory KhaleejMoney.zero(KhaleejCurrency currency) =>
      KhaleejMoney.fromSubunits(BigInt.zero, currency);

  /// Constructs a [KhaleejMoney] from a US Dollar amount using official central bank pegged parities.
  ///
  /// Example:
  /// ```dart
  /// final sar = KhaleejMoney.fromUsd(100, KhaleejCurrency.sar); // 375.00 SAR
  /// ```
  factory KhaleejMoney.fromUsd(num usdAmount, KhaleejCurrency targetCurrency) {
    final rate = targetCurrency.peggedRateToUsd;
    final factor = targetCurrency.subunitFactor;
    final roundedSubunits = (usdAmount * rate * factor).round();
    return KhaleejMoney.fromSubunits(BigInt.from(roundedSubunits), targetCurrency);
  }

  /// Parses a string representing a monetary amount (e.g. "1,250.75" or "1250.750").
  factory KhaleejMoney.parse(String text, KhaleejCurrency currency) {
    final parsed = tryParse(text, currency);
    if (parsed == null) {
      throw FormatException('Invalid money format: "$text" for $currency');
    }
    return parsed;
  }

  /// Attempts to parse a string representation of a monetary value.
  static KhaleejMoney? tryParse(String text, KhaleejCurrency currency) {
    var clean = text.trim();
    // Normalize Arabic-Indic numerals if present
    clean = NumeralConverter.toWesternArabic(clean, convertSeparators: true);

    // Remove currency codes and symbols if present
    clean = clean
        .replaceAll(currency.code, '')
        .replaceAll(currency.symbolEn, '')
        .replaceAll(currency.symbolAr, '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.');

    if (clean.isEmpty) return null;

    final isNegative = clean.startsWith('-');
    if (isNegative || clean.startsWith('+')) {
      clean = clean.substring(1).trim();
    }

    final parts = clean.split('.');
    if (parts.length > 2) return null;

    final majorPart = parts[0].isEmpty ? '0' : parts[0];
    final majorBig = BigInt.tryParse(majorPart);
    if (majorBig == null) return null;

    var subunitBig = BigInt.zero;
    if (parts.length == 2) {
      var frac = parts[1];
      if (frac.length > currency.decimals) {
        // Round to currency decimals
        final roundDigit = int.tryParse(frac[currency.decimals]) ?? 0;
        frac = frac.substring(0, currency.decimals);
        var sub = BigInt.tryParse(frac) ?? BigInt.zero;
        if (roundDigit >= 5) {
          sub += BigInt.one;
        }
        subunitBig = sub;
      } else {
        while (frac.length < currency.decimals) {
          frac = '${frac}0';
        }
        subunitBig = BigInt.tryParse(frac) ?? BigInt.zero;
      }
    }

    var total = (majorBig * currency.subunitFactorBigInt) + subunitBig;
    if (isNegative) {
      total = -total;
    }

    return KhaleejMoney.fromSubunits(total, currency);
  }

  /// Total amount stored in the currency's minor units (e.g. Halalas or Fils).
  final BigInt totalSubunits;

  /// The GCC currency.
  final KhaleejCurrency currency;

  /// Whole major currency units (e.g. Riyals or Dinars).
  BigInt get majorUnits => totalSubunits ~/ currency.subunitFactorBigInt;

  /// The fractional sub-unit remainder (0 to 99 for 2-dec, 0 to 999 for 3-dec).
  BigInt get subunitsRemainder =>
      (totalSubunits % currency.subunitFactorBigInt).abs();

  /// Decimal representation as standard Dart double.
  double get asDouble => totalSubunits.toDouble() / currency.subunitFactor;

  /// Returns true if the monetary amount is strictly greater than zero.
  bool get isPositive => totalSubunits > BigInt.zero;

  /// Returns true if the monetary amount is strictly less than zero.
  bool get isNegative => totalSubunits < BigInt.zero;

  /// Returns true if the monetary amount is zero.
  bool get isZero => totalSubunits == BigInt.zero;

  /// Absolute value.
  KhaleejMoney abs() =>
      KhaleejMoney.fromSubunits(totalSubunits.abs(), currency);

  /// Negated value.
  KhaleejMoney operator -() =>
      KhaleejMoney.fromSubunits(-totalSubunits, currency);

  /// Adds another [KhaleejMoney] value. Must share the same currency.
  KhaleejMoney operator +(KhaleejMoney other) {
    _ensureSameCurrency(other);
    return KhaleejMoney.fromSubunits(totalSubunits + other.totalSubunits, currency);
  }

  /// Subtracts another [KhaleejMoney] value. Must share the same currency.
  KhaleejMoney operator -(KhaleejMoney other) {
    _ensureSameCurrency(other);
    return KhaleejMoney.fromSubunits(totalSubunits - other.totalSubunits, currency);
  }

  /// Multiplies the monetary amount by a scalar factor [multiplier].
  KhaleejMoney operator *(num multiplier) {
    final result = (totalSubunits.toDouble() * multiplier).round();
    return KhaleejMoney.fromSubunits(BigInt.from(result), currency);
  }

  /// Divides the monetary amount by a scalar divisor [divisor].
  KhaleejMoney operator /(num divisor) {
    if (divisor == 0) {
      throw ArgumentError('Division by zero is not allowed in money arithmetic');
    }
    final result = (totalSubunits.toDouble() / divisor).round();
    return KhaleejMoney.fromSubunits(BigInt.from(result), currency);
  }

  /// Calculates a percentage of this monetary amount (e.g. `money.percentage(15)` for 15% VAT).
  KhaleejMoney percentage(num percent) {
    return this * (percent / 100.0);
  }

  /// Converts this monetary amount to another GCC currency using official central bank pegged parities.
  ///
  /// Conversions maintain integer subunit precision:
  /// - SAR (3.7500 / USD)
  /// - AED (3.6725 / USD)
  /// - QAR (3.6400 / USD)
  /// - BHD (0.3760 / USD)
  /// - OMR (0.3845 / USD)
  /// - KWD (0.3075 / USD)
  ///
  /// Example:
  /// ```dart
  /// final sar = KhaleejMoney.fromMajor(100, KhaleejCurrency.sar);
  /// final aed = sar.convertToPegged(KhaleejCurrency.aed); // 97.93 AED
  /// ```
  KhaleejMoney convertToPegged(KhaleejCurrency targetCurrency) {
    if (currency == targetCurrency) return this;

    // Scale rates by 1,000,000 (6 decimal places) for high-precision integer arithmetic
    const scale = 1000000;
    final sourceRateScaled = BigInt.from((currency.peggedRateToUsd * scale).round());
    final targetRateScaled = BigInt.from((targetCurrency.peggedRateToUsd * scale).round());
    final sourceFactor = currency.subunitFactorBigInt;
    final targetFactor = targetCurrency.subunitFactorBigInt;

    // targetSubunits = (sourceSubunits * targetFactor * targetRateScaled) / (sourceFactor * sourceRateScaled)
    final numerator = totalSubunits * targetFactor * targetRateScaled;
    final denominator = sourceFactor * sourceRateScaled;

    // Half-up integer rounding
    final halfDenominator = denominator ~/ BigInt.from(2);
    final isNegative = numerator < BigInt.zero;
    final roundedNumerator = isNegative
        ? numerator - halfDenominator
        : numerator + halfDenominator;

    final targetSubunits = roundedNumerator ~/ denominator;
    return KhaleejMoney.fromSubunits(targetSubunits, targetCurrency);
  }

  @override
  int compareTo(KhaleejMoney other) {
    _ensureSameCurrency(other);
    return totalSubunits.compareTo(other.totalSubunits);
  }

  bool operator <(KhaleejMoney other) => compareTo(other) < 0;
  bool operator <=(KhaleejMoney other) => compareTo(other) <= 0;
  bool operator >(KhaleejMoney other) => compareTo(other) > 0;
  bool operator >=(KhaleejMoney other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KhaleejMoney &&
        other.currency == currency &&
        other.totalSubunits == totalSubunits;
  }

  @override
  int get hashCode => Object.hash(currency, totalSubunits);

  void _ensureSameCurrency(KhaleejMoney other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Currency mismatch: cannot perform arithmetic between ${currency.code} and ${other.currency.code}.',
      );
    }
  }

  /// Formats the money into a formatted string with grouping and decimals.
  ///
  /// Examples:
  /// - `1,250.50 SAR`
  /// - `د.ك 1,250.750`
  /// - `١٬٢٥٠٫٥٠ ر.س`
  String format({
    bool includeSymbol = true,
    bool useArabicSymbol = false,
    bool symbolAtEnd = true,
    bool useArabicNumerals = false,
    String thousandsSeparator = ',',
    String decimalSeparator = '.',
  }) {
    final isNeg = isNegative;
    final absMajor = majorUnits.abs().toString();
    final rem = subunitsRemainder.toString().padLeft(currency.decimals, '0');

    // Group major units in 3-digit comma groups
    final buffer = StringBuffer();
    final len = absMajor.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(thousandsSeparator);
      }
      buffer.write(absMajor[i]);
    }

    buffer.write(decimalSeparator);
    buffer.write(rem);

    var formattedNum = (isNeg ? '-' : '') + buffer.toString();

    if (useArabicNumerals) {
      formattedNum = _toArabicIndicNumerals(
        formattedNum,
        thousandsSeparator: thousandsSeparator,
        decimalSeparator: decimalSeparator,
      );
    }

    if (!includeSymbol) {
      return formattedNum;
    }

    final symbol = useArabicSymbol ? currency.symbolAr : currency.symbolEn;
    if (symbolAtEnd) {
      return '$formattedNum $symbol';
    } else {
      return '$symbol $formattedNum';
    }
  }

  /// Converts this monetary value to formal Arabic words (Tafqeet).
  String toWordsAr({
    GrammaticalCase grammaticalCase = GrammaticalCase.nominative,
    bool includeLegalSuffix = true,
  }) {
    return Tafqeet.formatCurrencyAr(
      majorAmount: majorUnits.abs(),
      subunitAmount: subunitsRemainder,
      currency: currency,
      grammaticalCase: grammaticalCase,
      includeLegalSuffix: includeLegalSuffix,
    );
  }

  /// Converts this monetary value to formal English words.
  String toWordsEn({bool includeLegalSuffix = true}) {
    return Tafqeet.formatCurrencyEn(
      majorAmount: majorUnits.abs(),
      subunitAmount: subunitsRemainder,
      currency: currency,
      includeLegalSuffix: includeLegalSuffix,
    );
  }

  static String _toArabicIndicNumerals(
    String input, {
    required String thousandsSeparator,
    required String decimalSeparator,
  }) {
    const westernToIndic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    final out = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == thousandsSeparator) {
        out.write('٬');
      } else if (char == decimalSeparator) {
        out.write('٫');
      } else if (westernToIndic.containsKey(char)) {
        out.write(westernToIndic[char]);
      } else {
        out.write(char);
      }
    }
    return out.toString();
  }

  @override
  String toString() => format();
}
