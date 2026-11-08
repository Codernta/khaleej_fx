import 'dart:convert';
import 'khaleej_hash.dart';

/// Enterprise cryptographic timing-attack mitigation utilities.
///
/// Implements constant-time equality checks for sensitive strings and byte arrays
/// (such as OTPs, passwords, payment webhook signatures, and IBAN confirmations)
/// preventing side-channel execution time analysis.
class TimingSafe {
  const TimingSafe._();

  /// Constant-time comparison between two strings.
  ///
  /// Always traverses the full length of the longest input without short-circuiting
  /// on mismatch, executing identical instructions per iteration so that execution
  /// time remains uniform regardless of where mismatches occur.
  static bool equalString(String a, String b) {
    var diff = a.length ^ b.length;
    final maxLen = a.length > b.length ? a.length : b.length;

    for (var i = 0; i < maxLen; i++) {
      final codeA = i < a.length ? a.codeUnitAt(i) : 0;
      final codeB = i < b.length ? b.codeUnitAt(i) : 0;
      diff |= codeA ^ codeB;
    }

    return diff == 0;
  }

  /// Constant-time comparison between two byte lists (`List<int>` or `Uint8List`).
  ///
  /// Traverses the full length without short-circuiting on mismatch.
  static bool equalBytes(List<int> a, List<int> b) {
    var diff = a.length ^ b.length;
    final maxLen = a.length > b.length ? a.length : b.length;

    for (var i = 0; i < maxLen; i++) {
      final byteA = i < a.length ? a[i] : 0;
      final byteB = i < b.length ? b[i] : 0;
      diff |= byteA ^ byteB;
    }

    return diff == 0;
  }

  /// Strictly compares two byte lists of equal length in constant time.
  ///
  /// If lengths differ, executes dummy iterations to avoid timing side channels,
  /// then returns `false`.
  static bool equalBytesStrict(List<int> a, List<int> b) {
    final maxLen = a.length > b.length ? a.length : b.length;
    var diff = a.length ^ b.length;

    for (var i = 0; i < maxLen; i++) {
      final byteA = i < a.length ? a[i] : 0;
      final byteB = i < b.length ? b[i] : 0;
      diff |= byteA ^ byteB;
    }

    return diff == 0;
  }

  /// Side-channel immune comparison for variable-length sensitive strings (passwords, tokens).
  ///
  /// Hashes both strings with SHA-256 before constant-time digest comparison.
  /// Because SHA-256 produces a fixed 32-byte digest regardless of input length,
  /// this eliminates both value mismatches and length-based timing leakages.
  static bool equalDigest(String a, String b) {
    final hashA = KhaleejHash.sha256Bytes(utf8.encode(a));
    final hashB = KhaleejHash.sha256Bytes(utf8.encode(b));
    return equalBytes(hashA, hashB);
  }

  /// Side-channel immune comparison for variable-length sensitive byte buffers.
  ///
  /// Hashes both byte arrays with SHA-256 before constant-time digest comparison.
  static bool equalBytesDigest(List<int> a, List<int> b) {
    final hashA = KhaleejHash.sha256Bytes(a);
    final hashB = KhaleejHash.sha256Bytes(b);
    return equalBytes(hashA, hashB);
  }
}
