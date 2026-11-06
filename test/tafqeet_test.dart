import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('Tafqeet - Arabic Number to Words', () {
    test('converts zero and simple units', () {
      expect(Tafqeet.numberToWordsAr(BigInt.zero), 'صفر');
      expect(Tafqeet.numberToWordsAr(BigInt.one), 'واحد');
      expect(Tafqeet.numberToWordsAr(BigInt.from(2)), 'اثنان');
      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(2),
          grammaticalCase: GrammaticalCase.accusativeOrGenitive,
        ),
        'اثنين',
      );
    });

    test('respects gender agreement for units 3-10', () {
      // Masculine counted noun (e.g. Riyal): numerals take feminine ending
      expect(Tafqeet.numberToWordsAr(BigInt.from(5), isFeminine: false), 'خمسة');
      // Feminine counted noun (e.g. Halala): numerals take masculine ending
      expect(Tafqeet.numberToWordsAr(BigInt.from(5), isFeminine: true), 'خمس');
    });

    test('handles dual forms for hundreds and thousands in Marfoo and Majroor', () {
      // 200
      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(200),
          grammaticalCase: GrammaticalCase.nominative,
        ),
        'مئتان',
      );
      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(200),
          grammaticalCase: GrammaticalCase.accusativeOrGenitive,
        ),
        'مئتين',
      );

      // 2,000
      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(2000),
          grammaticalCase: GrammaticalCase.nominative,
        ),
        'ألفان',
      );
      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(2000),
          grammaticalCase: GrammaticalCase.accusativeOrGenitive,
        ),
        'ألفين',
      );
    });

    test('converts tens in Marfoo (عشرون) and Majroor (عشرين)', () {
      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(20),
          grammaticalCase: GrammaticalCase.nominative,
        ),
        'عشرون',
      );
      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(20),
          grammaticalCase: GrammaticalCase.accusativeOrGenitive,
        ),
        'عشرين',
      );

      expect(
        Tafqeet.numberToWordsAr(
          BigInt.from(95),
          isFeminine: false,
          grammaticalCase: GrammaticalCase.nominative,
        ),
        'خمسة وتسعون',
      );
    });

    test('converts complex numbers (thousands, hundreds, tens)', () {
      final words = Tafqeet.numberToWordsAr(
        BigInt.from(1250),
        isFeminine: false,
        grammaticalCase: GrammaticalCase.nominative,
      );
      expect(words, 'ألف ومئتان وخمسون');
    });

    test('converts currency with subunits to formal Arabic legal sentence', () {
      final money = KhaleejMoney.fromMajor(1250.75, KhaleejCurrency.sar);
      final words = money.toWordsAr(
        grammaticalCase: GrammaticalCase.nominative,
      );
      // 'ألف ومئتان وخمسون ريالاً وخمس وسبعون هللة فقط لا غير'
      expect(words.contains('ألف ومئتان وخمسون'), isTrue);
      expect(words.contains('سبعون هللة'), isTrue);
      expect(words.endsWith('فقط لا غير'), isTrue);
    });

    test('handles 1 and 2 currency amounts appropriately', () {
      final oneRiyal = KhaleejMoney.fromMajor(1, KhaleejCurrency.sar);
      expect(oneRiyal.toWordsAr(includeLegalSuffix: false), 'ريال سعودي');

      final twoRiyalsMarfoo = KhaleejMoney.fromMajor(2, KhaleejCurrency.sar);
      expect(
        twoRiyalsMarfoo.toWordsAr(
          grammaticalCase: GrammaticalCase.nominative,
          includeLegalSuffix: false,
        ),
        'ريالان سعوديان',
      );

      final twoRiyalsMajroor = KhaleejMoney.fromMajor(2, KhaleejCurrency.sar);
      expect(
        twoRiyalsMajroor.toWordsAr(
          grammaticalCase: GrammaticalCase.accusativeOrGenitive,
          includeLegalSuffix: false,
        ),
        'ريالين سعوديين',
      );
    });
  });

  group('Tafqeet - English Number to Words', () {
    test('converts numbers to English words', () {
      expect(Tafqeet.numberToWordsEn(BigInt.zero), 'Zero');
      expect(Tafqeet.numberToWordsEn(BigInt.from(25)), 'Twenty-Five');
      expect(Tafqeet.numberToWordsEn(BigInt.from(105)), 'One Hundred Five');
      expect(
        Tafqeet.numberToWordsEn(BigInt.from(1250)),
        'One Thousand Two Hundred Fifty',
      );
    });

    test('converts money to English legal phrase', () {
      final money = KhaleejMoney.fromMajor(1250.75, KhaleejCurrency.sar);
      expect(
        money.toWordsEn(),
        'One Thousand Two Hundred Fifty Saudi Riyals and Seventy-Five Halalas only',
      );
    });
  });
}
