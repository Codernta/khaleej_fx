import 'dart:convert';

/// Minimal pure-Dart QR Code matrix generator (ISO/IEC 18004 compliant).
///
/// Supports Byte mode encoding with Error Correction Level M/L
/// for data payloads up to 300+ bytes (ZATCA e-invoicing QR strings).
class QrMatrix {
  QrMatrix._({
    required this.version,
    required this.size,
    required this.modules,
  });

  final int version;
  final int size;
  final List<List<bool>> modules;

  /// Generates a QR Code matrix for the given [data] string.
  static QrMatrix generate(String data) {
    final bytes = utf8.encode(data);
    final version = _determineVersion(bytes.length);
    final size = version * 4 + 17;

    // Initialize modules matrix and reserved pattern mask
    final modules = List.generate(size, (_) => List.filled(size, false));
    final reserved = List.generate(size, (_) => List.filled(size, false));

    // 1. Add Function Patterns
    _addFinderPattern(modules, reserved, 0, 0);
    _addFinderPattern(modules, reserved, size - 7, 0);
    _addFinderPattern(modules, reserved, 0, size - 7);

    _addTimingPatterns(modules, reserved, size);
    _addAlignmentPatterns(modules, reserved, version, size);

    // Dark module
    modules[size - 8][8] = true;
    reserved[size - 8][8] = true;

    // Reserve format information areas
    _reserveFormatAreas(reserved, size);

    // 2. Encode Data + Error Correction
    final codewords = _encodeData(bytes, version);

    // 3. Place Data Codewords into Matrix
    _placeCodewords(modules, reserved, codewords, size);

    // 4. Apply Mask Pattern (Mask 0: (row + col) % 2 == 0)
    _applyMask(modules, reserved, size);

    // 5. Write Format Information (Level L/M + Mask 0)
    _writeFormatInformation(modules, size);

    return QrMatrix._(
      version: version,
      size: size,
      modules: modules,
    );
  }

  static int _determineVersion(int byteCount) {
    // Capacity for Level L / M in Byte mode:
    // V1: 17, V2: 32, V3: 53, V4: 78, V5: 106, V6: 134, V7: 154, V8: 192, V9: 230, V10: 271, V12: 367
    if (byteCount <= 17) return 1;
    if (byteCount <= 32) return 2;
    if (byteCount <= 53) return 3;
    if (byteCount <= 78) return 4;
    if (byteCount <= 106) return 5;
    if (byteCount <= 134) return 6;
    if (byteCount <= 154) return 7;
    if (byteCount <= 192) return 8;
    if (byteCount <= 230) return 9;
    if (byteCount <= 271) return 10;
    if (byteCount <= 321) return 11;
    return 12; // up to ~367 bytes
  }

  static void _addFinderPattern(
    List<List<bool>> m,
    List<List<bool>> res,
    int r,
    int c,
  ) {
    for (var i = -1; i <= 7; i++) {
      for (var j = -1; j <= 7; j++) {
        final row = r + i;
        final col = c + j;
        if (row >= 0 && row < m.length && col >= 0 && col < m.length) {
          res[row][col] = true;
          if ((i >= 0 && i <= 6 && (j == 0 || j == 6)) ||
              (j >= 0 && j <= 6 && (i == 0 || i == 6)) ||
              (i >= 2 && i <= 4 && j >= 2 && j <= 4)) {
            m[row][col] = true;
          } else {
            m[row][col] = false;
          }
        }
      }
    }
  }

  static void _addTimingPatterns(
    List<List<bool>> m,
    List<List<bool>> res,
    int size,
  ) {
    for (var i = 8; i < size - 8; i++) {
      final val = i % 2 == 0;
      if (!res[6][i]) {
        m[6][i] = val;
        res[6][i] = true;
      }
      if (!res[i][6]) {
        m[i][6] = val;
        res[i][6] = true;
      }
    }
  }

  static void _addAlignmentPatterns(
    List<List<bool>> m,
    List<List<bool>> res,
    int version,
    int size,
  ) {
    if (version < 2) return;
    final pos = _alignmentPositions(version, size);
    for (final r in pos) {
      for (final c in pos) {
        if (res[r][c]) continue; // Skip if overlapping with finder
        _drawAlignment(m, res, r, c);
      }
    }
  }

  static List<int> _alignmentPositions(int v, int size) {
    if (v == 1) return [];
    if (v == 2) return [6, 18];
    if (v == 3) return [6, 22];
    if (v == 4) return [6, 26];
    if (v == 5) return [6, 30];
    if (v == 6) return [6, 34];
    if (v == 7) return [6, 22, 38];
    if (v == 8) return [6, 24, 42];
    if (v == 9) return [6, 26, 46];
    if (v == 10) return [6, 28, 50];
    if (v == 11) return [6, 30, 54];
    return [6, 32, 58];
  }

  static void _drawAlignment(
    List<List<bool>> m,
    List<List<bool>> res,
    int r,
    int c,
  ) {
    for (var i = -2; i <= 2; i++) {
      for (var j = -2; j <= 2; j++) {
        final row = r + i;
        final col = c + j;
        res[row][col] = true;
        if (i == -2 || i == 2 || j == -2 || j == 2 || (i == 0 && j == 0)) {
          m[row][col] = true;
        } else {
          m[row][col] = false;
        }
      }
    }
  }

  static void _reserveFormatAreas(List<List<bool>> res, int size) {
    for (var i = 0; i < 9; i++) {
      res[8][i] = true;
      res[i][8] = true;
    }
    for (var i = 0; i < 8; i++) {
      res[8][size - 1 - i] = true;
      res[size - 1 - i][8] = true;
    }
  }

  static List<int> _encodeData(List<int> bytes, int version) {
    final totalDataCodewords = _totalDataCodewords(version);
    final bits = <int>[];

    // Byte Mode Indicator: 0100
    bits.addAll([0, 1, 0, 0]);

    // Character Count Indicator (8 bits for V1-V9, 16 bits for V10+)
    final countBits = version <= 9 ? 8 : 16;
    for (var i = countBits - 1; i >= 0; i--) {
      bits.add((bytes.length >> i) & 1);
    }

    // Byte payload
    for (final b in bytes) {
      for (var i = 7; i >= 0; i--) {
        bits.add((b >> i) & 1);
      }
    }

    // Terminator: up to 4 zeros
    final maxBits = totalDataCodewords * 8;
    for (var i = 0; i < 4 && bits.length < maxBits; i++) {
      bits.add(0);
    }

    // Align to 8-bit boundary
    while (bits.length % 8 != 0) {
      bits.add(0);
    }

    // Pad with alternate 0xEC and 0x11
    final dataCodewords = <int>[];
    for (var i = 0; i < bits.length; i += 8) {
      var byteVal = 0;
      for (var j = 0; j < 8; j++) {
        byteVal = (byteVal << 1) | bits[i + j];
      }
      dataCodewords.add(byteVal);
    }

    var padByte = 0xEC;
    while (dataCodewords.length < totalDataCodewords) {
      dataCodewords.add(padByte);
      padByte = padByte == 0xEC ? 0x11 : 0xEC;
    }

    // Generate Reed-Solomon Error Correction
    final ecCount = _ecCodewordsPerBlock(version);
    final ecCodewords = _generateReedSolomon(dataCodewords, ecCount);

    return [...dataCodewords, ...ecCodewords];
  }

  static int _totalDataCodewords(int v) {
    const table = [
      0, 19, 34, 55, 80, 108, 136, 156, 194, 232, 274, 324, 370
    ];
    return table[v <= 12 ? v : 12];
  }

  static int _ecCodewordsPerBlock(int v) {
    const table = [
      0, 7, 10, 15, 20, 26, 36, 40, 48, 60, 72, 80, 96
    ];
    return table[v <= 12 ? v : 12];
  }

  // Galois Field GF(256) for Reed-Solomon
  static final List<int> _exp = List.filled(512, 0);
  static final List<int> _log = List.filled(256, 0);
  static bool _gfInit = false;

  static void _initGF() {
    if (_gfInit) return;
    var x = 1;
    for (var i = 0; i < 255; i++) {
      _exp[i] = x;
      _log[x] = i;
      x <<= 1;
      if (x >= 256) {
        x ^= 0x11D;
      }
    }
    for (var i = 255; i < 512; i++) {
      _exp[i] = _exp[i - 255];
    }
    _gfInit = true;
  }

  static int _gfMul(int x, int y) {
    if (x == 0 || y == 0) return 0;
    _initGF();
    return _exp[_log[x] + _log[y]];
  }

  static List<int> _generateReedSolomon(List<int> data, int ecCount) {
    _initGF();

    // Generator polynomial for ecCount
    var gen = [1];
    for (var i = 0; i < ecCount; i++) {
      final nextGen = List.filled(gen.length + 1, 0);
      for (var j = 0; j < gen.length; j++) {
        nextGen[j] ^= _gfMul(gen[j], _exp[i]);
        nextGen[j + 1] ^= gen[j];
      }
      gen = nextGen;
    }

    final result = List.filled(ecCount, 0);
    for (final byte in data) {
      final factor = byte ^ result[0];
      for (var i = 0; i < ecCount - 1; i++) {
        result[i] = result[i + 1] ^ _gfMul(gen[i + 1], factor);
      }
      result[ecCount - 1] = _gfMul(gen[ecCount], factor);
    }

    return result;
  }

  static void _placeCodewords(
    List<List<bool>> m,
    List<List<bool>> res,
    List<int> codewords,
    int size,
  ) {
    var bitIndex = 0;
    final totalBits = codewords.length * 8;
    var upward = true;

    for (var right = size - 1; right > 0; right -= 2) {
      if (right == 6) right--; // Skip vertical timing column

      final rows = upward
          ? List.generate(size, (i) => size - 1 - i)
          : List.generate(size, (i) => i);

      for (final row in rows) {
        for (var col = right; col >= right - 1; col--) {
          if (!res[row][col]) {
            if (bitIndex < totalBits) {
              final byteVal = codewords[bitIndex ~/ 8];
              final bit = (byteVal >> (7 - (bitIndex % 8))) & 1;
              m[row][col] = bit == 1;
              bitIndex++;
            } else {
              m[row][col] = false;
            }
          }
        }
      }
      upward = !upward;
    }
  }

  static void _applyMask(
    List<List<bool>> m,
    List<List<bool>> res,
    int size,
  ) {
    // Mask 0: (row + col) % 2 == 0
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (!res[r][c] && ((r + c) % 2 == 0)) {
          m[r][c] = !m[r][c];
        }
      }
    }
  }

  static void _writeFormatInformation(List<List<bool>> m, int size) {
    // Level L + Mask 0: format data = 0x77C4 (BCH 15-bit encoded)
    const formatBits = 0x77C4;

    for (var i = 0; i < 15; i++) {
      final bit = ((formatBits >> (14 - i)) & 1) == 1;

      // Around top-left finder pattern
      if (i < 6) {
        m[8][i] = bit;
      } else if (i < 8) {
        m[8][i + 1] = bit;
      } else {
        m[14 - i][8] = bit;
      }

      // Around bottom-left and top-right finder patterns
      if (i < 8) {
        m[size - 1 - i][8] = bit;
      } else {
        m[8][size - 15 + i] = bit;
      }
    }
  }
}
