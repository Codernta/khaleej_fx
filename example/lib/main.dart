import 'package:flutter/material.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  runApp(const KhaleejFxDemoApp());
}

class KhaleejFxDemoApp extends StatelessWidget {
  const KhaleejFxDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khaleej FX Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006C35), // Saudi / GCC Emerald Green
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GccCountry _selectedCountry = GccCountry.saudiArabia;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_selectedCountry.flagEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'Khaleej FX — ${_selectedCountry.nameEn}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<GccCountry>(
            tooltip: 'Select Country',
            icon: const Icon(Icons.public),
            onSelected: (country) {
              setState(() => _selectedCountry = country);
            },
            itemBuilder: (context) {
              return GccCountry.values.map((c) {
                return PopupMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Text(c.flagEmoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text('${c.nameEn} (${c.iso2})'),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Money & Tafqeet'),
            Tab(icon: Icon(Icons.badge), text: 'National IDs'),
            Tab(icon: Icon(Icons.account_balance), text: 'IBAN & Banks'),
            Tab(icon: Icon(Icons.credit_card), text: 'Cards & Switches'),
            Tab(icon: Icon(Icons.qr_code_2), text: 'VAT & ZATCA'),
            Tab(icon: Icon(Icons.security), text: 'Security & Plates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MoneyTab(country: _selectedCountry),
          IdentityTab(country: _selectedCountry),
          IbanTab(country: _selectedCountry),
          CardsTab(country: _selectedCountry),
          VatZatcaTab(country: _selectedCountry),
          SecurityAndPlatesTab(country: _selectedCountry),
        ],
      ),
    );
  }
}

// ==========================================
// 1. Money & Tafqeet Tab
// ==========================================
class MoneyTab extends StatefulWidget {
  const MoneyTab({super.key, required this.country});
  final GccCountry country;

  @override
  State<MoneyTab> createState() => _MoneyTabState();
}

class _MoneyTabState extends State<MoneyTab> {
  final _amountController = TextEditingController(text: '1250.75');
  GrammaticalCase _grammaticalCase = GrammaticalCase.nominative;

  @override
  Widget build(BuildContext context) {
    final currency = KhaleejCurrency.forCountry(widget.country);
    final money = KhaleejMoney.tryParse(_amountController.text, currency) ??
        KhaleejMoney.zero(currency);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fixed-Point Money (${currency.code} - ${currency.decimals} Decimals)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount in ${currency.nameEn}',
                      suffixText: currency.symbolEn,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Formatted Representation:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Standard: ${money.format()}', style: const TextStyle(fontSize: 16)),
                  Text('Arabic Symbol: ${money.format(useArabicSymbol: true)}', style: const TextStyle(fontSize: 16)),
                  Text('Arabic Indic: ${money.format(useArabicNumerals: true, useArabicSymbol: true)}', style: const TextStyle(fontSize: 16)),
                  Text('Internal Subunits: ${money.totalSubunits} (${currency.subunitNameEn})', style: const TextStyle(color: Colors.blueGrey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tafqeet (Number to Words)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SegmentedButton<GrammaticalCase>(
                        segments: const [
                          ButtonSegment(value: GrammaticalCase.nominative, label: Text('مرفوع')),
                          ButtonSegment(value: GrammaticalCase.accusativeOrGenitive, label: Text('مجرور')),
                        ],
                        selected: {_grammaticalCase},
                        onSelectionChanged: (val) {
                          setState(() => _grammaticalCase = val.first);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Arabic (العربية):', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    money.toWordsAr(grammaticalCase: _grammaticalCase),
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006C35)),
                  ),
                  const SizedBox(height: 16),
                  const Text('English:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    money.toWordsEn(),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. National IDs Tab
// ==========================================
class IdentityTab extends StatefulWidget {
  const IdentityTab({super.key, required this.country});
  final GccCountry country;

  @override
  State<IdentityTab> createState() => _IdentityTabState();
}

class _IdentityTabState extends State<IdentityTab> {
  final _idController = TextEditingController();

  @override
  void didUpdateWidget(covariant IdentityTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country != widget.country) {
      _setPreset();
    }
  }

  @override
  void initState() {
    super.initState();
    _setPreset();
  }

  void _setPreset() {
    switch (widget.country) {
      case GccCountry.saudiArabia:
        _idController.text = '1010101010';
      case GccCountry.uae:
        _idController.text = '784-1990-1234567-1';
      case GccCountry.kuwait:
        _idController.text = '290051512343';
      case GccCountry.qatar:
        _idController.text = '29063412345';
      case GccCountry.bahrain:
        _idController.text = '900612345';
      case GccCountry.oman:
        _idController.text = '12345678';
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsed = KhaleejId.parse(_idController.text, country: widget.country);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.country.nameEn} National ID Validator',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'National / Civil ID',
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(
                        parsed.isValid ? Icons.check_circle : Icons.error,
                        color: parsed.isValid ? Colors.green : Colors.red,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: parsed.isValid ? Colors.green.shade50 : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        parsed.isValid ? Icons.verified_user : Icons.warning_rounded,
                        color: parsed.isValid ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        parsed.isValid ? 'Valid Identification' : 'Invalid Identification',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: parsed.isValid ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!parsed.isValid)
                    Text('Error: ${parsed.validationError ?? "Check digit mismatch"}', style: const TextStyle(color: Colors.red)),
                  if (parsed.isValid) ...[
                    Text('Formatted: ${parsed.formatted}'),
                    Text('Country: ${parsed.country.nameEn}'),
                    if (parsed is SaudiId)
                      Text('Classification: ${parsed.idType == SaudiIdType.citizen ? "Saudi Citizen" : "Resident Iqama"}'),
                    if (parsed is EmiratesId)
                      Text('Birth Year: ${parsed.birthYear} | Serial: ${parsed.serialNumber}'),
                    if (parsed is KuwaitCivilId)
                      Text('Birth Date: ${parsed.birthDate?.toIso8601String().substring(0, 10)}'),
                    if (parsed is QatarId)
                      Text('Birth Year: ${parsed.birthYear} | Nationality Code: ${parsed.nationalityCode}'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. Banking & IBAN Tab
// ==========================================
class IbanTab extends StatefulWidget {
  const IbanTab({super.key, required this.country});
  final GccCountry country;

  @override
  State<IbanTab> createState() => _IbanTabState();
}

class _IbanTabState extends State<IbanTab> {
  final _ibanController = TextEditingController(text: 'SA0380000000608010167519');

  @override
  Widget build(BuildContext context) {
    final result = IbanValidator.validate(_ibanController.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GCC ISO 13616 & Mod 97-10 IBAN Validator',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  KhaleejTextField(
                    controller: _ibanController,
                    inputType: KhaleejInputType.iban,
                    label: 'GCC IBAN',
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: result.isValid ? Colors.green.shade50 : Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.isValid ? 'IBAN Verified' : 'Validation Notice',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: result.isValid ? Colors.green.shade900 : Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!result.isValid)
                    Text('Message: ${result.errorMessage}', style: const TextStyle(color: Colors.red)),
                  if (result.isValid) ...[
                    Text('Formatted: ${result.formatted}'),
                    Text('Country: ${result.country?.nameEn} (${result.country?.iso2})'),
                    Text('Check Digits: ${result.checkDigits}'),
                    Text('Bank Code: ${result.bankCode}'),
                    if (result.bankInfo != null) ...[
                      const Divider(),
                      Text('Bank: ${result.bankInfo!.nameEn}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Arabic: ${result.bankInfo!.nameAr}', textDirection: TextDirection.rtl),
                      Text('BIC / SWIFT: ${result.bankInfo!.bic}'),
                    ],
                    Text('Account: ${result.accountNumber}'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. Cards & Switches Tab
// ==========================================
class CardsTab extends StatefulWidget {
  const CardsTab({super.key, required this.country});
  final GccCountry country;

  @override
  State<CardsTab> createState() => _CardsTabState();
}

class _CardsTabState extends State<CardsTab> {
  final _cardController = TextEditingController(text: '4176330000000008');

  @override
  Widget build(BuildContext context) {
    final result = CardValidator.validate(_cardController.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Card & Domestic Switch Detection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  KhaleejTextField(
                    controller: _cardController,
                    inputType: KhaleejInputType.cardNumber,
                    label: 'Card Number (PAN)',
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Scheme: ${result.brand.displayName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Domestic GCC Switch: ${result.domesticSwitch.nameEn} (${result.domesticSwitch.nameAr})'),
                  Text('Luhn Mod 10 Status: ${result.isValidLuhn ? "Passed ✓" : "Failed ✗"}',
                      style: TextStyle(color: result.isValidLuhn ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  const Text('PCI DSS 4.0 Masking:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Standard Mask: ${result.mask(preserveBin: false)}'),
                  Text('Preserve BIN: ${result.mask(preserveBin: true)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. VAT & ZATCA e-Invoicing Tab
// ==========================================
class VatZatcaTab extends StatefulWidget {
  const VatZatcaTab({super.key, required this.country});
  final GccCountry country;

  @override
  State<VatZatcaTab> createState() => _VatZatcaTabState();
}

class _VatZatcaTabState extends State<VatZatcaTab> {
  final _sellerController = TextEditingController(text: 'Khaleej Trading Est.');
  final _vatIdController = TextEditingController(text: '310123456700003');
  final _amountController = TextEditingController(text: '100.00');

  @override
  Widget build(BuildContext context) {
    final currency = KhaleejCurrency.forCountry(widget.country);
    final base = KhaleejMoney.tryParse(_amountController.text, currency) ??
        KhaleejMoney.zero(currency);
    final breakdown = KhaleejVat.calculateExclusive(
      baseAmount: base,
      country: widget.country,
    );

    final invoice = ZatcaInvoice(
      sellerName: _sellerController.text,
      vatRegistrationNumber: _vatIdController.text,
      timestamp: DateTime.now(),
      invoiceTotal: breakdown.totalAmount.format(includeSymbol: false),
      vatTotal: breakdown.vatAmount.format(includeSymbol: false),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GCC VAT Engine (${breakdown.vatRatePercent.toStringAsFixed(1)}% in ${widget.country.nameEn})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _sellerController,
                    decoration: const InputDecoration(labelText: 'Seller Legal Name', border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _vatIdController,
                    decoration: const InputDecoration(labelText: 'VAT Registration Number (15 digits)', border: OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Taxable Base Amount (${currency.symbolEn})', border: const OutlineInputBorder()),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text('VAT Amount: ${breakdown.vatAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Invoice Total: ${breakdown.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006C35))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ZATCA QR Widget with interactive diagnostics
          ZatcaQrWidget(
            invoice: invoice,
            size: 200,
            showDiagnostics: true,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. Security & Plates Tab
// ==========================================
class SecurityAndPlatesTab extends StatelessWidget {
  const SecurityAndPlatesTab({super.key, required this.country});
  final GccCountry country;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Bilingual Vehicle Registration Plates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          // Saudi Plate
          const GccVehiclePlateWidget.saudi(
            digits: '4567',
            lettersAr: 'أ د ر',
            lettersEn: 'A D R',
          ),
          const SizedBox(height: 16),
          // UAE Dubai Plate
          const GccVehiclePlateWidget.uae(
            digits: '12345',
            uaeEmirate: 'DUBAI',
            uaePlateCode: 'B',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enterprise Fintech Security (PDPL Redactor)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Sample sanitized output:'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      KhaleejPiiRedactor.redactText(
                        'Audit log: Citizen 1010101010 transferred to SA0380000000608010167519 with mobile +966501234567.',
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
