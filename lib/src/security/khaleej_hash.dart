import 'dart:convert';
import 'dart:typed_data';

/// Pure-Dart cryptographic hash implementations (RFC 6234 SHA-256 and RFC 2104 HMAC-SHA256).
///
/// Fully self-contained with zero external dependencies, running consistently
/// across all Flutter platforms (iOS, Android, Web, macOS, Linux, Windows).
class KhaleejHash {
  const KhaleejHash._();

  static const List<int> _k = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  /// Computes the SHA-256 hash of a byte array per RFC 6234.
  static Uint8List sha256Bytes(List<int> data) {
    // 1. Initial hash values
    var h0 = 0x6a09e667;
    var h1 = 0xbb67ae85;
    var h2 = 0x3c6ef372;
    var h3 = 0xa54ff53a;
    var h4 = 0x510e527f;
    var h5 = 0x9b05688c;
    var h6 = 0x1f83d9ab;
    var h7 = 0x5be0cd19;

    // 2. Pre-processing (Padding)
    final msgLengthInBytes = data.length;
    final msgLengthInBits = BigInt.from(msgLengthInBytes) * BigInt.from(8);

    // Padding length so that (msgLength + 1 + padding + 8) % 64 == 0
    final remainder = (msgLengthInBytes + 9) % 64;
    final paddingBytesCount = remainder == 0 ? 0 : 64 - remainder;
    final totalLength = msgLengthInBytes + 1 + paddingBytesCount + 8;

    final padded = Uint8List(totalLength);
    padded.setRange(0, msgLengthInBytes, data);
    padded[msgLengthInBytes] = 0x80; // append single '1' bit

    // Padded zeros are default 0 in Uint8List
    // Append 64-bit length in big-endian
    for (var i = 0; i < 8; i++) {
      final shift = (7 - i) * 8;
      padded[totalLength - 8 + i] =
          ((msgLengthInBits >> shift) & BigInt.from(0xFF)).toInt();
    }

    // 3. Process each 512-bit (64-byte) chunk
    final w = Uint32List(64);
    final byteData = ByteData.sublistView(padded);

    for (var chunk = 0; chunk < totalLength; chunk += 64) {
      // 16 words from chunk
      for (var t = 0; t < 16; t++) {
        w[t] = byteData.getUint32(chunk + (t * 4), Endian.big);
      }

      // Extend to 64 words
      for (var t = 16; t < 64; t++) {
        final s0 = _rotr32(w[t - 15], 7) ^
            _rotr32(w[t - 15], 18) ^
            (w[t - 15] >>> 3);
        final s1 = _rotr32(w[t - 2], 17) ^
            _rotr32(w[t - 2], 19) ^
            (w[t - 2] >>> 10);
        w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xFFFFFFFF;
      }

      // Initialize working variables
      var a = h0;
      var b = h1;
      var c = h2;
      var d = h3;
      var e = h4;
      var f = h5;
      var g = h6;
      var h = h7;

      // 64 compression rounds
      for (var t = 0; t < 64; t++) {
        final s1 = _rotr32(e, 6) ^ _rotr32(e, 11) ^ _rotr32(e, 25);
        final ch = (e & f) ^ (~e & g);
        final t1 = (h + s1 + ch + _k[t] + w[t]) & 0xFFFFFFFF;
        final s0 = _rotr32(a, 2) ^ _rotr32(a, 13) ^ _rotr32(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final t2 = (s0 + maj) & 0xFFFFFFFF;

        h = g;
        g = f;
        f = e;
        e = (d + t1) & 0xFFFFFFFF;
        d = c;
        c = b;
        b = a;
        a = (t1 + t2) & 0xFFFFFFFF;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
      h5 = (h5 + f) & 0xFFFFFFFF;
      h6 = (h6 + g) & 0xFFFFFFFF;
      h7 = (h7 + h) & 0xFFFFFFFF;
    }

    // 4. Produce 32-byte digest
    final digest = Uint8List(32);
    final outView = ByteData.sublistView(digest);
    outView.setUint32(0, h0, Endian.big);
    outView.setUint32(4, h1, Endian.big);
    outView.setUint32(8, h2, Endian.big);
    outView.setUint32(12, h3, Endian.big);
    outView.setUint32(16, h4, Endian.big);
    outView.setUint32(20, h5, Endian.big);
    outView.setUint32(24, h6, Endian.big);
    outView.setUint32(28, h7, Endian.big);

    return digest;
  }

  /// Computes the SHA-256 hash of a UTF-8 [text] string and returns the hex digest.
  static String sha256Hex(String text) {
    final bytes = sha256Bytes(utf8.encode(text));
    return _toHex(bytes);
  }

  /// Computes RFC 2104 HMAC-SHA256 over [message] using [key].
  static Uint8List hmacSha256Bytes(List<int> key, List<int> message) {
    const blockSize = 64; // SHA-256 block size

    var effectiveKey = key;
    if (effectiveKey.length > blockSize) {
      effectiveKey = sha256Bytes(effectiveKey);
    }

    final keyPadded = Uint8List(blockSize);
    keyPadded.setRange(0, effectiveKey.length, effectiveKey);

    final innerPad = Uint8List(blockSize + message.length);
    final outerPad = Uint8List(blockSize + 32);

    for (var i = 0; i < blockSize; i++) {
      innerPad[i] = keyPadded[i] ^ 0x36;
      outerPad[i] = keyPadded[i] ^ 0x5C;
    }

    innerPad.setRange(blockSize, innerPad.length, message);

    final innerHash = sha256Bytes(innerPad);
    outerPad.setRange(blockSize, outerPad.length, innerHash);

    return sha256Bytes(outerPad);
  }

  /// Computes RFC 2104 HMAC-SHA256 returning lowercase hex.
  static String hmacSha256Hex({required String key, required String message}) {
    final digest = hmacSha256Bytes(utf8.encode(key), utf8.encode(message));
    return _toHex(digest);
  }

  static int _rotr32(int x, int n) =>
      ((x >>> n) | (x << (32 - n))) & 0xFFFFFFFF;

  static String _toHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
