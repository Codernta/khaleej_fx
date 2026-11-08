import '../core/gcc_country.dart';
import '../security/timing_safe.dart';
import 'bank_directory.dart';
import 'bank_info.dart';

/// Validation and parsing result for a GCC International Bank Account Number (IBAN).
class GccIban {
  const GccIban({
    required this.raw,
    required this.isValid,
    this.country,
    this.checkDigits,
    this.bankCode,
    this.bankInfo,
    this.accountNumber,
    this.errorMessage,
  });

  /// Sanitized uppercase IBAN without spaces.
  final String raw;

  /// Whether the IBAN passes ISO 13616 structure and ISO 7064 Mod 97-10 checksum.
  final bool isValid;

  /// Issuing GCC country.
  final GccCountry? country;

  /// 2-digit checksum extracted from characters 2..4.
  final String? checkDigits;

  /// Domestic bank identifier extracted from the IBAN.
  final String? bankCode;

  /// Bank information from the GCC Bank Directory, if recognized.
  final BankInfo? bankInfo;

  /// Account number portion within the BBAN.
  final String? accountNumber;

  /// Error message explaining validation failure.
  final String? errorMessage;

  /// Formatted IBAN in 4-character blocks (e.g. `SA03 8000 0000 6080 1016 7519`).
  String get formatted => IbanValidator.format(raw);

  /// Privacy-compliant masked representation of the IBAN (PDPL / PCI compliant).
  String mask({String maskChar = '*', bool formatted = true}) =>
      IbanValidator.mask(raw, maskChar: maskChar, formatted: formatted);

  @override
  String toString() => formatted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GccIban &&
          runtimeType == other.runtimeType &&
          raw == other.raw;

  @override
  int get hashCode => raw.hashCode;
}

/// Enterprise ISO 13616 & ISO 7064 Mod 97-10 IBAN validator, generator, and formatter for GCC states.
class IbanValidator {
  const IbanValidator._();

  /// IBAN lengths per GCC country.
  static const Map<String, int> gccIbanLengths = {
    'SA': 24, // Saudi Arabia: SA + 2 check + 2 bank + 18 account
    'AE': 23, // UAE: AE + 2 check + 3 bank + 16 account
    'KW': 30, // Kuwait: KW + 2 check + 4 bank + 22 account
    'QA': 29, // Qatar: QA + 2 check + 4 bank + 21 account
    'BH': 22, // Bahrain: BH + 2 check + 4 bank + 14 account
    'OM': 23, // Oman: OM + 2 check + 3 bank + 16 account
  };

  /// Validates and parses a GCC IBAN.
  static GccIban validate(String input) {
    final clean = input.replaceAll(RegExp(r'\s+'), '').toUpperCase();

    if (clean.length < 4) {
      return GccIban(
        raw: clean,
        isValid: false,
        errorMessage: 'IBAN too short (minimum 4 characters)',
      );
    }

    final countryIso = clean.substring(0, 2);
    final country = GccCountry.fromCode(countryIso);

    if (country == null) {
      return GccIban(
        raw: clean,
        isValid: false,
        errorMessage: 'Country code "$countryIso" is not a recognized GCC member state',
      );
    }

    final expectedLength = gccIbanLengths[countryIso];
    if (expectedLength == null || clean.length != expectedLength) {
      return GccIban(
        raw: clean,
        isValid: false,
        country: country,
        errorMessage:
            'Invalid IBAN length for $countryIso: expected $expectedLength, got ${clean.length}',
      );
    }

    // Verify allowed characters (only alphanumeric A-Z, 0-9)
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(clean)) {
      return GccIban(
        raw: clean,
        isValid: false,
        country: country,
        errorMessage: 'IBAN contains invalid non-alphanumeric characters',
      );
    }

    // ISO 7064 Mod 97-10 Checksum Verification
    final mod97 = _computeMod97(clean);
    if (mod97 != 1) {
      return GccIban(
        raw: clean,
        isValid: false,
        country: country,
        checkDigits: clean.substring(2, 4),
        errorMessage: 'Invalid ISO 7064 Mod 97-10 checksum (remainder: $mod97)',
      );
    }

    // Extract bank code and account number based on country rules
    final checkDigits = clean.substring(2, 4);
    String bankCode;
    String accountNumber;

    switch (country) {
      case GccCountry.saudiArabia:
        // SAkk BB(2) CCCCCCCCCCCCCCCCCC(18)
        bankCode = clean.substring(4, 6);
        accountNumber = clean.substring(6);
      case GccCountry.uae:
        // AEkk BBB(3) CCCCCCCCCCCCCCCC(16)
        bankCode = clean.substring(4, 7);
        accountNumber = clean.substring(7);
      case GccCountry.kuwait:
        // KWkk BBBB(4) CCCCCCCCCCCCCCCCCCCCCC(22)
        bankCode = clean.substring(4, 8);
        accountNumber = clean.substring(8);
      case GccCountry.qatar:
        // QAkk BBBB(4) CCCCCCCCCCCCCCCCCCCCC(21)
        bankCode = clean.substring(4, 8);
        accountNumber = clean.substring(8);
      case GccCountry.bahrain:
        // BHkk BBBB(4) CCCCCCCCCCCCCC(14)
        bankCode = clean.substring(4, 8);
        accountNumber = clean.substring(8);
      case GccCountry.oman:
        // OMkk BBB(3) CCCCCCCCCCCCCCCC(16)
        bankCode = clean.substring(4, 7);
        accountNumber = clean.substring(7);
    }

    final bankInfo = BankDirectory.findBank(country, bankCode);

    return GccIban(
      raw: clean,
      isValid: true,
      country: country,
      checkDigits: checkDigits,
      bankCode: bankCode,
      bankInfo: bankInfo,
      accountNumber: accountNumber,
    );
  }

  /// Calculates ISO 7064 Mod 97 check digits for constructing a GCC IBAN.
  static String calculateCheckDigits({
    required GccCountry country,
    required String bankCode,
    required String accountNumber,
  }) {
    final countryIso = country.iso2.toUpperCase();
    final cleanBank = bankCode.trim().toUpperCase();
    final cleanAccount = accountNumber.trim().toUpperCase();

    // Prepare rearranged string with 00 check digits: BBAN + CC + 00
    final bban = '$cleanBank$cleanAccount';
    final rearranged = '$bban$countryIso' '00';

    final mod97 = _computeMod97NumericString(_convertToNumeric(rearranged));
    final checkNum = 98 - mod97;
    return checkNum.toString().padLeft(2, '0');
  }

  /// Generates a valid GCC IBAN string from country, bank code, and account number.
  static String generateIban({
    required GccCountry country,
    required String bankCode,
    required String accountNumber,
  }) {
    final checkDigits = calculateCheckDigits(
      country: country,
      bankCode: bankCode,
      accountNumber: accountNumber,
    );
    return '${country.iso2.toUpperCase()}$checkDigits$bankCode$accountNumber';
  }

  /// Formats an IBAN into standard 4-character blocks separated by a space.
  static String format(String iban) {
    final clean = iban.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final buffer = StringBuffer();
    for (var i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  /// Masks an IBAN for PCI DSS / PDPL compliance, preserving the country code and last 4 digits.
  ///
  /// Example: `SA03 8000 0000 6080 1016 7519` -> `SA** **** **** **** **** 7519`.
  static String mask(
    String iban, {
    String maskChar = '*',
    bool formatted = true,
  }) {
    final clean = iban.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (clean.length < 6) {
      return maskChar * clean.length;
    }

    final country = clean.substring(0, 2);
    final last4 = clean.substring(clean.length - 4);
    final middleLen = clean.length - 6;
    final maskedRaw = '$country${maskChar * middleLen}$last4';

    if (!formatted) {
      return maskedRaw;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < maskedRaw.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(maskedRaw[i]);
    }
    return buffer.toString();
  }

  /// Constant-time account / IBAN confirmation comparison.
  ///
  /// Prevents side-channel timing attacks when users confirm their IBAN or account details.
  static bool confirmIban(String iban1, String iban2) {
    final clean1 = iban1.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final clean2 = iban2.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    return TimingSafe.equalString(clean1, clean2);
  }

  static int _computeMod97(String iban) {
    // 1. Move first 4 characters to the end
    final rearranged = iban.substring(4) + iban.substring(0, 4);

    // 2. Replace letters with numeric equivalents (A=10, ..., Z=35)
    final numeric = _convertToNumeric(rearranged);

    // 3. Modulo 97
    return _computeMod97NumericString(numeric);
  }

  static String _convertToNumeric(String s) {
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        // '0'..'9'
        buffer.writeCharCode(code);
      } else if (code >= 65 && code <= 90) {
        // 'A'..'Z' -> 10..35
        buffer.write((code - 55).toString());
      }
    }
    return buffer.toString();
  }

  /// Efficient chunked Modulo 97 calculation on large numeric strings.
  static int _computeMod97NumericString(String numeric) {
    var remainder = 0;
    for (var i = 0; i < numeric.length; i++) {
      final digit = numeric.codeUnitAt(i) - 48;
      remainder = (remainder * 10 + digit) % 97;
    }
    return remainder;
  }
}
