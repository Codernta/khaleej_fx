import 'dart:convert';
import 'dart:typed_data';
import '../money/khaleej_money.dart';
import 'tlv.dart';

/// ZATCA e-Invoicing (FATOORAH) invoice data model for Phase 1 & Phase 2 QR codes.
class ZatcaInvoice {
  const ZatcaInvoice({
    required this.sellerName,
    required this.vatRegistrationNumber,
    required this.timestamp,
    required this.invoiceTotal,
    required this.vatTotal,
    this.invoiceHash,
    this.cryptographicStamp,
    this.publicKey,
  });

  /// Factory constructing from [KhaleejMoney] values.
  factory ZatcaInvoice.fromMoney({
    required String sellerName,
    required String vatRegistrationNumber,
    required DateTime timestamp,
    required KhaleejMoney invoiceTotal,
    required KhaleejMoney vatTotal,
    Uint8List? invoiceHash,
    Uint8List? cryptographicStamp,
    Uint8List? publicKey,
  }) {
    return ZatcaInvoice(
      sellerName: sellerName,
      vatRegistrationNumber: vatRegistrationNumber,
      timestamp: timestamp,
      invoiceTotal: invoiceTotal.format(includeSymbol: false),
      vatTotal: vatTotal.format(includeSymbol: false),
      invoiceHash: invoiceHash,
      cryptographicStamp: cryptographicStamp,
      publicKey: publicKey,
    );
  }

  /// Tag 1: Seller's legal business name.
  final String sellerName;

  /// Tag 2: Seller's 15-digit VAT Registration Number (starts and ends with 3).
  final String vatRegistrationNumber;

  /// Tag 3: Invoice issuance timestamp in ISO 8601 format.
  final DateTime timestamp;

  /// Tag 4: Total invoice amount including VAT.
  final String invoiceTotal;

  /// Tag 5: Total VAT amount.
  final String vatTotal;

  /// Tag 6 (Phase 2): SHA-256 hash of the UBL 2.1 XML invoice.
  final Uint8List? invoiceHash;

  /// Tag 7 (Phase 2): ECDSA cryptographic stamp (signature).
  final Uint8List? cryptographicStamp;

  /// Tag 8 (Phase 2): ECDSA public key certificate.
  final Uint8List? publicKey;

  /// Returns true if this invoice contains Phase 2 integration tags (6, 7, 8).
  bool get isPhase2 =>
      invoiceHash != null && cryptographicStamp != null && publicKey != null;

  /// Validates compliance with ZATCA technical specifications.
  List<String> validate() {
    final errors = <String>[];

    if (sellerName.trim().isEmpty) {
      errors.add('Seller name must not be empty (Tag 1)');
    }

    final cleanVat = vatRegistrationNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanVat.length != 15) {
      errors.add('VAT number must be exactly 15 digits (Tag 2, got ${cleanVat.length})');
    } else if (!cleanVat.startsWith('3') || !cleanVat.endsWith('3')) {
      errors.add('VAT number must start and end with digit 3 (Tag 2)');
    }

    final total = double.tryParse(invoiceTotal);
    final vat = double.tryParse(vatTotal);

    if (total == null) {
      errors.add('Invalid invoice total format (Tag 4: "$invoiceTotal")');
    }
    if (vat == null) {
      errors.add('Invalid VAT total format (Tag 5: "$vatTotal")');
    }
    if (total != null && vat != null && vat > total) {
      errors.add('VAT amount ($vat) cannot exceed total invoice amount ($total)');
    }

    if (invoiceHash != null && invoiceHash!.length != 32) {
      errors.add('SHA-256 XML hash must be exactly 32 bytes (Tag 6, got ${invoiceHash!.length})');
    }

    return errors;
  }
}

/// ZATCA FATOORAH Phase 1 & Phase 2 Base64 TLV QR Code encoder and decoder.
class ZatcaQr {
  const ZatcaQr._();

  /// Encodes a [ZatcaInvoice] into a ZATCA-compliant Base64 TLV string.
  static String encode(ZatcaInvoice invoice) {
    final items = <TlvItem>[
      // Tag 1: Seller Name
      TlvItem.fromText(1, invoice.sellerName),

      // Tag 2: VAT Registration Number
      TlvItem.fromText(2, invoice.vatRegistrationNumber),

      // Tag 3: Timestamp (ISO 8601 UTC or local)
      TlvItem.fromText(3, invoice.timestamp.toIso8601String()),

      // Tag 4: Invoice Total
      TlvItem.fromText(4, invoice.invoiceTotal),

      // Tag 5: Total VAT
      TlvItem.fromText(5, invoice.vatTotal),
    ];

    // Phase 2 Optional Tags
    if (invoice.invoiceHash != null) {
      items.add(TlvItem.fromBytes(6, invoice.invoiceHash!));
    }
    if (invoice.cryptographicStamp != null) {
      items.add(TlvItem.fromBytes(7, invoice.cryptographicStamp!));
    }
    if (invoice.publicKey != null) {
      items.add(TlvItem.fromBytes(8, invoice.publicKey!));
    }

    final rawBytes = TlvCodec.encode(items);
    return base64.encode(rawBytes);
  }

  /// Safely attempts to decode a ZATCA Base64 TLV string back into a [ZatcaInvoice].
  ///
  /// Returns `null` if the input is malformed, corrupted, or missing mandatory tags,
  /// preventing unhandled exceptions from interrupting transaction flows.
  static ZatcaInvoice? tryDecode(String base64Qr) {
    try {
      return decode(base64Qr);
    } catch (_) {
      return null;
    }
  }

  /// Decodes a ZATCA Base64 TLV string back into a [ZatcaInvoice].
  static ZatcaInvoice decode(String base64Qr) {
    final rawBytes = base64.decode(base64Qr.trim());
    final items = TlvCodec.decode(Uint8List.fromList(rawBytes));

    String? sellerName;
    String? vatNumber;
    DateTime? timestamp;
    String? total;
    String? vat;
    Uint8List? invoiceHash;
    Uint8List? cryptographicStamp;
    Uint8List? publicKey;

    for (final item in items) {
      switch (item.tag) {
        case 1:
          sellerName = item.valueAsText;
        case 2:
          vatNumber = item.valueAsText;
        case 3:
          timestamp = DateTime.tryParse(item.valueAsText);
        case 4:
          total = item.valueAsText;
        case 5:
          vat = item.valueAsText;
        case 6:
          invoiceHash = item.value;
        case 7:
          cryptographicStamp = item.value;
        case 8:
          publicKey = item.value;
      }
    }

    if (sellerName == null ||
        vatNumber == null ||
        timestamp == null ||
        total == null ||
        vat == null) {
      throw FormatException(
        'Incomplete ZATCA TLV payload: missing one or more mandatory tags (1..5)',
      );
    }

    return ZatcaInvoice(
      sellerName: sellerName,
      vatRegistrationNumber: vatNumber,
      timestamp: timestamp,
      invoiceTotal: total,
      vatTotal: vat,
      invoiceHash: invoiceHash,
      cryptographicStamp: cryptographicStamp,
      publicKey: publicKey,
    );
  }
}
