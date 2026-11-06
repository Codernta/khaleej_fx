import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('KhaleejCurrency', () {
    test('verifies 2-decimal precision for SAR, AED, QAR', () {
      expect(KhaleejCurrency.sar.decimals, 2);
      expect(KhaleejCurrency.sar.subunitFactor, 100);
      expect(KhaleejCurrency.aed.decimals, 2);
      expect(KhaleejCurrency.aed.subunitFactor, 100);
      expect(KhaleejCurrency.qar.decimals, 2);
      expect(KhaleejCurrency.qar.subunitFactor, 100);
    });

    test('verifies 3-decimal precision for KWD, BHD, OMR', () {
      expect(KhaleejCurrency.kwd.decimals, 3);
      expect(KhaleejCurrency.kwd.subunitFactor, 1000);
      expect(KhaleejCurrency.bhd.decimals, 3);
      expect(KhaleejCurrency.bhd.subunitFactor, 1000);
      expect(KhaleejCurrency.omr.decimals, 3);
      expect(KhaleejCurrency.omr.subunitFactor, 1000);
    });

    test('finds currency by code or symbol', () {
      expect(KhaleejCurrency.fromCode('SAR'), KhaleejCurrency.sar);
      expect(KhaleejCurrency.fromCode('ر.س'), KhaleejCurrency.sar);
      expect(KhaleejCurrency.fromCode('KWD'), KhaleejCurrency.kwd);
      expect(KhaleejCurrency.fromCode('د.ك'), KhaleejCurrency.kwd);
      expect(KhaleejCurrency.fromCode('AED'), KhaleejCurrency.aed);
      expect(KhaleejCurrency.fromCode('OMR'), KhaleejCurrency.omr);
    });
  });

  group('KhaleejMoney - Fixed Point Subunit Arithmetic', () {
    test('creates 2-decimal SAR money accurately from major units', () {
      final money = KhaleejMoney.fromMajor(1250.75, KhaleejCurrency.sar);
      expect(money.totalSubunits, BigInt.from(125075));
      expect(money.majorUnits, BigInt.from(1250));
      expect(money.subunitsRemainder, BigInt.from(75));
      expect(money.asDouble, 1250.75);
    });

    test('creates 3-decimal KWD money accurately from major units', () {
      final money = KhaleejMoney.fromMajor(45.125, KhaleejCurrency.kwd);
      expect(money.totalSubunits, BigInt.from(45125));
      expect(money.majorUnits, BigInt.from(45));
      expect(money.subunitsRemainder, BigInt.from(125));
      expect(money.asDouble, 45.125);
    });

    test('parses string representations with commas and decimals', () {
      final m1 = KhaleejMoney.parse('1,250.50 SAR', KhaleejCurrency.sar);
      expect(m1.totalSubunits, BigInt.from(125050));

      final m2 = KhaleejMoney.parse('100.350', KhaleejCurrency.bhd);
      expect(m2.totalSubunits, BigInt.from(100350));

      final m3 = KhaleejMoney.parse('١٬٥٠٠٫٢٥', KhaleejCurrency.qar);
      expect(m3.totalSubunits, BigInt.from(150025));
    });

    test('addition and subtraction maintain exact integer precision', () {
      final a = KhaleejMoney.fromMajor(100.15, KhaleejCurrency.sar);
      final b = KhaleejMoney.fromMajor(200.85, KhaleejCurrency.sar);
      final sum = a + b;
      expect(sum.totalSubunits, BigInt.from(30100));
      expect(sum.asDouble, 301.00);

      final diff = b - a;
      expect(diff.totalSubunits, BigInt.from(10070));
      expect(diff.asDouble, 100.70);
    });

    test('multiplication and division round cleanly to sub-units', () {
      final price = KhaleejMoney.fromMajor(10.55, KhaleejCurrency.sar);
      final total = price * 3;
      expect(total.asDouble, 31.65);

      final half = price / 2;
      expect(half.totalSubunits, BigInt.from(528)); // 1055 / 2 = 527.5 -> 528
    });

    test('percentage calculation (e.g. 15% VAT)', () {
      final base = KhaleejMoney.fromMajor(100.00, KhaleejCurrency.sar);
      final vat = base.percentage(15);
      expect(vat.totalSubunits, BigInt.from(1500));
      expect(vat.asDouble, 15.00);
    });

    test('comparison operators work correctly', () {
      final m1 = KhaleejMoney.fromMajor(100, KhaleejCurrency.sar);
      final m2 = KhaleejMoney.fromMajor(200, KhaleejCurrency.sar);
      final m3 = KhaleejMoney.fromMajor(100, KhaleejCurrency.sar);

      expect(m1 < m2, isTrue);
      expect(m1 <= m3, isTrue);
      expect(m2 > m1, isTrue);
      expect(m1 == m3, isTrue);
      expect(m1 == m2, isFalse);
    });

    test('throws ArgumentError on currency mismatch', () {
      final sar = KhaleejMoney.fromMajor(100, KhaleejCurrency.sar);
      final aed = KhaleejMoney.fromMajor(100, KhaleejCurrency.aed);
      expect(() => sar + aed, throwsArgumentError);
      expect(() => sar.compareTo(aed), throwsArgumentError);
    });

    test('formats with standard 3-digit comma grouping', () {
      final money = KhaleejMoney.fromMajor(1000000.50, KhaleejCurrency.sar);
      expect(money.format(includeSymbol: false), '1,000,000.50');
      expect(money.format(includeSymbol: true), '1,000,000.50 SAR');
      expect(
        money.format(useArabicSymbol: true, symbolAtEnd: true),
        '1,000,000.50 ر.س',
      );
    });

    test('formats 3-decimal currencies with 3 decimal places', () {
      final kwd = KhaleejMoney.fromMajor(1234.5, KhaleejCurrency.kwd);
      expect(kwd.format(includeSymbol: false), '1,234.500');
    });

    test('formats in Arabic-Indic numerals', () {
      final money = KhaleejMoney.fromMajor(1250.75, KhaleejCurrency.sar);
      expect(
        money.format(useArabicNumerals: true, includeSymbol: false),
        '١٬٢٥٠٫٧٥',
      );
    });
  });
}
