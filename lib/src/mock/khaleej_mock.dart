import 'dart:math';
import '../banking/bank_directory.dart';
import '../banking/iban_validator.dart';
import '../cards/card_brand.dart';
import '../cards/domestic_switches.dart';
import '../core/gcc_country.dart';
import '../identity/bahrain_cpr.dart';
import '../identity/khaleej_id.dart';
import '../identity/kuwait_civil_id.dart';
import '../identity/qatar_id.dart';
import '../vat/zatca_qr.dart';

/// Synthetic test data generator for GCC Fintech QA environments and unit tests.
///
/// Under Saudi and UAE Personal Data Protection Laws (PDPL), using actual customer
/// PII, real National IDs, or production IBANs in development and staging environments
/// is strictly regulated or prohibited.
///
/// [KhaleejMock] generates mathematically and structurally valid synthetic mock data
/// (passing Luhn Mod 10, Mod 11, and ISO 7064 Mod 97-10 algorithms) without exposing
/// any real personal identifiable information.
class KhaleejMock {
  const KhaleejMock._();

  static final Random _rng = Random(42);

  /// Generates a valid synthetic Saudi National ID or Resident Iqama.
  ///
  /// - Starts with `1` (Citizen) or `2` (Resident Iqama).
  /// - Exactly 10 digits with a mathematically verified Luhn check digit.
  static String saudiId({bool isCitizen = true, int? sequence}) {
    final prefix = isCitizen ? '1' : '2';
    final seqNum = sequence ?? (_rng.nextInt(90000000) + 10000000);
    final body = '$prefix${seqNum.toString().padLeft(8, '0')}';
    final check = ChecksumUtils.calculateLuhnCheckDigit(body);
    return '$body$check';
  }

  /// Generates a valid synthetic UAE Emirates ID.
  ///
  /// - Exactly 15 digits formatted `784-YYYY-XXXXXXX-C`.
  /// - Satisfies Luhn Modulo 10 check digit.
  static String emiratesId({int birthYear = 1990, int? sequence}) {
    final seqNum = sequence ?? (_rng.nextInt(9000000) + 1000000);
    final prefix = '784$birthYear${seqNum.toString().padLeft(7, '0')}';
    final check = ChecksumUtils.calculateLuhnCheckDigit(prefix);
    return '$prefix$check';
  }

  /// Generates a valid synthetic Kuwait Civil ID.
  ///
  /// - 12 digits satisfying PACI Modulo 11 weighted checksum.
  static String kuwaitCivilId({
    int birthYear = 1992,
    int birthMonth = 5,
    int birthDay = 15,
    int? sequence,
  }) {
    final century = birthYear >= 2000 ? '3' : '2';
    final yy = (birthYear % 100).toString().padLeft(2, '0');
    final mm = birthMonth.toString().padLeft(2, '0');
    final dd = birthDay.toString().padLeft(2, '0');
    var seq = sequence ?? (_rng.nextInt(9000) + 1000);

    while (true) {
      final prefix = '$century$yy$mm$dd${seq.toString().padLeft(4, '0')}';
      var sum = 0;
      for (var i = 0; i < 11; i++) {
        sum += int.parse(prefix[i]) * KuwaitCivilId.weights[i];
      }
      final rem = sum % 11;
      if (rem != 1) {
        // rem == 1 yields 10 (not a single decimal digit), pick next seq
        final check = rem == 0 ? 0 : 11 - rem;
        return '$prefix$check';
      }
      seq++;
    }
  }

  /// Generates a valid synthetic Qatar ID (QID).
  ///
  /// - 11 digits satisfying Modulo 11 check digit.
  static String qatarId({
    int birthYear = 1995,
    String nationalityCode = '634',
    int? sequence,
  }) {
    final century = birthYear >= 2000 ? '3' : '2';
    final yy = (birthYear % 100).toString().padLeft(2, '0');
    final seq = sequence ?? (_rng.nextInt(9000) + 1000);
    final prefix = '$century$yy$nationalityCode${seq.toString().padLeft(4, '0')}';

    var sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += int.parse(prefix[i]) * QatarId.weights[i];
    }
    final check = (sum % 11) % 10;
    return '$prefix$check';
  }

  /// Generates a valid synthetic Bahrain CPR.
  ///
  /// - 9 digits satisfying Modulo 11 check digit.
  static String bahrainCpr({
    int birthYear = 1988,
    int birthMonth = 7,
    int? sequence,
  }) {
    final yy = (birthYear % 100).toString().padLeft(2, '0');
    final mm = birthMonth.toString().padLeft(2, '0');
    final seq = sequence ?? (_rng.nextInt(9000) + 1000);
    final prefix = '$yy$mm${seq.toString().padLeft(4, '0')}';

    var sum = 0;
    for (var i = 0; i < 8; i++) {
      sum += int.parse(prefix[i]) * BahrainCpr.weights[i];
    }
    final check = (sum % 11) % 10;
    return '$prefix$check';
  }

  /// Generates a valid synthetic Oman Civil ID (8 digits).
  static String omanCivilId({int? sequence}) {
    final seq = sequence ?? (_rng.nextInt(90000000) + 10000000);
    return seq.toString().padLeft(8, '0');
  }

  /// Generates a valid synthetic ISO 13616 IBAN with verified Mod 97-10 check digits.
  static String iban(GccCountry country, {String? bankCode, int? seed}) {
    final banks = BankDirectory.banksFor(country);
    final bank = (bankCode != null && bankCode.isNotEmpty)
        ? bankCode
        : (banks.isNotEmpty ? banks.first.bankCode : '80');

    final rng = seed != null ? Random(seed) : _rng;

    final String account;
    switch (country) {
      case GccCountry.saudiArabia:
        // 18-digit account
        account = '${rng.nextInt(90000000) + 10000000}${rng.nextInt(900000000) + 100000000}1';
        break;
      case GccCountry.uae:
        // 16-digit account
        account = '${rng.nextInt(90000000) + 10000000}${rng.nextInt(90000000) + 10000000}';
        break;
      case GccCountry.kuwait:
        // 22-digit account
        account =
            '${rng.nextInt(90000000) + 10000000}${rng.nextInt(90000000) + 10000000}${rng.nextInt(900000) + 100000}';
        break;
      case GccCountry.qatar:
        // 21-digit account
        account =
            '${rng.nextInt(90000000) + 10000000}${rng.nextInt(90000000) + 10000000}${rng.nextInt(90000) + 10000}';
        break;
      case GccCountry.bahrain:
        // 14-digit account
        account = '${rng.nextInt(90000000) + 10000000}${rng.nextInt(900000) + 100000}';
        break;
      case GccCountry.oman:
        // 16-digit account
        account = '${rng.nextInt(90000000) + 10000000}${rng.nextInt(90000000) + 10000000}';
        break;
    }

    return IbanValidator.generateIban(
      country: country,
      bankCode: bank,
      accountNumber: account,
    );
  }

  /// Generates a valid synthetic 16-digit payment card for a GCC domestic switch.
  static String card(GccDomesticSwitch domesticSwitch, {int? seed}) {
    final rng = seed != null ? Random(seed) : _rng;
    final String bin;

    switch (domesticSwitch) {
      case GccDomesticSwitch.mada:
        bin = DomesticSwitches.madaBins.first; // e.g. 417633
        break;
      case GccDomesticSwitch.jaywan:
        bin = DomesticSwitches.jaywanBins.first; // e.g. 654321
        break;
      case GccDomesticSwitch.knet:
        bin = DomesticSwitches.knetBins.first; // e.g. 589160
        break;
      case GccDomesticSwitch.benefit:
        bin = DomesticSwitches.benefitBins.first; // e.g. 508123
        break;
      case GccDomesticSwitch.himyan:
        bin = DomesticSwitches.himyanBins.first; // e.g. 500109
        break;
      case GccDomesticSwitch.omanNet:
        bin = DomesticSwitches.omanNetBins.first; // e.g. 508170
        break;
      case GccDomesticSwitch.none:
        bin = '400000'; // Standard Visa BIN
        break;
    }

    // 16 digits total: BIN(6) + account(9) + check(1)
    final seq9 = (rng.nextInt(900000000) + 100000000).toString();
    final body15 = '$bin$seq9';
    final check = ChecksumUtils.calculateLuhnCheckDigit(body15);
    return '$body15$check';
  }

  /// Generates a valid synthetic Saudi Commercial Registration (CR - 10 digits).
  static String saudiCr({String cityCode = '1010', int? sequence}) {
    final seq = sequence ?? (_rng.nextInt(900000) + 100000);
    return '$cityCode${seq.toString().padLeft(6, '0')}';
  }

  /// Generates a valid synthetic Saudi 700 Unified Establishment Number.
  static String saudi700({int? sequence}) {
    final seq = sequence ?? (_rng.nextInt(9000000) + 1000000);
    return '700${seq.toString().padLeft(7, '0')}';
  }

  /// Generates a valid synthetic UAE Tax Registration Number (TRN - 15 digits).
  static String uaeTrn({int? sequence}) {
    final seq = sequence ?? (_rng.nextInt(90000000) + 10000000);
    return '100${seq.toString().padLeft(8, '0')}0003';
  }

  /// Generates a valid synthetic ZATCA e-Invoice test model.
  static ZatcaInvoice zatcaInvoice({
    String sellerName = 'شركة الاختبار للحلول التقنية المحدودة',
    String vatRegistrationNumber = '310123456700003',
    String invoiceTotal = '1150.00',
    String vatTotal = '150.00',
    DateTime? timestamp,
  }) {
    return ZatcaInvoice(
      sellerName: sellerName,
      vatRegistrationNumber: vatRegistrationNumber,
      timestamp: timestamp ?? DateTime.now(),
      invoiceTotal: invoiceTotal,
      vatTotal: vatTotal,
    );
  }
}
