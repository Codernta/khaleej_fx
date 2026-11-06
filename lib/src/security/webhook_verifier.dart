import 'dart:convert';
import 'khaleej_hash.dart';
import 'timing_safe.dart';

/// Webhook signature verifier for major GCC and regional payment gateways.
///
/// Supports Tap Payments, Moyasar, Geidea, Checkout.com, PayTabs, and Network International.
class WebhookVerifier {
  const WebhookVerifier._();

  /// Generic HMAC-SHA256 webhook signature verification with timing-safe comparison.
  static bool verifyHmacSha256({
    required String rawPayload,
    required String secretKey,
    required String signatureHeader,
  }) {
    final computed = KhaleejHash.hmacSha256Hex(
      key: secretKey,
      message: rawPayload,
    );
    return TimingSafe.equalString(
      computed.toLowerCase(),
      signatureHeader.trim().toLowerCase(),
    );
  }

  /// Verifies a **Tap Payments** webhook signature (`hashstring` or HMAC header).
  ///
  /// Tap calculates HMAC-SHA256 over concatenated payload values or the raw body.
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
  ///
  /// Moyasar passes a shared webhook secret or HMAC signature in headers.
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
  ///
  /// Geidea calculates HMAC-SHA256 signature using the merchant API password/secret.
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
    final computed = base64.encode(
      KhaleejHash.hmacSha256Bytes(
        utf8.encode(secretKey),
        utf8.encode(rawBody),
      ),
    );
    return TimingSafe.equalString(computed, signature.trim());
  }
}
