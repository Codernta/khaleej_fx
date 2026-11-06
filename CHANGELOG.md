# Changelog

All notable changes to the `khaleej_fx` package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-06

### Initial Production Release

Enterprise GCC Fintech, Banking, Identity, VAT, and Utilities library for Flutter and Dart.
Zero external dependencies — pure Dart & Flutter standard library.

#### Features

- **Money & Currencies (`KhaleejMoney`, `KhaleejCurrency`)**:
  - Full support for all 6 GCC currencies: SAR, AED, QAR (2 decimals / $100$ subunits) and KWD, BHD, OMR (3 decimals / $1000$ subunits).
  - Exact integer subunit arithmetic (`+`, `-`, `*`, `/`, `percentage`, comparisons) using `BigInt` to prevent floating-point drift.
  - Parsing of formatted currency strings with commas, decimals, and Arabic-Indic numerals (`٠١٢٣٤٥٦٧٨٩`).
  - Formatting with standard 3-digit comma grouping (`1,000,000.00`) and localized Arabic numeral support.
  - **Tafqeet (`tafqeet.dart`)**:
    - Arabic legal number-to-words engine supporting grammatical case distinctions (Nominative / *Marfoo*, Accusative & Genitive / *Mansoob* & *Majroor*).
    - Grammatical duals (مثنى: ريالان / ريالين), plurals (جمع: ريالات / فلس), and gender agreement for units 3–10.
    - English number-to-words conversion for legal check and invoice writing.

- **National IDs (`KhaleejId`)**:
  - Auto-detection and country-specific ID validation for all 6 GCC states.
  - **Saudi Arabia (KSA)**: 10-digit Luhn Modulo 10 check, distinguishing Citizens (`1...`) and Resident Iqama holders (`2...`).
  - **United Arab Emirates (UAE)**: 15-digit Emirates ID (`784-YYYY-XXXXXXX-C`), birth year extraction and validation, Luhn check digit verification.
  - **Kuwait (KWT)**: 12-digit Civil ID validated using PACI Modulo 11 weighted algorithm.
  - **Qatar (QAT)**: 11-digit QID with century code, birth year, ISO-3166 nationality code, and Modulo 11 checksum.
  - **Bahrain (BHR)**: 9-digit CPR with birth year/month and Modulo 11 weighted check.
  - **Oman (OMN)**: 8-digit Civil Number with automatic 7-digit zero-padding normalization.

- **GCC Banking & IBAN (`IbanValidator`)**:
  - Full ISO 13616 and ISO 7064 Mod 97-10 validation, generation, and formatting.
  - Exact country lengths: SA (24), AE (23), KW (30), QA (29), BH (22), OM (23).
  - Comprehensive GCC bank directory mapping bank identifiers to BIC / SWIFT codes and localized names (Al Rajhi, SNB, FAB, ENBD, NBK, QNB, NBB, Bank Muscat, etc.).
  - Constant-time IBAN / account confirmation (`confirmIban`).

- **Cards & Domestic Payment Switches**:
  - Modulo 10 Luhn check with BIN-level detection for GCC domestic debit switches:
    - **Mada** (Saudi Arabia)
    - **Jaywan** / Mercury (United Arab Emirates)
    - **KNET** (Kuwait)
    - **Benefit** (Bahrain)
    - **NAPS / Himyan** (Qatar)
    - **OmanNet** (Oman)
    - International networks: Visa, Mastercard, American Express.
  - PCI DSS 4.0 compliant PAN masking (`preserveBin` options: `XXXX-XXXX-XXXX-1234` or `4176 33XX XXXX 1234`).

- **GCC VAT & ZATCA e-Invoicing (`KhaleejVat`, `ZatcaQr`)**:
  - Standard and zero VAT rates across all GCC jurisdictions (KSA 15%, UAE 5%, BH 10%, OM 5%, KW 0%, QA 0%).
  - Inclusive and exclusive VAT breakdown with exact subunit rounding.
  - Intra-GCC B2B Reverse Charge Mechanism (RCM) support.
  - Zero-dependency Base64 Tag-Length-Value (TLV) QR code encoder, decoder, and validator:
    - Phase 1: Tags 1–5 (Seller Name, VAT Number, Timestamp, Invoice Total, VAT Total).
    - Phase 2: Tags 6–8 (Invoice Hash SHA-256, ECDSA Cryptographic Stamp, ECDSA Public Key).

- **Enterprise Fintech Security (`KhaleejSecurity`)**:
  - `TimingSafe`: Constant-time string and byte equality comparisons resisting timing side-channel attacks.
  - `SensitiveValue<T>`: Secret container masking values from `toString()` and `toJson()` (`[PROTECTED_VALUE]`) with explicit `.zeroize()` memory wiper.
  - Pure-Dart RFC 6234 SHA-256 and RFC 2104 HMAC-SHA256 implementations verified against NIST CAVP and RFC 4231 vectors.
  - Payment Webhook Signature Verifiers: Tap Payments, Moyasar, Geidea, Checkout.com, PayTabs, Network International.
  - `KhaleejPiiRedactor`: Compliant with Saudi & UAE PDPL, redacting National IDs, Iqamas, Emirates IDs, Civil IDs, IBANs, Card PANs, CVVs, and Phone Numbers in strings and recursive JSON maps.

- **Arabic Script & Address Utilities**:
  - `ArabicNormalizer`: Tashkeel stripping, Tatweel (Kashida) removal, Alef/Yaa/Taa Marbuta normalization.
  - `NumeralConverter`: Lossless bidirectional conversion between Arabic-Indic (`٠-٩`) and Western Arabic (`0-9`) digits.
  - `AddressValidator`: Validation for Saudi SPL Short Address (`RRRD2929`), UAE Makani 10-digit code, and Qatar Blue Plate.

- **Hardened UI Widgets**:
  - `KhaleejTextField`: Form field hardened with anti-keylogging flags, anti-clipboard guards, GCC country selector dropdown, and automatic input formatters.
  - `ZatcaQrWidget`: Self-contained vector QR code renderer with built-in compliance inspector.
  - `GccVehiclePlateWidget`: Bilingual Saudi (Latin/Arabic characters) and UAE private vehicle plates.
