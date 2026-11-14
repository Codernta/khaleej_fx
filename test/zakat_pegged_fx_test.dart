import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('Pegged GCC FX Cross-Rate Engine', () {
    test('converts from USD using central bank fixed parities', () {
      final sar = KhaleejMoney.fromUsd(100, KhaleejCurrency.sar);
      expect(sar.format(), equals('375.00 SAR'));

      final aed = KhaleejMoney.fromUsd(100, KhaleejCurrency.aed);
      expect(aed.format(), equals('367.25 AED'));

      final qar = KhaleejMoney.fromUsd(100, KhaleejCurrency.qar);
      expect(qar.format(), equals('364.00 QAR'));

      final bhd = KhaleejMoney.fromUsd(100, KhaleejCurrency.bhd);
      expect(bhd.format(), equals('37.600 BHD'));

      final omr = KhaleejMoney.fromUsd(100, KhaleejCurrency.omr);
      expect(omr.format(), equals('38.450 OMR'));
    });

    test('converts between GCC currencies with subunit integer accuracy', () {
      // 100 SAR -> AED: 100 / 3.75 * 3.6725 = 97.9333... -> 97.93 AED
      final sar100 = KhaleejMoney.fromMajor(100, KhaleejCurrency.sar);
      final aedConverted = sar100.convertToPegged(KhaleejCurrency.aed);
      expect(aedConverted.format(), equals('97.93 AED'));

      // Inverse: 97.93 AED -> SAR: 97.93 / 3.6725 * 3.75 = 99.996... -> 100.00 SAR
      final sarBack = aedConverted.convertToPegged(KhaleejCurrency.sar);
      expect(sarBack.format(), equals('100.00 SAR'));

      // 1000 SAR -> KWD (3 decimals): 1000 / 3.75 * 0.3075 = 82.000 KWD
      final kwd = sar100.convertToPegged(KhaleejCurrency.kwd);
      expect(kwd.currency.decimals, equals(3));
      expect(kwd.totalSubunits, equals(BigInt.from(8200))); // 8.200 KWD
    });
  });

  group('Zakat Calculation Engine (KhaleejZakat)', () {
    test('calculates 2.5% for Hijri lunar year', () {
      final wealth = KhaleejMoney.fromMajor(100000, KhaleejCurrency.sar);
      final breakdown = KhaleejZakat.calculate(
        wealth: wealth,
        yearType: IslamicCalendarYear.hijri,
      );

      expect(breakdown.isZakatDue, isTrue);
      expect(breakdown.ratePercent, equals(2.5));
      expect(breakdown.zakatDue.format(), equals('2,500.00 SAR'));
      expect(breakdown.netWealthRemaining.format(), equals('97,500.00 SAR'));
    });

    test('calculates 2.5775% for Gregorian solar year (AAOIFI Standard No. 35)', () {
      final wealth = KhaleejMoney.fromMajor(100000, KhaleejCurrency.sar);
      final breakdown = KhaleejZakat.calculate(
        wealth: wealth,
        yearType: IslamicCalendarYear.gregorian,
      );

      expect(breakdown.isZakatDue, isTrue);
      expect(breakdown.ratePercent, equals(2.5775));
      expect(breakdown.zakatDue.format(), equals('2,577.50 SAR'));
      expect(breakdown.netWealthRemaining.format(), equals('97,422.50 SAR'));
    });

    test('respects Nisab threshold and returns zero when wealth is below Nisab', () {
      final nisab = KhaleejMoney.fromMajor(25000, KhaleejCurrency.sar);
      final wealthBelow = KhaleejMoney.fromMajor(20000, KhaleejCurrency.sar);

      final breakdown = KhaleejZakat.calculate(
        wealth: wealthBelow,
        nisabThreshold: nisab,
      );

      expect(breakdown.isZakatDue, isFalse);
      expect(breakdown.zakatDue.totalSubunits, equals(BigInt.zero));
      expect(breakdown.netWealthRemaining, equals(wealthBelow));
    });

    test('calculates Gold and Silver Nisab in GCC currencies', () {
      // 85 grams * 300 SAR/gram = 25,500 SAR
      final goldNisab = KhaleejZakat.calculateGoldNisab(
        currency: KhaleejCurrency.sar,
        goldPricePerGram: 300,
      );
      expect(goldNisab.format(), equals('25,500.00 SAR'));

      // 595 grams * 3.50 SAR/gram = 2,082.50 SAR
      final silverNisab = KhaleejZakat.calculateSilverNisab(
        currency: KhaleejCurrency.sar,
        silverPricePerGram: 3.50,
      );
      expect(silverNisab.format(), equals('2,082.50 SAR'));
    });
  });
}
