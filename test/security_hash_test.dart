import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:khaleej_fx/khaleej_fx.dart';

void main() {
  group('KhaleejHash - NIST CAVP / RFC 6234 SHA-256 Vectors', () {
    test('SHA-256 Vector 1: Empty string', () {
      final digest = KhaleejHash.sha256Hex('');
      expect(
        digest,
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('SHA-256 Vector 2: "abc"', () {
      final digest = KhaleejHash.sha256Hex('abc');
      expect(
        digest,
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('SHA-256 Vector 3: multi-block string', () {
      const msg =
          'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq';
      final digest = KhaleejHash.sha256Hex(msg);
      expect(
        digest,
        '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
      );
    });
  });

  group('KhaleejHash - RFC 4231 HMAC-SHA256 Test Vectors', () {
    test('RFC 4231 Test Case 1: 20-byte key with "Hi There"', () {
      final key = List.filled(20, 0x0B);
      final msg = utf8.encode('Hi There');
      final digestBytes = KhaleejHash.hmacSha256Bytes(key, msg);
      final digestHex = digestBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

      expect(
        digestHex,
        'b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7',
      );
    });

    test('RFC 4231 Test Case 2: key="Jefe", data="what do ya want for nothing?"', () {
      final digest = KhaleejHash.hmacSha256Hex(
        key: 'Jefe',
        message: 'what do ya want for nothing?',
      );
      expect(
        digest,
        '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843',
      );
    });
  });

  group('WebhookVerifier (Tap, Moyasar, Geidea, Checkout.com, PayTabs)', () {
    test('verifies Tap / Moyasar / Geidea HMAC webhook signatures', () {
      const secret = 'sk_test_123456789';
      const body = '{"id":"chg_123","status":"CAPTURED","amount":100}';
      final validSig = KhaleejHash.hmacSha256Hex(key: secret, message: body);

      expect(
        WebhookVerifier.verifyTap(
          rawBody: body,
          secretKey: secret,
          signature: validSig,
        ),
        isTrue,
      );

      expect(
        WebhookVerifier.verifyMoyasar(
          rawBody: body,
          secretKey: secret,
          signature: validSig,
        ),
        isTrue,
      );

      // Rejects forged signature
      expect(
        WebhookVerifier.verifyTap(
          rawBody: body,
          secretKey: secret,
          signature: 'invalid_forged_signature',
        ),
        isFalse,
      );
    });

    test('verifies PayTabs query string HMAC signature', () {
      const serverKey = 'SKJLLLLK-TEST-KEY';
      final payload = {
        'cart_id': '1001',
        'tran_ref': 'TST230001',
        'tran_total': '150.00',
      };

      // Generate expected PayTabs signature
      final sortedKeys = payload.keys.toList()..sort();
      final queryParts = sortedKeys
          .map((k) => '$k=${Uri.encodeQueryComponent(payload[k]!)}')
          .join('&');
      final sig = KhaleejHash.hmacSha256Hex(key: serverKey, message: queryParts);

      expect(
        WebhookVerifier.verifyPayTabs(
          payload: payload,
          serverKey: serverKey,
          signature: sig,
        ),
        isTrue,
      );
    });
  });

  group('TimingSafe Utilities', () {
    test('constant-time string and byte equality', () {
      expect(TimingSafe.equalString('secret123', 'secret123'), isTrue);
      expect(TimingSafe.equalString('secret123', 'secret124'), isFalse);
      expect(TimingSafe.equalString('secret123', 'secret12'), isFalse);

      final b1 = Uint8List.fromList([1, 2, 3]);
      final b2 = Uint8List.fromList([1, 2, 3]);
      final b3 = Uint8List.fromList([1, 2, 4]);

      expect(TimingSafe.equalBytes(b1, b2), isTrue);
      expect(TimingSafe.equalBytes(b1, b3), isFalse);
    });
  });

  group('SensitiveValue', () {
    test('masks secret from toString and toJson', () {
      final secret = SensitiveValue<String>('my_super_secret_otp_9999');

      expect(secret.toString(), '[PROTECTED_VALUE]');
      expect(secret.toJson(), '[PROTECTED_VALUE]');
      expect(secret.reveal(), 'my_super_secret_otp_9999');

      secret.use((val) {
        expect(val, 'my_super_secret_otp_9999');
      });
    });

    test('zeroizes memory buffer and blocks subsequent access', () {
      final bytes = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]);
      final secret = SensitiveValue<Uint8List>(bytes);

      expect(secret.isZeroized, isFalse);
      secret.zeroize();
      expect(secret.isZeroized, isTrue);

      // Memory buffer was overwritten with zeros
      expect(bytes, [0, 0, 0, 0]);

      // Attempting to reveal throws StateError
      expect(() => secret.reveal(), throwsStateError);
      expect(() => secret.use((v) => v), throwsStateError);
    });
  });
}
