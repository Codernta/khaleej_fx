/// PCI DSS 4.0 compliant Payment Card Industry Primary Account Number (PAN) masking.
class CardMasker {
  const CardMasker._();

  /// Masks a card number compliant with PCI DSS v4.0 Requirement 3.4.
  ///
  /// Options:
  /// - [preserveBin]: When true, preserves the first 6 digits (BIN/IIN) and the last 4 digits
  ///   (e.g., `4176 33XX XXXX 1234`). When false, displays only the last 4 digits
  ///   (e.g., `XXXX XXXX XXXX 1234`).
  /// - [maskChar]: The character used to mask digits (default `'X'`).
  /// - [delimiter]: Character separating 4-digit groups (e.g., `' '` or `'-'`).
  static String mask(
    String pan, {
    bool preserveBin = false,
    String maskChar = 'X',
    String delimiter = ' ',
  }) {
    final clean = pan.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 10) {
      // Too short to safely mask with BIN+last4, mask all but last 2
      if (clean.length <= 4) return clean;
      return '${maskChar * (clean.length - 4)}${clean.substring(clean.length - 4)}';
    }

    final totalLen = clean.length;
    final last4 = clean.substring(totalLen - 4);
    final String rawMasked;

    if (preserveBin) {
      final bin6 = clean.substring(0, 6);
      final maskedMiddleLen = totalLen - 10;
      rawMasked = '$bin6${maskChar * maskedMiddleLen}$last4';
    } else {
      final maskedPrefixLen = totalLen - 4;
      rawMasked = '${maskChar * maskedPrefixLen}$last4';
    }

    if (delimiter.isEmpty) {
      return rawMasked;
    }

    // Group into 4-digit blocks
    final buffer = StringBuffer();
    for (var i = 0; i < rawMasked.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(delimiter);
      }
      buffer.write(rawMasked[i]);
    }
    return buffer.toString();
  }

  /// Formats a card PAN into 4-character blocks or 4-6-5 blocks for Amex.
  static String format(String pan) {
    final clean = pan.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('34') || clean.startsWith('37')) {
      // Amex: 4 - 6 - 5
      final buffer = StringBuffer();
      for (var i = 0; i < clean.length; i++) {
        if (i == 4 || i == 10) {
          buffer.write(' ');
        }
        buffer.write(clean[i]);
      }
      return buffer.toString();
    }

    // Standard 4-digit grouping
    final buffer = StringBuffer();
    for (var i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }
}
