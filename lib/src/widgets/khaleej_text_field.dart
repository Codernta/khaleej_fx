import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../banking/iban_validator.dart';
import '../cards/card_validator.dart';
import '../core/gcc_country.dart';
import '../identity/bahrain_cpr.dart';
import '../identity/emirates_id.dart';
import '../identity/kuwait_civil_id.dart';
import '../identity/oman_civil_id.dart';
import '../identity/qatar_id.dart';
import '../identity/saudi_id.dart';
import 'formatters.dart';

/// Semantic input types supported by [KhaleejTextField].
enum KhaleejInputType {
  /// Saudi National ID / Iqama (10 digits).
  saudiId,

  /// UAE Emirates ID (15 digits formatted 784-YYYY-XXXXXXX-C).
  emiratesId,

  /// Kuwait Civil ID (12 digits PACI).
  kuwaitCivilId,

  /// Qatar ID (11 digits QID).
  qatarId,

  /// Bahrain CPR (9 digits).
  bahrainCpr,

  /// Oman Civil ID (8 digits).
  omanCivilId,

  /// GCC International Bank Account Number (IBAN).
  iban,

  /// Payment Card Primary Account Number (PAN).
  cardNumber,

  /// Card Security Code (CVV / CVC).
  cvv,

  /// GCC Mobile Phone Number.
  phone,

  /// Monetary Amount.
  amount,

  /// Sensitive Secret (PIN, Password, OTP).
  sensitiveSecret,

  /// General unconstrained text.
  text,
}

/// A hardened, production-ready form text field engineered for GCC fintech applications.
///
/// Security Hardening:
/// - Anti-keylogging protection (`autocorrect: false`, `enableSuggestions: false`).
/// - Optional anti-clipboard guard (`disableClipboard: true`) prevents pasting or copying sensitive credentials.
/// - Obscure text toggle for PINs, CVVs, and passwords.
/// - Built-in input formatters for GCC IDs, IBANs, and cards.
/// - Country selector prefix dropdown with official GCC flags.
class KhaleejTextField extends StatefulWidget {
  const KhaleejTextField({
    super.key,
    this.controller,
    this.inputType = KhaleejInputType.text,
    this.label,
    this.hint,
    this.helperText,
    this.selectedCountry = GccCountry.saudiArabia,
    this.onCountryChanged,
    this.showCountrySelector = false,
    this.disableClipboard,
    this.obscureText,
    this.showObscureToggle = false,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
  });

  final TextEditingController? controller;
  final KhaleejInputType inputType;
  final String? label;
  final String? hint;
  final String? helperText;
  final GccCountry selectedCountry;
  final ValueChanged<GccCountry>? onCountryChanged;
  final bool showCountrySelector;
  final bool? disableClipboard;
  final bool? obscureText;
  final bool showObscureToggle;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;

  @override
  State<KhaleejTextField> createState() => _KhaleejTextFieldState();
}

class _KhaleejTextFieldState extends State<KhaleejTextField> {
  late bool _obscured;
  late GccCountry _country;

  @override
  void initState() {
    super.initState();
    final isSensitive = widget.inputType == KhaleejInputType.sensitiveSecret ||
        widget.inputType == KhaleejInputType.cvv;
    _obscured = widget.obscureText ?? isSensitive;
    _country = widget.selectedCountry;
  }

  @override
  void didUpdateWidget(covariant KhaleejTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCountry != widget.selectedCountry) {
      _country = widget.selectedCountry;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboardType = _getKeyboardType();
    final effectiveFormatters = _getFormatters();

    Widget? countryPrefix;
    if (widget.showCountrySelector) {
      countryPrefix = DropdownButtonHideUnderline(
        child: DropdownButton<GccCountry>(
          value: _country,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          items: GccCountry.values.map((c) {
            return DropdownMenuItem<GccCountry>(
              value: c,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.flagEmoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(
                    widget.inputType == KhaleejInputType.phone
                        ? c.dialCode
                        : c.iso2,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: widget.enabled
              ? (val) {
                  if (val != null) {
                    setState(() => _country = val);
                    widget.onCountryChanged?.call(val);
                  }
                }
              : null,
        ),
      );
    }

    Widget? suffix;
    if (widget.showObscureToggle) {
      suffix = IconButton(
        icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    } else {
      suffix = widget.suffixIcon;
    }

    final inputDecoration = (widget.decoration ?? const InputDecoration()).copyWith(
      labelText: widget.label,
      hintText: widget.hint ?? _getDefaultHint(),
      helperText: widget.helperText,
      prefixIcon: widget.prefixIcon ?? (countryPrefix != null ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: countryPrefix,
      ) : null),
      suffixIcon: suffix,
    );

    final isSensitive = widget.inputType == KhaleejInputType.sensitiveSecret ||
        widget.inputType == KhaleejInputType.cvv;
    final effectiveDisableClipboard = widget.disableClipboard ?? isSensitive;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      keyboardType: effectiveKeyboardType,
      inputFormatters: effectiveFormatters,

      // Security hardening flags
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: !effectiveDisableClipboard,
      contextMenuBuilder: effectiveDisableClipboard
          ? (context, editableTextState) => const SizedBox.shrink()
          : null,

      validator: widget.validator ?? _defaultValidator,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      decoration: inputDecoration,
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.inputType) {
      case KhaleejInputType.saudiId:
      case KhaleejInputType.emiratesId:
      case KhaleejInputType.kuwaitCivilId:
      case KhaleejInputType.qatarId:
      case KhaleejInputType.bahrainCpr:
      case KhaleejInputType.omanCivilId:
      case KhaleejInputType.cardNumber:
      case KhaleejInputType.cvv:
      case KhaleejInputType.sensitiveSecret:
        return TextInputType.number;
      case KhaleejInputType.phone:
        return TextInputType.phone;
      case KhaleejInputType.amount:
        return const TextInputType.numberWithOptions(decimal: true);
      case KhaleejInputType.iban:
      case KhaleejInputType.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getFormatters() {
    final list = <TextInputFormatter>[];

    switch (widget.inputType) {
      case KhaleejInputType.emiratesId:
        list.add(EmiratesIdInputFormatter());
      case KhaleejInputType.saudiId:
        list.add(SaudiIdInputFormatter());
      case KhaleejInputType.kuwaitCivilId:
        list.add(KuwaitCivilIdInputFormatter());
      case KhaleejInputType.qatarId:
        list.add(FilteringTextInputFormatter.digitsOnly);
        list.add(LengthLimitingTextInputFormatter(11));
      case KhaleejInputType.bahrainCpr:
        list.add(FilteringTextInputFormatter.digitsOnly);
        list.add(LengthLimitingTextInputFormatter(9));
      case KhaleejInputType.omanCivilId:
        list.add(FilteringTextInputFormatter.digitsOnly);
        list.add(LengthLimitingTextInputFormatter(8));
      case KhaleejInputType.iban:
        list.add(GccIbanInputFormatter());
      case KhaleejInputType.cardNumber:
        list.add(CardNumberInputFormatter());
      case KhaleejInputType.cvv:
        list.add(FilteringTextInputFormatter.digitsOnly);
        list.add(LengthLimitingTextInputFormatter(4));
      case KhaleejInputType.phone:
        list.add(FilteringTextInputFormatter.allow(RegExp(r'[\d\s+-]')));
      case KhaleejInputType.amount:
        list.add(FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')));
      case KhaleejInputType.sensitiveSecret:
      case KhaleejInputType.text:
        break;
    }

    return list;
  }

  String? _getDefaultHint() {
    switch (widget.inputType) {
      case KhaleejInputType.emiratesId:
        return '784-1990-1234567-1';
      case KhaleejInputType.saudiId:
        return '10XXXXXXXX or 20XXXXXXXX';
      case KhaleejInputType.kuwaitCivilId:
        return '290010101234';
      case KhaleejInputType.qatarId:
        return '29063401234';
      case KhaleejInputType.bahrainCpr:
        return '900101234';
      case KhaleejInputType.omanCivilId:
        return '12345678';
      case KhaleejInputType.iban:
        return 'SA03 8000 0000 6080 1016 7519';
      case KhaleejInputType.cardNumber:
        return '4176 3300 0000 1234';
      case KhaleejInputType.cvv:
        return '123';
      case KhaleejInputType.phone:
        return '50 123 4567';
      case KhaleejInputType.amount:
        return '0.00';
      case KhaleejInputType.sensitiveSecret:
      case KhaleejInputType.text:
        return null;
    }
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final text = value.trim();

    switch (widget.inputType) {
      case KhaleejInputType.saudiId:
        final res = SaudiId.parse(text);
        return res.isValid ? null : (res.validationError ?? 'Invalid Saudi ID');
      case KhaleejInputType.emiratesId:
        final res = EmiratesId.parse(text);
        return res.isValid ? null : (res.validationError ?? 'Invalid Emirates ID');
      case KhaleejInputType.kuwaitCivilId:
        final res = KuwaitCivilId.parse(text);
        return res.isValid ? null : (res.validationError ?? 'Invalid Kuwait Civil ID');
      case KhaleejInputType.qatarId:
        final res = QatarId.parse(text);
        return res.isValid ? null : (res.validationError ?? 'Invalid Qatar ID');
      case KhaleejInputType.bahrainCpr:
        final res = BahrainCpr.parse(text);
        return res.isValid ? null : (res.validationError ?? 'Invalid Bahrain CPR');
      case KhaleejInputType.omanCivilId:
        final res = OmanCivilId.parse(text);
        return res.isValid ? null : (res.validationError ?? 'Invalid Oman Civil ID');
      case KhaleejInputType.iban:
        final res = IbanValidator.validate(text);
        return res.isValid ? null : (res.errorMessage ?? 'Invalid GCC IBAN');
      case KhaleejInputType.cardNumber:
        final res = CardValidator.validate(text);
        return res.isValid ? null : (res.errorMessage ?? 'Invalid Card Number');
      case KhaleejInputType.cvv:
        return (text.length >= 3 && text.length <= 4) ? null : 'CVV must be 3 or 4 digits';
      default:
        return null;
    }
  }
}
