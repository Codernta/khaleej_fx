import '../core/gcc_country.dart';
import '../identity/khaleej_id.dart';
import 'card_brand.dart';
import 'card_masker.dart';
import 'domestic_switches.dart';

/// Inspection result for a payment card.
class CardValidationResult {
  const CardValidationResult({
    required this.raw,
    required this.isValidLuhn,
    required this.brand,
    required this.domesticSwitch,
    required this.issuingCountry,
    this.errorMessage,
  });

  /// Digits of the card PAN.
  final String raw;

  /// Whether the card number passes the Luhn (Modulo 10) algorithm.
  final bool isValidLuhn;

  /// Detected brand (e.g. Mada, Visa, Mastercard).
  final CardBrand brand;

  /// Domestic GCC switch scheme, if applicable.
  final GccDomesticSwitch domesticSwitch;

  /// Issuing GCC country, or null if international.
  final GccCountry? issuingCountry;

  /// Error message if invalid.
  final String? errorMessage;

  /// Returns true if valid Luhn and recognized card length.
  bool get isValid => isValidLuhn && errorMessage == null;

  /// Formatted card number with standard spacing.
  String get formatted => CardMasker.format(raw);

  /// PCI DSS 4.0 masked card number.
  String mask({
    bool preserveBin = false,
    String maskChar = 'X',
    String delimiter = ' ',
  }) =>
      CardMasker.mask(
        raw,
        preserveBin: preserveBin,
        maskChar: maskChar,
        delimiter: delimiter,
      );

  @override
  String toString() => '$brand (${domesticSwitch.nameEn}) - ${mask()}';
}

/// Card validator and switch detection for GCC fintech.
class CardValidator {
  const CardValidator._();

  /// Validates a card PAN against Luhn Modulo 10 and identifies its brand and GCC switch.
  static CardValidationResult validate(String cardNumber) {
    final clean = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (clean.length < 12 || clean.length > 19) {
      return CardValidationResult(
        raw: clean,
        isValidLuhn: false,
        brand: CardBrand.unknown,
        domesticSwitch: GccDomesticSwitch.none,
        issuingCountry: null,
        errorMessage: 'Invalid card number length (${clean.length} digits)',
      );
    }

    final isLuhnValid = ChecksumUtils.verifyLuhn(clean);
    final domestic = DomesticSwitches.detectDomesticSwitch(clean);
    final brand = DomesticSwitches.detectBrand(clean);

    if (!isLuhnValid) {
      return CardValidationResult(
        raw: clean,
        isValidLuhn: false,
        brand: brand,
        domesticSwitch: domestic,
        issuingCountry: domestic.country,
        errorMessage: 'Invalid Luhn (Modulo 10) checksum',
      );
    }

    return CardValidationResult(
      raw: clean,
      isValidLuhn: true,
      brand: brand,
      domesticSwitch: domestic,
      issuingCountry: domestic.country,
    );
  }
}
