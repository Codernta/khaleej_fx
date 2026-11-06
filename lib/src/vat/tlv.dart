import 'dart:convert';
import 'dart:typed_data';

/// A single Tag-Length-Value (TLV) data unit.
class TlvItem {
  const TlvItem({
    required this.tag,
    required this.value,
  });

  /// Creates a [TlvItem] containing UTF-8 encoded text.
  factory TlvItem.fromText(int tag, String text) {
    return TlvItem(
      tag: tag,
      value: Uint8List.fromList(utf8.encode(text)),
    );
  }

  /// Creates a [TlvItem] containing raw bytes.
  factory TlvItem.fromBytes(int tag, List<int> bytes) {
    return TlvItem(
      tag: tag,
      value: Uint8List.fromList(bytes),
    );
  }

  /// Tag identifier (1..255).
  final int tag;

  /// Byte payload.
  final Uint8List value;

  /// Length of payload in bytes.
  int get length => value.length;

  /// Decodes payload as UTF-8 string.
  String get valueAsText => utf8.decode(value);

  @override
  String toString() => 'TlvItem(tag: $tag, len: $length, val: $valueAsText)';
}

/// Zero-dependency Tag-Length-Value (TLV) byte encoder and decoder
/// adhering to Saudi ZATCA e-Invoicing (FATOORAH) technical specifications.
class TlvCodec {
  const TlvCodec._();

  /// Encodes a list of [TlvItem] entries into a binary [Uint8List].
  static Uint8List encode(List<TlvItem> items) {
    final buffer = BytesBuilder();

    for (final item in items) {
      // 1. Tag (1 byte)
      buffer.addByte(item.tag);

      // 2. Length (standard ZATCA 1-byte length, or multi-byte if > 255)
      final len = item.value.length;
      if (len <= 255) {
        buffer.addByte(len);
      } else {
        // Extended length (BER/DER style): 0x82 followed by 2 length bytes
        buffer.addByte(0x82);
        buffer.addByte((len >> 8) & 0xFF);
        buffer.addByte(len & 0xFF);
      }

      // 3. Value bytes
      buffer.add(item.value);
    }

    return buffer.toBytes();
  }

  /// Decodes a binary [Uint8List] into a list of [TlvItem] entries.
  static List<TlvItem> decode(Uint8List bytes) {
    final items = <TlvItem>[];
    var offset = 0;

    while (offset < bytes.length) {
      if (offset + 2 > bytes.length) {
        throw FormatException('Unexpected EOF while reading TLV header at offset $offset');
      }

      final tag = bytes[offset++];
      var len = bytes[offset++];

      if (len == 0x82) {
        // Multi-byte length
        if (offset + 2 > bytes.length) {
          throw FormatException('Unexpected EOF reading multi-byte length at offset $offset');
        }
        final b1 = bytes[offset++];
        final b2 = bytes[offset++];
        len = (b1 << 8) | b2;
      }

      if (offset + len > bytes.length) {
        throw FormatException(
          'TLV payload truncated for tag $tag: expected $len bytes, available ${bytes.length - offset}',
        );
      }

      final val = bytes.sublist(offset, offset + len);
      offset += len;

      items.add(TlvItem(tag: tag, value: val));
    }

    return items;
  }
}
