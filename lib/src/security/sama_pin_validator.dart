/// Specific reason for SAMA PIN policy violation.
enum WeakPinReason {
  /// PIN is too short or too long.
  invalidLength,

  /// PIN contains non-numeric characters.
  nonNumeric,

  /// PIN consists of repeating identical digits (e.g. `1111`, `0000`).
  repeatedDigits,

  /// PIN consists of sequential ascending or descending numbers (e.g. `1234`, `4321`).
  sequentialDigits,

  /// PIN consists of an alternating pattern (e.g. `1212`, `1010`).
  alternatingPattern,

  /// PIN matches or contains the user's birth year or birth date.
  containsBirthDate,

  /// PIN matches trailing digits of the user's National ID or Iqama.
  matchesNationalId,

  /// PIN matches trailing digits of the user's mobile phone number.
  matchesPhoneNumber,
}

/// Validation result produced by [SamaPinValidator].
class SamaPinValidationResult {
  const SamaPinValidationResult({
    required this.isValid,
    this.failureReasons = const [],
    this.messageEn,
    this.messageAr,
  });

  /// Whether the PIN satisfies all SAMA Cybersecurity Framework constraints.
  final bool isValid;

  /// List of specific failure reasons if invalid.
  final List<WeakPinReason> failureReasons;

  /// English regulatory explanation.
  final String? messageEn;

  /// Arabic regulatory explanation.
  final String? messageAr;

  @override
  String toString() =>
      'SamaPinValidationResult(valid: $isValid, reasons: $failureReasons)';
}

/// SAMA (Saudi Central Bank) Cybersecurity Framework PIN & Password Policy Validator.
///
/// Implements mandatory constraints for customer financial PINs, mobile banking MPINs,
/// and debit card ATM PINs to mitigate brute-force and dictionary attacks:
/// - Rejects repeating digits (e.g. `1111`, `0000`).
/// - Rejects sequential digits (forward: `1234`, `5678`, backward: `4321`, `8765`).
/// - Rejects alternating repeating patterns (e.g. `1212`, `1010`).
/// - Rejects personal identity correlation (birth year, birth date, national ID, mobile phone).
class SamaPinValidator {
  const SamaPinValidator._();

  /// Validates a financial PIN against SAMA Cybersecurity Framework constraints.
  ///
  /// Parameters:
  /// - [pin]: The PIN to validate (typically 4 or 6 digits).
  /// - [allowedLengths]: Set of permissible lengths (defaults to `{4, 6}`).
  /// - [birthYear]: Optional user birth year (e.g. `1990`) to prevent obvious PINs.
  /// - [birthDateMonthDay]: Optional 4-digit MMDD or DDMM string (e.g. `1505` or `0515`).
  /// - [nationalIdOrIqama]: Optional 10-digit Saudi ID/Iqama to check trailing correlation.
  /// - [phoneNumber]: Optional mobile phone number to check trailing correlation.
  static SamaPinValidationResult validate({
    required String pin,
    Set<int> allowedLengths = const {4, 6},
    int? birthYear,
    String? birthDateMonthDay,
    String? nationalIdOrIqama,
    String? phoneNumber,
  }) {
    final cleanPin = pin.trim();
    final reasons = <WeakPinReason>[];

    // 1. Numeric check
    if (!RegExp(r'^\d+$').hasMatch(cleanPin)) {
      reasons.add(WeakPinReason.nonNumeric);
      return const SamaPinValidationResult(
        isValid: false,
        failureReasons: [WeakPinReason.nonNumeric],
        messageEn: 'PIN must contain numeric digits only.',
        messageAr: 'يجب أن يحتوي رمز التعريف الشخصي على أرقام فقط.',
      );
    }

    // 2. Length check
    if (!allowedLengths.contains(cleanPin.length)) {
      reasons.add(WeakPinReason.invalidLength);
      final allowedStr = allowedLengths.join(' or ');
      return SamaPinValidationResult(
        isValid: false,
        failureReasons: reasons,
        messageEn: 'PIN length must be exactly $allowedStr digits.',
        messageAr: 'يجب أن يكون طول الرمز $allowedStr خانات بالضبط.',
      );
    }

    // 3. Repeated digits check (e.g. 1111, 0000)
    if (RegExp(r'^(\d)\1+$').hasMatch(cleanPin)) {
      reasons.add(WeakPinReason.repeatedDigits);
    }

    // 4. Sequential digits check (1234, 4321, 567890, etc.)
    if (_isSequential(cleanPin)) {
      reasons.add(WeakPinReason.sequentialDigits);
    }

    // 5. Alternating repeating pattern check (1212, 1010, 123123)
    if (_isAlternating(cleanPin)) {
      reasons.add(WeakPinReason.alternatingPattern);
    }

    // 6. Birth year check
    if (birthYear != null) {
      final yStr = birthYear.toString();
      final y2Str = yStr.length >= 2 ? yStr.substring(yStr.length - 2) : '';
      if (cleanPin.contains(yStr) ||
          (cleanPin.length == 4 && (cleanPin.startsWith(y2Str) || cleanPin.endsWith(y2Str)))) {
        reasons.add(WeakPinReason.containsBirthDate);
      }
    }

    // 7. Birth date check (MMDD or DDMM)
    if (birthDateMonthDay != null) {
      final cleanDate = birthDateMonthDay.replaceAll(RegExp(r'\D'), '');
      if (cleanDate.isNotEmpty && cleanPin.contains(cleanDate)) {
        if (!reasons.contains(WeakPinReason.containsBirthDate)) {
          reasons.add(WeakPinReason.containsBirthDate);
        }
      }
    }

    // 8. National ID correlation (last 4 or 6 digits)
    if (nationalIdOrIqama != null) {
      final cleanId = nationalIdOrIqama.replaceAll(RegExp(r'\D'), '');
      if (cleanId.length >= cleanPin.length) {
        final idSuffix = cleanId.substring(cleanId.length - cleanPin.length);
        if (cleanPin == idSuffix) {
          reasons.add(WeakPinReason.matchesNationalId);
        }
      }
    }

    // 9. Phone number correlation (last 4 digits)
    if (phoneNumber != null) {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length >= cleanPin.length) {
        final phoneSuffix = cleanPhone.substring(cleanPhone.length - cleanPin.length);
        if (cleanPin == phoneSuffix) {
          reasons.add(WeakPinReason.matchesPhoneNumber);
        }
      }
    }

    if (reasons.isNotEmpty) {
      return SamaPinValidationResult(
        isValid: false,
        failureReasons: reasons,
        messageEn: _buildMessageEn(reasons),
        messageAr: _buildMessageAr(reasons),
      );
    }

    return const SamaPinValidationResult(
      isValid: true,
      failureReasons: [],
      messageEn: 'PIN satisfies SAMA Cybersecurity constraints.',
      messageAr: 'الرمز متوافق مع معايير البنك المركزي السعودي للأمن السيبراني.',
    );
  }

  static bool _isSequential(String pin) {
    if (pin.length < 3) return false;
    bool ascending = true;
    bool descending = true;

    for (int i = 0; i < pin.length - 1; i++) {
      final curr = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);

      if ((curr + 1) % 10 != next) {
        ascending = false;
      }
      if ((curr - 1 + 10) % 10 != next) {
        descending = false;
      }
    }

    return ascending || descending;
  }

  static bool _isAlternating(String pin) {
    if (pin.length == 4) {
      // 1212
      return pin[0] == pin[2] && pin[1] == pin[3] && pin[0] != pin[1];
    }
    if (pin.length == 6) {
      // 121212
      final p1 = pin.substring(0, 2);
      if (pin == '$p1$p1$p1') return true;
      // 123123
      final p2 = pin.substring(0, 3);
      if (pin == '$p2$p2') return true;
    }
    return false;
  }

  static String _buildMessageEn(List<WeakPinReason> reasons) {
    if (reasons.contains(WeakPinReason.repeatedDigits)) {
      return 'PIN cannot consist of repeating identical digits.';
    }
    if (reasons.contains(WeakPinReason.sequentialDigits)) {
      return 'PIN cannot consist of sequential ascending or descending digits.';
    }
    if (reasons.contains(WeakPinReason.alternatingPattern)) {
      return 'PIN cannot consist of alternating repeating patterns.';
    }
    if (reasons.contains(WeakPinReason.containsBirthDate)) {
      return 'PIN cannot contain your birth year or birth date.';
    }
    if (reasons.contains(WeakPinReason.matchesNationalId)) {
      return 'PIN cannot match digits from your National ID or Iqama.';
    }
    if (reasons.contains(WeakPinReason.matchesPhoneNumber)) {
      return 'PIN cannot match digits from your mobile phone number.';
    }
    return 'PIN does not meet SAMA Cybersecurity policy standards.';
  }

  static String _buildMessageAr(List<WeakPinReason> reasons) {
    if (reasons.contains(WeakPinReason.repeatedDigits)) {
      return 'لا يمكن أن يتكون الرمز من أرقام متكررة متطابقة.';
    }
    if (reasons.contains(WeakPinReason.sequentialDigits)) {
      return 'لا يمكن أن يتكون الرمز من أرقام متسلسلة تصاعدياً أو تنازلياً.';
    }
    if (reasons.contains(WeakPinReason.alternatingPattern)) {
      return 'لا يمكن أن يتكون الرمز من أنماط متكررة متبادلة.';
    }
    if (reasons.contains(WeakPinReason.containsBirthDate)) {
      return 'لا يمكن أن يحتوي الرمز على سنة أو تاريخ ميلادك.';
    }
    if (reasons.contains(WeakPinReason.matchesNationalId)) {
      return 'لا يمكن أن يطابق الرمز أرقام الهوية الوطنية أو الإقامة الخاصة بك.';
    }
    if (reasons.contains(WeakPinReason.matchesPhoneNumber)) {
      return 'لا يمكن أن يطابق الرمز أرقام هاتفك الجوال.';
    }
    return 'الرمز لا يلبي متطلبات البنك المركزي السعودي للأمن السيبراني.';
  }
}
