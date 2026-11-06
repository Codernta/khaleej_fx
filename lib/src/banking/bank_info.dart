import '../core/gcc_country.dart';

/// Metadata for a financial institution / bank operating in the GCC.
class BankInfo {
  const BankInfo({
    required this.country,
    required this.bankCode,
    required this.nameEn,
    required this.nameAr,
    required this.bic,
    this.shortName,
  });

  /// Country where the bank is headquartered / regulated.
  final GccCountry country;

  /// Domestic bank identifier code used within the country's IBAN structure.
  final String bankCode;

  /// English bank name.
  final String nameEn;

  /// Arabic bank name.
  final String nameAr;

  /// SWIFT / BIC code.
  final String bic;

  /// Short marketing name or acronym (e.g. SNB, FAB, NBK).
  final String? shortName;

  @override
  String toString() => '$nameEn ($bankCode) [$bic]';
}
