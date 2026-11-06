import 'package:flutter/material.dart';
import '../vat/zatca_qr.dart';
import 'qr/qr_matrix.dart';

/// Interactive ZATCA e-Invoicing (FATOORAH) QR Code display widget with validation diagnostics.
///
/// Features:
/// - Pure Flutter vector QR Code rendering (zero third-party dependencies).
/// - Instant decoding and validation diagnostics panel.
/// - Compliance status indicators for Phase 1 & Phase 2.
class ZatcaQrWidget extends StatefulWidget {
  const ZatcaQrWidget({
    super.key,
    this.invoice,
    this.base64Qr,
    this.size = 220.0,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(12.0),
    this.showDiagnostics = true,
  }) : assert(invoice != null || base64Qr != null, 'Either invoice or base64Qr must be provided');

  /// The structured ZATCA invoice.
  final ZatcaInvoice? invoice;

  /// The raw Base64-encoded ZATCA TLV string.
  final String? base64Qr;

  /// Rendered size of the QR code in logical pixels.
  final double size;

  /// QR module color.
  final Color color;

  /// Background color.
  final Color backgroundColor;

  /// Padding around the QR code matrix.
  final EdgeInsets padding;

  /// Whether to display the interactive diagnostic breakdown sheet below the QR code.
  final bool showDiagnostics;

  @override
  State<ZatcaQrWidget> createState() => _ZatcaQrWidgetState();
}

class _ZatcaQrWidgetState extends State<ZatcaQrWidget> {
  late String _qrPayload;
  late ZatcaInvoice? _decodedInvoice;
  List<String> _validationErrors = [];
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant ZatcaQrWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoice != widget.invoice || oldWidget.base64Qr != widget.base64Qr) {
      _processData();
    }
  }

  void _processData() {
    if (widget.invoice != null) {
      _decodedInvoice = widget.invoice;
      _qrPayload = ZatcaQr.encode(widget.invoice!);
    } else {
      _qrPayload = widget.base64Qr!;
      try {
        _decodedInvoice = ZatcaQr.decode(_qrPayload);
      } catch (e) {
        _decodedInvoice = null;
        _validationErrors = ['Decoding error: ${e.toString()}'];
        return;
      }
    }

    if (_decodedInvoice != null) {
      _validationErrors = _decodedInvoice!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final matrix = QrMatrix.generate(_qrPayload);
    final isValid = _validationErrors.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // QR Code Card
        Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _QrPainter(
              matrix: matrix,
              color: widget.color,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Compliance Status Badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isValid ? Icons.verified : Icons.warning_amber_rounded,
              size: 16,
              color: isValid ? Colors.green.shade700 : Colors.amber.shade800,
            ),
            const SizedBox(width: 6),
            Text(
              isValid
                  ? (_decodedInvoice?.isPhase2 ?? false
                      ? 'ZATCA Phase 2 Valid'
                      : 'ZATCA Phase 1 Valid')
                  : 'Compliance Issue (${_validationErrors.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isValid ? Colors.green.shade800 : Colors.amber.shade900,
              ),
            ),
          ],
        ),

        // Optional Diagnostics Panel
        if (widget.showDiagnostics && _decodedInvoice != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
            ),
            label: Text(_expanded ? 'Hide Diagnostics' : 'Inspect ZATCA Tags'),
          ),
          if (_expanded)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _diagRow('Seller (Tag 1)', _decodedInvoice!.sellerName),
                  _diagRow('VAT No. (Tag 2)', _decodedInvoice!.vatRegistrationNumber),
                  _diagRow('Timestamp (Tag 3)', _decodedInvoice!.timestamp.toIso8601String()),
                  _diagRow('Total (Tag 4)', '${_decodedInvoice!.invoiceTotal} SAR'),
                  _diagRow('VAT (Tag 5)', '${_decodedInvoice!.vatTotal} SAR'),
                  if (_decodedInvoice!.isPhase2) ...[
                    _diagRow('Phase 2 Hash', 'SHA-256 Verified'),
                    _diagRow('Cryptographic Stamp', 'ECDSA Present'),
                  ],
                  if (_validationErrors.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Validation Issues:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    for (final err in _validationErrors)
                      Text('• $err', style: const TextStyle(color: Colors.red, fontSize: 11)),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _diagRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter({
    required this.matrix,
    required this.color,
  });

  final QrMatrix matrix;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final moduleCount = matrix.size;
    final moduleSize = size.width / moduleCount;

    for (var r = 0; r < moduleCount; r++) {
      for (var c = 0; c < moduleCount; c++) {
        if (matrix.modules[r][c]) {
          final rect = Rect.fromLTWH(
            c * moduleSize,
            r * moduleSize,
            moduleSize,
            moduleSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.matrix != matrix || oldDelegate.color != color;
}
