import 'dart:convert';
import 'khaleej_hash.dart';
import 'timing_safe.dart';

/// Webhook signature verifier for major GCC and regional payment gateways.
///
/// Supports Tap Payments, Moyasar, Geidea, HyperPay, Tamara, Tabby,
/// Checkout.com, PayTabs, Network International, and Stripe.
///
/// Security Mitigations:
/// - Side-channel timing attack immunity via [TimingSafe].
/// - Replay attack prevention via timestamp validation with tolerance window.
/// - Mandatory key validation (empty or whitespace keys are strictly rejected).
/// - Automatic scheme normalization (strips `sha256=` or `hex=` prefixes).
class WebhookVerifier {
  const WebhookVerifier._();

  /// Generic HMAC-SHA256 webhook signature verification with timing-safe comparison.
  ///
  /// Rejects empty keys or signatures, strips common prefixes (`sha256=`, `hex=`),
  /// and compares computed HMAC against [signatureHeader] in constant time.
  static bool verifyHmacSha256({
    required String rawPayload,
    required String secretKey,
    required String signatureHeader,
  }) {
    final cleanSecret = secretKey.trim();
    final cleanSig = _normalizeSignature(signatureHeader);

    if (cleanSecret.isEmpty || cleanSig.isEmpty) {
      return false;
    }

    final computed = KhaleejHash.hmacSha256Hex(
      key: cleanSecret,
      message: rawPayload,
    );

    return TimingSafe.equalString(
      computed.toLowerCase(),
      cleanSig.toLowerCase(),
    );
  }

  /// Verifies an HMAC-SHA256 signature with replay attack protection.
  ///
  /// Verifies that:
  /// 1. `|currentTime - timestampInSeconds| <= tolerance` (rejecting stale/replayed webhooks).
  /// 2. Signature matches HMAC-SHA256 computed over the payload.
  ///
  /// If [includeTimestampInSignature] is true (e.g. Stripe, Tap), computes HMAC over
  /// `"$timestampInSeconds.$rawPayload"`.
  static bool verifyWithTimestamp({
    required String rawPayload,
    required String secretKey,
    required String signatureHeader,
    required int timestampInSeconds,
    Duration tolerance = const Duration(minutes: 5),
    int? currentTimestampInSeconds,
    bool includeTimestampInSignature = false,
  }) {
    final now = currentTimestampInSeconds ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final age = (now - timestampInSeconds).abs();

    if (age > tolerance.inSeconds) {
      return false; // Replay attack detected or timestamp expired
    }

    final payloadToVerify = includeTimestampInSignature
        ? '$timestampInSeconds.$rawPayload'
        : rawPayload;

    return verifyHmacSha256(
      rawPayload: payloadToVerify,
      secretKey: secretKey,
      signatureHeader: signatureHeader,
    );
  }

  /// Verifies a **Tap Payments** webhook signature (`hashstring` or HMAC header).
  static bool verifyTap({
    required String rawBody,
    required String secretKey,
    required String signature,
  }) {
    return verifyHmacSha256(
      rawPayload: rawBody,
      secretKey: secretKey,
      signatureHeader: signature,
    );
  }

  /// Verifies a **Moyasar** webhook request.
  static bool verifyMoyasar({
    required String rawBody,
    required String secretKey,
    required String signature,
  }) {
    return verifyHmacSha256(
      rawPayload: rawBody,
      secretKey: secretKey,
      signatureHeader: signature,
    );
  }

  /// Verifies a **Geidea** payment gateway webhook notification.
  static bool verifyGeidea({
    required String rawBody,
    required String secretKey,
    required String signature,
  }) {
    return verifyHmacSha256(
      rawPayload: rawBody,
      secretKey: secretKey,
      signatureHeader: signature,
    );
  }

  /// Verifies a **HyperPay** payment gateway webhook notification (`X-Signature` header).
  ///
  /// Widely used across Saudi Arabia and the UAE. HyperPay calculates an HMAC-SHA256
  /// signature of the raw request payload using the merchant webhook key.
  static bool verifyHyperPay({
    required String rawBody,
    required String secretKey,
    required String signature,
  }) {
    return verifyHmacSha256(
      rawPayload: rawBody,
      secretKey: secretKey,
      signatureHeader: signature,
    );
  }

  /// Verifies a **Tamara** Buy-Now-Pay-Later (BNPL) webhook notification.
  ///
  /// Supports both HMAC-SHA256 signature verification and bearer token confirmation.
  static bool verifyTamara({
    required String rawBody,
    required String notificationToken,
    required String signatureOrToken,
  }) {
    final cleanToken = notificationToken.trim();
    final cleanSig = signatureOrToken.trim();

    if (cleanToken.isEmpty || cleanSig.isEmpty) {
      return false;
    }

    // Direct token comparison (Authorization / Bearer token mode)
    if (TimingSafe.equalString(cleanToken, cleanSig)) {
      return true;
    }

    // HMAC signature mode
    return verifyHmacSha256(
      rawPayload: rawBody,
      secretKey: cleanToken,
      signatureHeader: cleanSig,
    );
  }

  /// Verifies a **Tabby** Buy-Now-Pay-Later (BNPL) webhook notification.
  static bool verifyTabby({
    required String rawBody,
    required String secretKey,
    required String signature,
  }) {
    return verifyHmacSha256(
      rawPayload: rawBody,
      secretKey: secretKey,
      signatureHeader: signature,
    );
  }

  /// Verifies a **Checkout.com** webhook notification (`cko-signature` header).
  static bool verifyCheckoutCom({
    required String rawBody,
    required String secretKey,
    required String ckoSignature,
  }) {
    return verifyHmacSha256(
      rawPayload: rawBody,
      secretKey: secretKey,
      signatureHeader: ckoSignature,
    );
  }

  /// Verifies a **PayTabs** IPN / webhook response signature (`signature` header).
  ///
  /// PayTabs server-to-server signature calculation verifies HMAC over sorted payload.
  static bool verifyPayTabs({
    required Map<String, dynamic> payload,
    required String serverKey,
    required String signature,
  }) {
    if (serverKey.trim().isEmpty || signature.trim().isEmpty) {
      return false;
    }

    // PayTabs excludes 'signature' parameter and sorts keys alphabetically
    final filtered = Map<String, dynamic>.from(payload)..remove('signature');
    final sortedKeys = filtered.keys.toList()..sort();

    final queryParts = <String>[];
    for (final key in sortedKeys) {
      final val = filtered[key];
      if (val != null && val.toString().isNotEmpty) {
        queryParts.add('$key=${Uri.encodeQueryComponent(val.toString())}');
      }
    }
    final message = queryParts.join('&');

    return verifyHmacSha256(
      rawPayload: message,
      secretKey: serverKey,
      signatureHeader: signature,
    );
  }

  /// Verifies a **Network International (N-Genius)** webhook notification.
  static bool verifyNetworkInternational({
    required String rawBody,
    required String secretKey,
    required String signature,
  }) {
    final cleanSecret = secretKey.trim();
    final cleanSig = signature.trim();

    if (cleanSecret.isEmpty || cleanSig.isEmpty) {
      return false;
    }

    final computed = base64.encode(
      KhaleejHash.hmacSha256Bytes(
        utf8.encode(cleanSecret),
        utf8.encode(rawBody),
      ),
    );
    return TimingSafe.equalString(computed, cleanSig);
  }

  /// Verifies a **Stripe** webhook notification (`Stripe-Signature` header).
  ///
  /// Extracts the timestamp `t` and signature `v1`, prevents replay attacks
  /// within [tolerance], and computes HMAC-SHA256 over `${timestamp}.${rawBody}`.
  static bool verifyStripe({
    required String rawBody,
    required String secretKey,
    required String signatureHeader,
    Duration tolerance = const Duration(minutes: 5),
    int? currentTimestampInSeconds,
  }) {
    final cleanSecret = secretKey.trim();
    if (cleanSecret.isEmpty || signatureHeader.trim().isEmpty) {
      return false;
    }

    final elements = signatureHeader.split(',');
    int? timestamp;
    final signatures = <String>[];

    for (final item in elements) {
      final parts = item.split('=');
      if (parts.length == 2) {
        final prefix = parts[0].trim();
        final value = parts[1].trim();
        if (prefix == 't') {
          timestamp = int.tryParse(value);
        } else if (prefix == 'v1') {
          signatures.add(value);
        }
      }
    }

    if (timestamp == null || signatures.isEmpty) {
      return false;
    }

    final now = currentTimestampInSeconds ??
        (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    if ((now - timestamp).abs() > tolerance.inSeconds) {
      return false; // Replay window exceeded
    }

    final signedPayload = '$timestamp.$rawBody';
    final computed = KhaleejHash.hmacSha256Hex(
      key: cleanSecret,
      message: signedPayload,
    );

    for (final sig in signatures) {
      if (TimingSafe.equalString(computed.toLowerCase(), sig.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  static String _normalizeSignature(String sig) {
    var s = sig.trim();
    final lower = s.toLowerCase();
    if (lower.startsWith('sha256=')) {
      s = s.substring(7).trim();
    } else if (lower.startsWith('sha256:')) {
      s = s.substring(7).trim();
    } else if (lower.startsWith('hex=')) {
      s = s.substring(4).trim();
    }
    return s;
  }
}
