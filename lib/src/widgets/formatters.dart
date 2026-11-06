import 'package:flutter/services.dart';

/// Formatter for Emirates ID: automatically produces `784-YYYY-XXXXXXX-C`.
class EmiratesIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 15; i++) {
      if (i == 3 || i == 7 || i == 14) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Saudi National ID or Iqama: limits to 10 digits and optional grouping.
class SaudiIdInputFormatter extends TextInputFormatter {
  SaudiIdInputFormatter({this.grouped = false});

  final bool grouped;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;

    if (!grouped || limited.length < 5) {
      return TextEditingValue(
        text: limited,
        selection: TextSelection.collapsed(offset: limited.length),
      );
    }

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 1 || i == 5) {
        buffer.write(' ');
      }
      buffer.write(limited[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formatter for GCC IBANs: uppercases characters and spaces in 4-character blocks.
class GccIbanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean =
        newValue.text.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final buffer = StringBuffer();

    for (var i = 0; i < clean.length && i < 34; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for payment card PAN: 4-4-4-4 grouping or 4-6-5 for Amex.
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 19 ? digits.substring(0, 19) : digits;

    final isAmex = limited.startsWith('34') || limited.startsWith('37');
    final buffer = StringBuffer();

    if (isAmex) {
      for (var i = 0; i < limited.length && i < 15; i++) {
        if (i == 4 || i == 10) {
          buffer.write(' ');
        }
        buffer.write(limited[i]);
      }
    } else {
      for (var i = 0; i < limited.length; i++) {
        if (i > 0 && i % 4 == 0) {
          buffer.write(' ');
        }
        buffer.write(limited[i]);
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Kuwait Civil ID (12 digits with grouping).
class KuwaitCivilIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 12 ? digits.substring(0, 12) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 1 || i == 7 || i == 11) {
        buffer.write(' ');
      }
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
