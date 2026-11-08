import 'dart:typed_data';
import 'timing_safe.dart';

/// A secure container that wraps sensitive fintech secrets (PINs, CVVs, OTPs, private keys).
///
/// Protections:
/// - Masked string representation (`[PROTECTED_VALUE]`) preventing unintentional leaks in logs.
/// - Serialization shield (`toJson()` returns `[PROTECTED_VALUE]`).
/// - Scope-safe access via [use].
/// - [zeroize] method to wipe memory buffers immediately when done.
/// - Timing-attack resistant equality checking via [TimingSafe].
class SensitiveValue<T> {
  SensitiveValue(this._value);

  /// Creates a [SensitiveValue] wrapping a sensitive [String] (e.g. password, OTP, token).
  factory SensitiveValue.fromString(String value) =>
      SensitiveValue<String>(value) as SensitiveValue<T>;

  /// Creates a [SensitiveValue] wrapping a sensitive byte buffer (e.g. private key, seed).
  factory SensitiveValue.fromBytes(List<int> bytes) =>
      SensitiveValue<Uint8List>(Uint8List.fromList(bytes)) as SensitiveValue<T>;

  T? _value;
  bool _isZeroized = false;

  /// Returns true if the sensitive memory has been cleared.
  bool get isZeroized => _isZeroized;

  /// Safely executes [block] with the sensitive value, without exposing the raw secret externally.
  R use<R>(R Function(T value) block) {
    _ensureNotZeroized();
    return block(_value as T);
  }

  /// Explicitly retrieves the sensitive value.
  ///
  /// Caution: Ensure this is not passed to logging, crash reporting, or analytics.
  T reveal() {
    _ensureNotZeroized();
    return _value as T;
  }

  /// Overwrites the sensitive buffer in memory with zeros (for byte arrays)
  /// and clears the internal reference to prevent memory inspection attacks.
  void zeroize() {
    if (_isZeroized) return;

    if (_value is Uint8List) {
      final bytes = _value as Uint8List;
      for (var i = 0; i < bytes.length; i++) {
        bytes[i] = 0;
      }
    } else if (_value is List<int>) {
      final list = _value as List<int>;
      for (var i = 0; i < list.length; i++) {
        list[i] = 0;
      }
    }

    _value = null;
    _isZeroized = true;
  }

  /// Constant-time comparison between two [SensitiveValue] instances.
  ///
  /// Prevents timing side-channel attacks during secret or credential verification.
  bool constantTimeEquals(SensitiveValue<T> other) {
    if (_isZeroized || other._isZeroized) return false;
    final valA = _value;
    final valB = other._value;
    if (valA == null || valB == null) return valA == valB;

    if (valA is List<int> && valB is List<int>) {
      return TimingSafe.equalBytes(valA, valB);
    }
    if (valA is String && valB is String) {
      return TimingSafe.equalString(valA, valB);
    }
    return valA == valB;
  }

  void _ensureNotZeroized() {
    if (_isZeroized || _value == null) {
      throw StateError(
        'SensitiveValue has already been zeroized and its contents destroyed.',
      );
    }
  }

  @override
  String toString() => '[PROTECTED_VALUE]';

  dynamic toJson() => '[PROTECTED_VALUE]';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SensitiveValue<T>) return false;
    if (_isZeroized || other._isZeroized) return false;
    return constantTimeEquals(other);
  }

  @override
  int get hashCode => _isZeroized ? 0 : (_value?.hashCode ?? 0);
}
