import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('GCC VAT Engine (KhaleejVat)', () {
    test('calculates exclusive VAT at 15% for Saudi Arabia', () {
      final base = KhaleejMoney.fromMajor(100.00, KhaleejCurrency.sar);
      final breakdown = KhaleejVat.calculateExclusive(
        baseAmount: base,
        country: GccCountry.saudiArabia,
      );

      expect(breakdown.baseAmount.asDouble, 100.00);
      expect(breakdown.vatAmount.asDouble, 15.00);
      expect(breakdown.totalAmount.asDouble, 115.00);
      expect(breakdown.vatRatePercent, 15.0);
      expect(breakdown.isReverseCharge, isFalse);
    });

    test('calculates exclusive VAT at 5% for UAE', () {
      final base = KhaleejMoney.fromMajor(200.00, KhaleejCurrency.aed);
      final breakdown = KhaleejVat.calculateExclusive(
        baseAmount: base,
        country: GccCountry.uae,
      );

      expect(breakdown.vatAmount.asDouble, 10.00);
      expect(breakdown.totalAmount.asDouble, 210.00);
      expect(breakdown.vatRatePercent, 5.0);
    });

    test('calculates exclusive VAT at 10% for Bahrain', () {
      final base = KhaleejMoney.fromMajor(50.000, KhaleejCurrency.bhd);
      final breakdown = KhaleejVat.calculateExclusive(
        baseAmount: base,
        country: GccCountry.bahrain,
      );

      expect(breakdown.vatAmount.asDouble, 5.000);
      expect(breakdown.totalAmount.asDouble, 55.000);
      expect(breakdown.vatRatePercent, 10.0);
    });

    test('calculates inclusive VAT extracting base and tax from total', () {
      // 115 SAR total at 15% -> base 100 SAR, VAT 15 SAR
      final total = KhaleejMoney.fromMajor(115.00, KhaleejCurrency.sar);
      final breakdown = KhaleejVat.calculateInclusive(
        totalAmount: total,
        country: GccCountry.saudiArabia,
      );

      expect(breakdown.baseAmount.asDouble, 100.00);
      expect(breakdown.vatAmount.asDouble, 15.00);
      expect(breakdown.totalAmount.asDouble, 115.00);
    });

    test('applies Reverse Charge Mechanism on Intra-GCC B2B supplies', () {
      final amount = KhaleejMoney.fromMajor(5000.00, KhaleejCurrency.sar);

      // KSA supplier to UAE business customer with verified VAT ID
      final breakdown = KhaleejVat.calculateCrossBorder(
        amount: amount,
        originCountry: GccCountry.saudiArabia,
        destinationCountry: GccCountry.uae,
        customerVatNumber: '100023456789003',
      );

      expect(breakdown.isReverseCharge, isTrue);
      expect(breakdown.vatRatePercent, 0.0);
      expect(breakdown.vatAmount.asDouble, 0.0);
      expect(breakdown.note, contains('Reverse Charge in United Arab Emirates'));
    });
  });

  group('ZATCA FATOORAH Phase 1 & Phase 2 TLV QR Code', () {
    test('encodes and decodes Phase 1 ZATCA invoice (Tags 1..5)', () {
      final invoice = ZatcaInvoice(
        sellerName: 'Acme Trading Co. Ltd',
        vatRegistrationNumber: '310123456700003', // 15 digits starting and ending with 3
        timestamp: DateTime.parse('2023-10-25T14:30:00Z'),
        invoiceTotal: '115.00',
        vatTotal: '15.00',
      );

      expect(invoice.validate(), isEmpty);

      // Encode to Base64
      final base64Qr = ZatcaQr.encode(invoice);
      expect(base64Qr, isNotEmpty);

      // Decode back
      final decoded = ZatcaQr.decode(base64Qr);
      expect(decoded.sellerName, 'Acme Trading Co. Ltd');
      expect(decoded.vatRegistrationNumber, '310123456700003');
      expect(decoded.timestamp.toIso8601String(), contains('2023-10-25T14:30:00'));
      expect(decoded.invoiceTotal, '115.00');
      expect(decoded.vatTotal, '15.00');
      expect(decoded.isPhase2, isFalse);
    });

    test('encodes and decodes Phase 2 ZATCA invoice with cryptographic tags (6, 7, 8)', () {
      final dummyHash = Uint8List.fromList(List.filled(32, 0xAA));
      final dummyStamp = Uint8List.fromList(List.filled(64, 0xBB));
      final dummyPubKey = Uint8List.fromList(List.filled(64, 0xCC));

      final invoice = ZatcaInvoice(
        sellerName: 'شركة الرياض للتقنية',
        vatRegistrationNumber: '300000000000003',
        timestamp: DateTime.parse('2023-11-01T10:00:00Z'),
        invoiceTotal: '230.00',
        vatTotal: '30.00',
        invoiceHash: dummyHash,
        cryptographicStamp: dummyStamp,
        publicKey: dummyPubKey,
      );

      expect(invoice.isPhase2, isTrue);
      expect(invoice.validate(), isEmpty);

      final qrString = ZatcaQr.encode(invoice);
      final decoded = ZatcaQr.decode(qrString);

      expect(decoded.sellerName, 'شركة الرياض للتقنية');
      expect(decoded.isPhase2, isTrue);
      expect(decoded.invoiceHash, dummyHash);
      expect(decoded.cryptographicStamp, dummyStamp);
      expect(decoded.publicKey, dummyPubKey);
    });

    test('validates regulatory constraints (VAT ID format, amounts)', () {
      final invalidInvoice = ZatcaInvoice(
        sellerName: '',
        vatRegistrationNumber: '12345', // invalid: not 15 digits, doesn't start/end with 3
        timestamp: DateTime.now(),
        invoiceTotal: '50.00',
        vatTotal: '60.00', // invalid: VAT > total
      );

      final errors = invalidInvoice.validate();
      expect(errors.length, 3);
      expect(errors.any((e) => e.contains('Seller name')), isTrue);
      expect(errors.any((e) => e.contains('15 digits')), isTrue);
      expect(errors.any((e) => e.contains('cannot exceed')), isTrue);
    });

    test('tryDecode safely parses valid QR and returns null on corrupted payload', () {
      final invoice = ZatcaInvoice(
        sellerName: 'Safe Corp',
        vatRegistrationNumber: '300000000000003',
        timestamp: DateTime.parse('2023-11-01T10:00:00Z'),
        invoiceTotal: '100.00',
        vatTotal: '15.00',
      );
      final encoded = ZatcaQr.encode(invoice);

      final validResult = ZatcaQr.tryDecode(encoded);
      expect(validResult, isNotNull);
      expect(validResult!.sellerName, 'Safe Corp');

      // Corrupted / malformed input
      expect(ZatcaQr.tryDecode('not_a_valid_base64_tlv_!@#'), isNull);
      expect(ZatcaQr.tryDecode(''), isNull);
    });
  });
}
