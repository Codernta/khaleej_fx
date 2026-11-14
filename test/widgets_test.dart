import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('Hardened UI Widgets', () {
    testWidgets('KhaleejTextField renders with Emirates ID formatter', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhaleejTextField(
              controller: controller,
              inputType: KhaleejInputType.emiratesId,
              label: 'Emirates ID',
              showCountrySelector: true,
              selectedCountry: GccCountry.uae,
            ),
          ),
        ),
      );

      expect(find.text('Emirates ID'), findsOneWidget);
      expect(find.text('🇦🇪'), findsOneWidget);

      // Enter digits
      await tester.enterText(find.byType(TextFormField), '784199012345671');
      await tester.pump();

      // Formatter should format it to 784-1990-1234567-1
      expect(controller.text, '784-1990-1234567-1');
    });

    testWidgets('ZatcaQrWidget displays QR code and toggles diagnostics', (tester) async {
      final invoice = ZatcaInvoice(
        sellerName: 'Al-Farabi Tech',
        vatRegistrationNumber: '300000000000003',
        timestamp: DateTime.parse('2023-10-25T15:30:00Z'),
        invoiceTotal: '115.00',
        vatTotal: '15.00',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ZatcaQrWidget(invoice: invoice),
            ),
          ),
        ),
      );

      expect(find.text('ZATCA Phase 1 Valid'), findsOneWidget);
      expect(find.text('Inspect ZATCA Tags'), findsOneWidget);

      // Tap inspect button
      await tester.tap(find.text('Inspect ZATCA Tags'));
      await tester.pumpAndSettle();

      expect(find.text('Al-Farabi Tech'), findsOneWidget);
      expect(find.text('300000000000003'), findsOneWidget);
      expect(find.text('115.00 SAR'), findsOneWidget);
    });

    testWidgets('GccVehiclePlateWidget renders Saudi and UAE plates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GccVehiclePlateWidget.saudi(
                  digits: '1234',
                  lettersAr: 'أ ب ج',
                  lettersEn: 'A B J',
                ),
                GccVehiclePlateWidget.uae(
                  digits: '99999',
                  uaeEmirate: 'DUBAI',
                  uaePlateCode: 'R',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('KSA'), findsOneWidget);
      expect(find.text('١٢٣٤'), findsOneWidget);
      expect(find.text('DUBAI'), findsOneWidget);
      expect(find.text('99999'), findsOneWidget);
    });

    testWidgets('KhaleejTextField obscures CVV and sensitive secrets by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KhaleejTextField(
              inputType: KhaleejInputType.cvv,
              label: 'CVV Code',
            ),
          ),
        ),
      );

      final editableText = tester.widget<EditableText>(find.byType(EditableText));
      expect(editableText.obscureText, isTrue);
      // Clipboard interaction is disabled by default for sensitive inputs
      expect(editableText.enableInteractiveSelection, isFalse);
    });

    testWidgets('EmiratesIdInputFormatter normalizes Arabic-Indic numerals', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhaleejTextField(
              controller: controller,
              inputType: KhaleejInputType.emiratesId,
            ),
          ),
        ),
      );

      // Enter digits in Arabic-Indic numerals
      await tester.enterText(find.byType(TextFormField), '٧٨٤١٩٩٠١٢٣٤٥٦٧١');
      await tester.pump();

      expect(controller.text, '784-1990-1234567-1');
    });

    testWidgets('KhaleejTextField renders with B2B input types (Saudi CR, 700, UAE TRN)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                KhaleejTextField(
                  inputType: KhaleejInputType.saudiCr,
                  label: 'Saudi CR',
                ),
                KhaleejTextField(
                  inputType: KhaleejInputType.saudi700,
                  label: 'Unified 700 Number',
                ),
                KhaleejTextField(
                  inputType: KhaleejInputType.uaeTrn,
                  label: 'UAE TRN',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Saudi CR'), findsOneWidget);
      expect(find.text('Unified 700 Number'), findsOneWidget);
      expect(find.text('UAE TRN'), findsOneWidget);
    });
  });
}
