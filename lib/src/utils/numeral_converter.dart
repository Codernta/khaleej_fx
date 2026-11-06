/// Bidirectional numeral converter between Arabic-Indic numerals (`٠١٢٣٤٥٦٧٨٩`)
/// and Western Arabic numerals (`0123456789`).
class NumeralConverter {
  const NumeralConverter._();

  static const Map<String, String> _westernToIndic = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  static const Map<String, String> _indicToWestern = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    // Persian / Urdu variants
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  /// Converts Western Arabic digits (`0-9`) in [input] to Arabic-Indic digits (`٠-٩`).
  ///
  /// Preserves all non-digit characters (letters, symbols, punctuation).
  /// If [convertSeparators] is true, converts `.` to Arabic decimal `٫` and `,` to `٬`.
  static String toArabicIndic(String input, {bool convertSeparators = false}) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (_westernToIndic.containsKey(char)) {
        buffer.write(_westernToIndic[char]);
      } else if (convertSeparators && char == '.') {
        buffer.write('٫');
      } else if (convertSeparators && char == ',') {
        buffer.write('٬');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Converts Arabic-Indic digits (`٠-٩`) in [input] to Western Arabic digits (`0-9`).
  ///
  /// If [convertSeparators] is true, converts Arabic decimal `٫` to `.` and `٬` to `,`.
  static String toWesternArabic(String input, {bool convertSeparators = false}) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (_indicToWestern.containsKey(char)) {
        buffer.write(_indicToWestern[char]);
      } else if (convertSeparators && char == '٫') {
        buffer.write('.');
      } else if (convertSeparators && char == '٬') {
        buffer.write(',');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
