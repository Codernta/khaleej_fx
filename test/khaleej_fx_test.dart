import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  test('KhaleejFX package exports and initializes cleanly', () {
    expect(GccCountry.values.length, 6);
    expect(KhaleejCurrency.values.length, 6);

    final money = KhaleejMoney.fromMajor(100, KhaleejCurrency.sar);
    expect(money.format(), '100.00 SAR');
  });
}
