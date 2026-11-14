# Changelog

All notable changes to the `khaleej_fx` package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.3] - 2026-11-14

### Added - B2B KYB Identity, Telco Intelligence, SAMA PIN Hardening, Pegged FX & QA Generator

- **B2B / KYB Business Entity Verification**:
  - `SaudiCr`: Saudi Commercial Registration (السجل التجاري) validator identifying regional chamber/city branch codes (Riyadh `1010`, Jeddah `4030`, Dammam `2050`, etc.) with formatting and privacy masking.
  - `Saudi700Number`: Unified National Establishment Number (الرقم الموحد 700) validator for KSA corporate entities, institutions, and government authorities.
  - `UaeTrn`: UAE Federal Tax Authority (FTA) Tax Registration Number (15 digits starting with `100` and ending in `0003`) for Corporate Tax and VAT.
  - `KhaleejBusinessId`: Unified parser and auto-detection engine for GCC commercial and tax identifiers.
  - `KhaleejTextField`: Added support for `KhaleejInputType.saudiCr`, `KhaleejInputType.saudi700`, and `KhaleejInputType.uaeTrn`.

- **GCC Telecom Carrier & Phone Intelligence**:
  - `KhaleejPhone`: High-precision mobile phone number parser, normalizer, and validator across all 6 GCC member states.
  - `GccCarrier`: Detailed carrier detection for STC, Mobily, Zain, Virgin Mobile, Salam, Red Bull Mobile (KSA), e& / Etisalat, du, Virgin (UAE), Zain, Ooredoo, stc (Kuwait & Bahrain), Ooredoo, Vodafone (Qatar), Omantel, Ooredoo, Vodafone (Oman).
  - Normalizes to E.164 (`+966501234567`), national display (`050 123 4567`), and privacy-compliant PDPL masking (`+966 50 *** 4567`).

- **SAMA Cybersecurity Framework PIN Validator**:
  - `SamaPinValidator`: Mandatory constraint validation for mobile banking MPINs and ATM PINs.
  - Rejects sequential numbers (`1234`, `4321`), repeating identical digits (`1111`, `0000`), alternating repeating patterns (`1212`, `1010`), and personal PII matches (birth year, birth date, National ID suffix, mobile phone suffix).
  - Bilingual regulatory error reporting in Arabic and English.

- **Pegged FX Cross-Rate Engine & Zakat Calculator**:
  - `KhaleejMoney.fromUsd`: Direct conversion from US Dollars to any GCC currency using official central bank parities.
  - `KhaleejMoney.convertToPegged`: Subunit integer-precision cross-rate conversions between SAR (3.7500), AED (3.6725), QAR (3.6400), BHD (0.3760), OMR (0.3845), and KWD (0.3075) without floating-point inaccuracies.
  - `KhaleejZakat`: Statutory Zakat calculation supporting Hijri lunar years (2.5%) and Gregorian solar years (2.5775%) per AAOIFI Shari'ah Standard No. 35 and ZATCA regulations.
  - `calculateGoldNisab` (85g) and `calculateSilverNisab` (595g) threshold evaluators in local GCC currencies.

- **Synthetic Mock Data Generator (`KhaleejMock`)**:
  - `KhaleejMock`: Production-grade mock data generator for QA, CI, and test fixtures without exposing real customer PII.
  - Generates algorithmically verified Saudi IDs (Luhn), Emirates IDs (Luhn), Kuwait Civil IDs (PACI Mod 11), Qatar IDs, Bahrain CPRs, Oman Civil IDs, ISO 13616 IBANs (Mod 97-10), and GCC domestic switch cards (Mada, Jaywan, KNET, Benefit, Himyan, OmanNet).

---

## [1.0.2] - 2026-11-08

### Documentation & Asset Fix
- **`README.md`**:
  - Fixed banner poster image rendering on pub.dev and external renderers by switching from relative local asset path (`doc/images/khaleej_fx_poster.jpg`) to absolute GitHub raw asset URL (`https://raw.githubusercontent.com/Codernta/khaleej_fx/main/doc/images/khaleej_fx_poster.jpg`).
  - Updated pub version badge to `v1.0.2` pointing to `https://pub.dev/packages/khaleej_fx`.

---

## [1.0.1] - 2026-11-08

### Security Hardening & Enterprise Enhancements

Comprehensive security audit, side-channel timing attack mitigations, enhanced PII redaction (Saudi PDPL & UAE Data Protection Law compliance), expanded regional fintech gateway verifiers, secure-by-default UI controls, and memory protection.

#### Security & Cryptography
- **`TimingSafe`**:
  - Hardened `equalString` and `equalBytes` with uniform instruction loops over maximum length to prevent execution-time side channels.
  - Added `equalDigest` and `equalBytesDigest`: SHA-256 pre-hashing ensures comparisons occur on fixed 32-byte digests, eliminating length-leakage vulnerabilities for variable-length secrets (passwords, tokens, OTPs).
  - Added `equalBytesStrict` for fixed-length cryptographic buffers.
- **`SensitiveValue`**:
  - Added `SensitiveValue.fromString` and `SensitiveValue.fromBytes` factory constructors.
  - Fixed `operator ==` to utilize `TimingSafe.equalBytes` for byte arrays and `TimingSafe.equalString` for strings instead of reference or non-constant-time equality.
  - Added `constantTimeEquals` method for explicit timing-safe secret comparisons.
  - Hardened `zeroize()` memory scrubbing across byte buffers and string containers.
- **`WebhookVerifier`**:
  - Mandatory key validation: strictly rejects empty or whitespace secret keys and signatures upfront.
  - Added signature prefix normalization (supports `sha256=`, `sha256:`, and `hex=`).
  - Added `verifyWithTimestamp` with configurable tolerance window (default 5 minutes) to mitigate replay attacks.
  - Added regional GCC payment gateway verifiers:
    - **HyperPay** (`verifyHyperPay` with `X-Signature` HMAC-SHA256)
    - **Tamara** (`verifyTamara` supporting both HMAC and Bearer token modes)
    - **Tabby** (`verifyTabby` BNPL signature verification)
    - **Stripe** (`verifyStripe` with `t=...,v1=...` parsing and timestamp replay mitigation)

#### Privacy & PII Compliance (Saudi PDPL & UAE Data Protection)
- **`KhaleejPiiRedactor`**:
  - Added support for spaced and hyphen-grouped GCC IBANs (`SA03 8000 0000 6080 1016 7519`), which previously bypassed unformatted patterns.
  - Added email address redaction (`[REDACTED_EMAIL]`).
  - Added Eastern Arabic-Indic numerals (`٠-٩`) support across all national ID patterns (Saudi Citizen ID, Iqama, Emirates ID, Kuwait Civil ID, Qatar ID, Bahrain CPR) and GCC mobile numbers.
  - Added Oman Civil ID context redaction (`[REDACTED_OMAN_CIVIL_ID]`).
  - Expanded `_sensitiveKeys` dictionary covering API keys, access tokens, auth tokens, client secrets, session IDs, private keys, cookies, and JWTs.

#### Masking & Privacy Controls
- **`KhaleejId`**: Added `mask()` method across the base class and all 6 national ID implementations (`SaudiId`, `EmiratesId`, `KuwaitCivilId`, `QatarId`, `BahrainCpr`, `OmanCivilId`).
- **`IbanValidator` & `GccIban`**: Added `mask()` (`SA** **** **** **** **** 7519`) for PCI DSS and PDPL compliant IBAN display.
- **`CardMasker`**: Fixed short token leakage (inputs <= 4 digits now safely masked as `maskChar * len`); added `maskCvv` for CVV/CVC masking.

#### UI Hardening & Resilience
- **`KhaleejTextField`**:
  - Secure-by-default: automatically obscures text and disables clipboard copying for `cvv` and `sensitiveSecret` inputs unless explicitly overridden.
  - Input formatters (`EmiratesIdInputFormatter`, `SaudiIdInputFormatter`, `GccIbanInputFormatter`, `CardNumberInputFormatter`, `KuwaitCivilIdInputFormatter`) now automatically normalize Arabic-Indic digits to Western digits upon typing/pasting.
- **`ZatcaQr` & `TlvCodec`**:
  - Added `ZatcaQr.tryDecode` returning `null` instead of throwing unhandled exceptions on corrupt inputs.
  - `TlvCodec` hardened with tag 0 validation, 1-byte extended length support (BER/DER), and safe decoding fallback in `TlvItem.valueAsText`.

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
