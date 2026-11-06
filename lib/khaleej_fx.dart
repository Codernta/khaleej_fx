/// Khaleej FX: Enterprise GCC Fintech, Banking, Identity, VAT, and Utilities library for Flutter and Dart.
///
/// Complete suite covering:
/// - Saudi Arabia 🇸🇦, UAE 🇦🇪, Kuwait 🇰🇼, Qatar 🇶🇦, Bahrain 🇧🇭, and Oman 🇴🇲
/// - Sub-unit precision fixed-point money arithmetic & Tafqeet
/// - National ID & Residency validation (Saudi ID/Iqama, Emirates ID, Kuwait Civil ID, Qatar ID, Bahrain CPR, Oman Civil ID)
/// - ISO 13616 & ISO 7064 Mod 97-10 IBAN validation with GCC Bank Directory
/// - Domestic card switches (Mada, Jaywan, KNET, Benefit, Himyan, OmanNet) & PCI DSS 4.0 masking
/// - GCC VAT & ZATCA FATOORAH Phase 1 & 2 TLV QR Code engine
/// - Enterprise fintech security (TimingSafe, SensitiveValue, pure-Dart SHA-256 & HMAC-SHA256, Webhook verifiers, PII Redactor)
/// - Arabic text normalization, numeral converter, and address validator
/// - Hardened UI widgets (KhaleejTextField, ZatcaQrWidget, GccVehiclePlateWidget)
library;

// Core
export 'src/core/gcc_country.dart';

// Money & Tafqeet
export 'src/money/khaleej_currency.dart';
export 'src/money/khaleej_money.dart';
export 'src/money/tafqeet.dart';

// Identity & Civil Cards
export 'src/identity/bahrain_cpr.dart';
export 'src/identity/emirates_id.dart';
export 'src/identity/khaleej_id.dart';
export 'src/identity/kuwait_civil_id.dart';
export 'src/identity/oman_civil_id.dart';
export 'src/identity/qatar_id.dart';
export 'src/identity/saudi_id.dart';

// Banking & IBAN
export 'src/banking/bank_directory.dart';
export 'src/banking/bank_info.dart';
export 'src/banking/iban_validator.dart';

// Cards & Domestic Switches
export 'src/cards/card_brand.dart';
export 'src/cards/card_masker.dart';
export 'src/cards/card_validator.dart';
export 'src/cards/domestic_switches.dart';

// VAT & ZATCA e-Invoicing
export 'src/vat/khaleej_vat.dart';
export 'src/vat/tlv.dart';
export 'src/vat/zatca_qr.dart';

// Security & Cryptography
export 'src/security/khaleej_hash.dart';
export 'src/security/pii_redactor.dart';
export 'src/security/sensitive_value.dart';
export 'src/security/timing_safe.dart';
export 'src/security/webhook_verifier.dart';

// Arabic & Address Utilities
export 'src/utils/address_validator.dart';
export 'src/utils/arabic_normalizer.dart';
export 'src/utils/numeral_converter.dart';

// Widgets & Formatters
export 'src/widgets/formatters.dart';
export 'src/widgets/khaleej_text_field.dart';
export 'src/widgets/vehicle_plate_widget.dart';
export 'src/widgets/zatca_qr_widget.dart';
