import 'khaleej_currency.dart';
import 'khaleej_money.dart';

/// Islamic financial year type used for Zakat calculation.
enum IslamicCalendarYear {
  /// Hijri Lunar Year (سنة قمرية هجرية - 354 days).
  ///
  /// Standard Zakat rate is 2.5% (1/40th of wealth).
  hijri(ratePercent: 2.5),

  /// Gregorian Solar Year (سنة شمسية ميلادية - 365.25 days).
  ///
  /// Adjusted Zakat rate is 2.5775% per AAOIFI Standard No. 35 and ZATCA regulations
  /// to account for the additional 11.25 solar days (`2.5% * 365.25 / 354`).
  gregorian(ratePercent: 2.5775);

  const IslamicCalendarYear({required this.ratePercent});

  /// The statutory Zakat rate percentage for this calendar year.
  final double ratePercent;
}

/// Comprehensive breakdown of a calculated Zakat liability.
class ZakatBreakdown {
  const ZakatBreakdown({
    required this.totalWealth,
    required this.zakatDue,
    required this.netWealthRemaining,
    required this.ratePercent,
    required this.yearType,
    required this.isZakatDue,
    this.nisabThreshold,
    this.note,
  });

  /// Total Zakatable wealth / net liquid assets.
  final KhaleejMoney totalWealth;

  /// The calculated Zakat amount due (or zero if below Nisab).
  final KhaleejMoney zakatDue;

  /// Net wealth remaining after deducting Zakat (`totalWealth - zakatDue`).
  final KhaleejMoney netWealthRemaining;

  /// Applied Zakat rate percentage (2.5% for Hijri, 2.5775% for Gregorian).
  final double ratePercent;

  /// Calendar year basis (Hijri or Gregorian).
  final IslamicCalendarYear yearType;

  /// Whether the wealth meets or exceeds the Nisab threshold.
  final bool isZakatDue;

  /// The Nisab threshold used for evaluation, if provided.
  final KhaleejMoney? nisabThreshold;

  /// Explanatory regulatory or Shari'ah note.
  final String? note;

  @override
  String toString() =>
      'ZakatBreakdown(Wealth: $totalWealth, ZakatDue: $zakatDue, Rate: $ratePercent%, ValidDue: $isZakatDue)';
}

/// Shari'ah-compliant Zakat calculation engine according to AAOIFI Standard No. 35
/// and Saudi ZATCA Zakat Collection Regulations.
class KhaleejZakat {
  const KhaleejZakat._();

  /// Calculates statutory Zakat on Zakatable financial wealth.
  ///
  /// Parameters:
  /// - [wealth]: Zakatable net wealth / liquid assets held for one full lunar hawl (حول).
  /// - [yearType]: Calendar year type (defaults to [IslamicCalendarYear.hijri] at 2.5%).
  /// - [nisabThreshold]: Optional minimum wealth threshold (Nisab). If [wealth] is below
  ///   [nisabThreshold], [ZakatBreakdown.isZakatDue] will be false and [zakatDue] will be zero.
  static ZakatBreakdown calculate({
    required KhaleejMoney wealth,
    IslamicCalendarYear yearType = IslamicCalendarYear.hijri,
    KhaleejMoney? nisabThreshold,
  }) {
    if (nisabThreshold != null && nisabThreshold.currency != wealth.currency) {
      throw ArgumentError(
        'Currency mismatch: wealth is in ${wealth.currency.code} but nisabThreshold is in ${nisabThreshold.currency.code}.',
      );
    }

    final isDue = nisabThreshold == null || wealth >= nisabThreshold;

    if (!isDue) {
      return ZakatBreakdown(
        totalWealth: wealth,
        zakatDue: KhaleejMoney.zero(wealth.currency),
        netWealthRemaining: wealth,
        ratePercent: yearType.ratePercent,
        yearType: yearType,
        isZakatDue: false,
        nisabThreshold: nisabThreshold,
        note: 'Wealth is below the Nisab threshold; no Zakat is due.',
      );
    }

    // High precision calculation using percentage method
    final zakatDue = wealth.percentage(yearType.ratePercent);
    final remaining = wealth - zakatDue;

    return ZakatBreakdown(
      totalWealth: wealth,
      zakatDue: zakatDue,
      netWealthRemaining: remaining,
      ratePercent: yearType.ratePercent,
      yearType: yearType,
      isZakatDue: true,
      nisabThreshold: nisabThreshold,
      note: yearType == IslamicCalendarYear.hijri
          ? 'Calculated at 2.5% on Hijri lunar year (354 days).'
          : 'Calculated at 2.5775% on Gregorian solar year (365.25 days) per AAOIFI Standard No. 35.',
    );
  }

  /// Calculates the official Gold Nisab threshold (85 grams of pure 24k gold) in the given [currency].
  ///
  /// Parameters:
  /// - [currency]: The target GCC currency.
  /// - [goldPricePerGram]: Current market price of 1 gram of 24k gold in that currency.
  static KhaleejMoney calculateGoldNisab({
    required KhaleejCurrency currency,
    required num goldPricePerGram,
  }) {
    if (goldPricePerGram <= 0) {
      throw ArgumentError('Gold price per gram must be greater than zero.');
    }
    const gramsOfGoldInNisab = 85.0;
    return KhaleejMoney.fromMajor(gramsOfGoldInNisab * goldPricePerGram, currency);
  }

  /// Calculates the official Silver Nisab threshold (595 grams of pure silver) in the given [currency].
  ///
  /// Parameters:
  /// - [currency]: The target GCC currency.
  /// - [silverPricePerGram]: Current market price of 1 gram of pure silver in that currency.
  static KhaleejMoney calculateSilverNisab({
    required KhaleejCurrency currency,
    required num silverPricePerGram,
  }) {
    if (silverPricePerGram <= 0) {
      throw ArgumentError('Silver price per gram must be greater than zero.');
    }
    const gramsOfSilverInNisab = 595.0;
    return KhaleejMoney.fromMajor(gramsOfSilverInNisab * silverPricePerGram, currency);
  }
}
