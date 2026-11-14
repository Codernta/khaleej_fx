import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('Synthetic Mock Data Generator (KhaleejMock)', () {
    test('generates valid synthetic Saudi Citizen IDs and Iqamas', () {
      for (var i = 0; i < 5; i++) {
        final citizenId = KhaleejMock.saudiId(isCitizen: true);
        final parsedCitizen = SaudiId.parse(citizenId);
        expect(parsedCitizen.isValid, isTrue, reason: 'Failed for $citizenId');
        expect(parsedCitizen.idType, equals(SaudiIdType.citizen));

        final iqama = KhaleejMock.saudiId(isCitizen: false);
        final parsedIqama = SaudiId.parse(iqama);
        expect(parsedIqama.isValid, isTrue, reason: 'Failed for $iqama');
        expect(parsedIqama.idType, equals(SaudiIdType.residentIqama));
      }
    });

    test('generates valid synthetic UAE Emirates IDs', () {
      for (var i = 0; i < 5; i++) {
        final eid = KhaleejMock.emiratesId(birthYear: 1990 + i);
        final parsed = EmiratesId.parse(eid);
        expect(parsed.isValid, isTrue, reason: 'Failed for $eid');
        expect(parsed.birthYear, equals(1990 + i));
      }
    });

    test('generates valid synthetic Kuwait Civil IDs', () {
      for (var i = 0; i < 5; i++) {
        final kwId = KhaleejMock.kuwaitCivilId(birthYear: 1995);
        final parsed = KuwaitCivilId.parse(kwId);
        expect(parsed.isValid, isTrue, reason: 'Failed for $kwId');
      }
    });

    test('generates valid synthetic Qatar IDs, Bahrain CPRs, and Oman Civil IDs', () {
      final qid = KhaleejMock.qatarId();
      expect(QatarId.parse(qid).isValid, isTrue);

      final cpr = KhaleejMock.bahrainCpr();
      expect(BahrainCpr.parse(cpr).isValid, isTrue);

      final omanId = KhaleejMock.omanCivilId();
      expect(OmanCivilId.parse(omanId).isValid, isTrue);
    });

    test('generates valid synthetic ISO 13616 IBANs for all 6 GCC countries', () {
      for (final country in GccCountry.values) {
        final mockIban = KhaleejMock.iban(country);
        final result = IbanValidator.validate(mockIban);
        expect(
          result.isValid,
          isTrue,
          reason: 'Failed for country ${country.iso2}: $mockIban - ${result.errorMessage}',
        );
        expect(result.country, equals(country));
      }
    });

    test('generates valid synthetic cards for all GCC domestic switches', () {
      final switches = [
        GccDomesticSwitch.mada,
        GccDomesticSwitch.jaywan,
        GccDomesticSwitch.knet,
        GccDomesticSwitch.benefit,
        GccDomesticSwitch.himyan,
        GccDomesticSwitch.omanNet,
      ];

      for (final sw in switches) {
        final card = KhaleejMock.card(sw);
        final result = CardValidator.validate(card);
        expect(result.isValidLuhn, isTrue, reason: 'Luhn failed for switch $sw: $card');
        expect(result.domesticSwitch, equals(sw), reason: 'Switch mismatch for card: $card');
      }
    });

    test('generates valid synthetic B2B entity IDs (Saudi CR, 700, UAE TRN)', () {
      final cr = KhaleejMock.saudiCr(cityCode: '1010');
      expect(SaudiCr.parse(cr).isValid, isTrue);

      final s700 = KhaleejMock.saudi700();
      expect(Saudi700Number.parse(s700).isValid, isTrue);

      final trn = KhaleejMock.uaeTrn();
      expect(UaeTrn.parse(trn).isValid, isTrue);
    });

    test('generates valid synthetic ZATCA e-Invoices and encodes to QR', () {
      final invoice = KhaleejMock.zatcaInvoice();
      final qrString = ZatcaQr.encode(invoice);
      expect(qrString, isNotEmpty);

      final decoded = ZatcaQr.decode(qrString);
      expect(decoded.validate(), isEmpty);
      expect(decoded.sellerName, equals(invoice.sellerName));
    });
  });
}
