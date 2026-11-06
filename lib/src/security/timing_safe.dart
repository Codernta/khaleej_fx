
/// Enterprise cryptographic timing-attack mitigation utilities.
///
/// Implements constant-time equality checks for sensitive strings and byte arrays
/// (such as OTPs, passwords, payment webhook signatures, and IBAN confirmations)
/// preventing side-channel execution time analysis.
class TimingSafe {
  const TimingSafe._();

  /// Constant-time comparison between two strings.
  ///
  /// Always traverses the full length without short-circuiting on mismatch,
  /// ensuring execution time remains constant regardless of where mismatches occur.
  static bool equalString(String a, String b) {
    var diff = a.length ^ b.length;
    final minLen = a.length < b.length ? a.length : b.length;

    for (var i = 0; i < minLen; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    // Process leftover characters if lengths differ
    if (a.length > minLen) {
      for (var i = minLen; i < a.length; i++) {
        diff |= a.codeUnitAt(i);
      }
    } else if (b.length > minLen) {
      for (var i = minLen; i < b.length; i++) {
        diff |= b.codeUnitAt(i);
      }
    }

    return diff == 0;
  }

  /// Constant-time comparison between two byte lists (`List<int>` or `Uint8List`).
  static bool equalBytes(List<int> a, List<int> b) {
    var diff = a.length ^ b.length;
    final minLen = a.length < b.length ? a.length : b.length;

    for (var i = 0; i < minLen; i++) {
      diff |= a[i] ^ b[i];
    }

    if (a.length > minLen) {
      for (var i = minLen; i < a.length; i++) {
        diff |= a[i];
      }
    } else if (b.length > minLen) {
      for (var i = minLen; i < b.length; i++) {
        diff |= b[i];
      }
    }

    return diff == 0;
  }
}
