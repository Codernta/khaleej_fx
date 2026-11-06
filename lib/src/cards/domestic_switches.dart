import 'card_brand.dart';

/// Detection and mapping engine for GCC domestic switches and card schemes.
class DomesticSwitches {
  const DomesticSwitches._();

  /// Saudi Mada known Bank Identification Numbers (BINs) - 6-digit prefixes.
  static const Set<String> madaBins = {
    // SAMA / Mada Bank prefixes
    '417633', '440647', '440795', '446404', '457865', '468540', '468541',
    '468542', '468543', '400861', '401757', '409201', '458456', '484783',
    '432328', '428671', '428672', '428673', '422817', '422818', '422819',
    '588845', '588846', '588847', '588848', '588849', '588850', '588851',
    '636120', '968201', '968202', '968203', '968204', '968205', '968206',
    '968207', '968208', '968209', '968211', '504300', '521076', '524130',
    '524514', '529415', '529741', '535825', '543085', '543357', '455708',
  };

  /// UAE Jaywan / Mercury domestic payment network BINs.
  static const Set<String> jaywanBins = {
    '654321', '506968', '508125', '627191', '650001', '650002', '650003',
  };

  /// Kuwait KNET domestic payment switch BINs.
  static const Set<String> knetBins = {
    '589160', '508160', '401662', '415254', '450778', '485425', '521175',
  };

  /// Bahrain Benefit domestic debit card BINs.
  static const Set<String> benefitBins = {
    '508123', '410100', '458838', '474415', '589004', '452243',
  };

  /// Qatar Himyan / NAPS domestic debit card BINs.
  static const Set<String> himyanBins = {
    '500109', '589005', '400371', '400372', '458839',
  };

  /// Oman OmanNet domestic debit switch BINs.
  static const Set<String> omanNetBins = {
    '508170', '508171', '410050', '421032', '477121', '428282',
  };

  /// Identifies if a card PAN belongs to a GCC domestic switch.
  static GccDomesticSwitch detectDomesticSwitch(String pan) {
    final clean = pan.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 6) return GccDomesticSwitch.none;

    final bin6 = clean.substring(0, 6);

    if (madaBins.contains(bin6)) {
      return GccDomesticSwitch.mada;
    }

    if (jaywanBins.contains(bin6) ||
        (clean.startsWith('65') && clean.length >= 6)) {
      return GccDomesticSwitch.jaywan;
    }

    if (knetBins.contains(bin6)) {
      return GccDomesticSwitch.knet;
    }

    if (benefitBins.contains(bin6)) {
      return GccDomesticSwitch.benefit;
    }

    if (himyanBins.contains(bin6)) {
      return GccDomesticSwitch.himyan;
    }

    if (omanNetBins.contains(bin6)) {
      return GccDomesticSwitch.omanNet;
    }

    return GccDomesticSwitch.none;
  }

  /// Detects the card brand, giving priority to domestic switches or global schemes.
  static CardBrand detectBrand(String pan) {
    final clean = pan.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return CardBrand.unknown;

    final domestic = detectDomesticSwitch(clean);
    switch (domestic) {
      case GccDomesticSwitch.mada:
        return CardBrand.mada;
      case GccDomesticSwitch.jaywan:
        return CardBrand.jaywan;
      case GccDomesticSwitch.knet:
        return CardBrand.knet;
      case GccDomesticSwitch.benefit:
        return CardBrand.benefit;
      case GccDomesticSwitch.himyan:
        return CardBrand.himyan;
      case GccDomesticSwitch.omanNet:
        return CardBrand.omanNet;
      case GccDomesticSwitch.none:
        break;
    }

    // Global Schemes
    if (clean.startsWith('4')) {
      return CardBrand.visa;
    }

    // Mastercard: 51..55 or 2221..2720
    if (clean.length >= 2) {
      final prefix2 = int.tryParse(clean.substring(0, 2)) ?? 0;
      if (prefix2 >= 51 && prefix2 <= 55) {
        return CardBrand.mastercard;
      }
    }
    if (clean.length >= 4) {
      final prefix4 = int.tryParse(clean.substring(0, 4)) ?? 0;
      if (prefix4 >= 2221 && prefix4 <= 2720) {
        return CardBrand.mastercard;
      }
    }

    // American Express: 34 or 37
    if (clean.startsWith('34') || clean.startsWith('37')) {
      return CardBrand.americanExpress;
    }

    // Discover: 6011, 65, 644..649
    if (clean.startsWith('6011') || clean.startsWith('65')) {
      return CardBrand.discover;
    }

    return CardBrand.unknown;
  }
}
