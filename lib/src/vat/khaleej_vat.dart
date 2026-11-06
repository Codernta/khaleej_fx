import '../core/gcc_country.dart';
import '../money/khaleej_money.dart';

/// Breakdown of a calculated Value Added Tax (VAT) transaction.
class VatBreakdown {
  const VatBreakdown({
    required this.baseAmount,
    required this.vatAmount,
    required this.totalAmount,
    required this.vatRatePercent,
    required this.isReverseCharge,
    this.note,
  });

  /// The net taxable amount before tax.
  final KhaleejMoney baseAmount;

  /// The calculated VAT amount.
  final KhaleejMoney vatAmount;

  /// The gross total amount (base + VAT).
  final KhaleejMoney totalAmount;

  /// Applicable VAT rate percentage (e.g. 15.0 for KSA, 5.0 for UAE).
  final double vatRatePercent;

  /// Whether this transaction is subject to the Intra-GCC Reverse Charge Mechanism.
  final bool isReverseCharge;

  /// Regulatory or explanatory note (e.g. 'Subject to Reverse Charge').
  final String? note;

  @override
  String toString() =>
      'Base: $baseAmount | VAT (${vatRatePercent.toStringAsFixed(1)}%): $vatAmount | Total: $totalAmount';
}

/// Standard GCC Value Added Tax (VAT) rates and calculation engine.
class KhaleejVat {
  const KhaleejVat._();

  /// Standard VAT rate percentage per GCC country.
  static const Map<GccCountry, double> standardRates = {
    GccCountry.saudiArabia: 15.0,
    GccCountry.uae: 5.0,
    GccCountry.bahrain: 10.0,
    GccCountry.oman: 5.0,
    GccCountry.kuwait: 0.0,
    GccCountry.qatar: 0.0,
  };

  /// Gets the standard VAT rate percentage for a given [country].
  static double rateFor(GccCountry country) => standardRates[country] ?? 0.0;

  /// Calculates VAT added on top of a net taxable [baseAmount] (Exclusive VAT).
  ///
  /// Example: 100 SAR base + 15% VAT = 15 SAR VAT, 115 SAR Total.
  static VatBreakdown calculateExclusive({
    required KhaleejMoney baseAmount,
    double? customRatePercent,
    GccCountry? country,
  }) {
    final rate = customRatePercent ?? (country != null ? rateFor(country) : rateFor(countryFromCurrency(baseAmount)));
    final vat = baseAmount.percentage(rate);
    final total = baseAmount + vat;

    return VatBreakdown(
      baseAmount: baseAmount,
      vatAmount: vat,
      totalAmount: total,
      vatRatePercent: rate,
      isReverseCharge: false,
    );
  }

  /// Calculates base amount and VAT extracted from a gross inclusive [totalAmount] (Inclusive VAT).
  ///
  /// Formula:
  /// `base = total / (1 + rate / 100)`
  /// `vat = total - base`
  ///
  /// Example: 115 SAR total at 15% -> 100 SAR base, 15 SAR VAT.
  static VatBreakdown calculateInclusive({
    required KhaleejMoney totalAmount,
    double? customRatePercent,
    GccCountry? country,
  }) {
    final rate = customRatePercent ?? (country != null ? rateFor(country) : rateFor(countryFromCurrency(totalAmount)));
    final divisor = 1.0 + (rate / 100.0);
    final base = totalAmount / divisor;
    final vat = totalAmount - base;

    return VatBreakdown(
      baseAmount: baseAmountRound(base, totalAmount),
      vatAmount: vat,
      totalAmount: totalAmount,
      vatRatePercent: rate,
      isReverseCharge: false,
    );
  }

  /// Calculates Intra-GCC cross-border VAT according to Unified GCC VAT Agreement rules.
  ///
  /// If the customer in [destinationCountry] provides a valid [customerVatNumber] (B2B),
  /// the transaction qualifies for the **Reverse Charge Mechanism**:
  /// - Supplier charges 0% VAT.
  /// - Customer self-accounts for VAT in destination member state.
  ///
  /// If B2C (no VAT number), standard origin country VAT is levied.
  static VatBreakdown calculateCrossBorder({
    required KhaleejMoney amount,
    required GccCountry originCountry,
    required GccCountry destinationCountry,
    String? customerVatNumber,
    bool isAmountInclusive = false,
  }) {
    final hasValidVatId = customerVatNumber != null &&
        customerVatNumber.trim().isNotEmpty &&
        customerVatNumber.length >= 10;

    final isSameCountry = originCountry == destinationCountry;

    if (!isSameCountry && hasValidVatId) {
      // Intra-GCC B2B: Reverse Charge Mechanism (0% local VAT)
      return VatBreakdown(
        baseAmount: amount,
        vatAmount: KhaleejMoney.zero(amount.currency),
        totalAmount: amount,
        vatRatePercent: 0.0,
        isReverseCharge: true,
        note:
            'Intra-GCC supply: Subject to Reverse Charge in ${destinationCountry.nameEn} by customer ($customerVatNumber)',
      );
    }

    // Standard Domestic or B2C export
    final rate = rateFor(originCountry);
    if (isAmountInclusive) {
      return calculateInclusive(
        totalAmount: amount,
        customRatePercent: rate,
      );
    } else {
      return calculateExclusive(
        baseAmount: amount,
        customRatePercent: rate,
      );
    }
  }

  static KhaleejMoney baseAmountRound(KhaleejMoney base, KhaleejMoney total) {
    // Exact fixed-point balance: base = total - (total - base)
    return total - (total - base);
  }

  static GccCountry countryFromCurrency(KhaleejMoney money) {
    return money.currency.country;
  }
}
