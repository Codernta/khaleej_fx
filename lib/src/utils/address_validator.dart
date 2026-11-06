/// Address parsing and verification utility for GCC address standards:
/// - Saudi Post (SPL) Short Address & National Address
/// - UAE Makani 10-digit Smart Navigation Code
/// - Qatar Blue Plate (Zone, Street, Building)
class AddressValidator {
  const AddressValidator._();

  // SPL Short Address: 4 uppercase letters followed by 4 digits (e.g. RRRD2929)
  static final RegExp _splShortAddressPattern = RegExp(
    r'^[A-Z]{4}\d{4}$',
  );

  // UAE Makani Code: 10 digits (optionally separated by space or hyphen: XXXXX XXXXX)
  static final RegExp _makaniPattern = RegExp(
    r'^\d{5}[-\s]?\d{5}$',
  );

  /// Validates a Saudi Post (SPL) National Address Short Code (e.g. `RRRD2929`).
  static bool validateSplShortAddress(String code) {
    final clean = code.trim().toUpperCase();
    return _splShortAddressPattern.hasMatch(clean);
  }

  /// Formats an SPL Short Address into uppercase 8-character code.
  static String? formatSplShortAddress(String code) {
    final clean = code.trim().toUpperCase();
    if (_splShortAddressPattern.hasMatch(clean)) {
      return clean;
    }
    return null;
  }

  /// Validates a Saudi 5-digit postal code (الرمز البريدي).
  static bool validateSaudiPostalCode(String postalCode) {
    final clean = postalCode.trim();
    // Saudi postal codes are 5 digits starting with 1..8
    return RegExp(r'^[1-8]\d{4}$').hasMatch(clean);
  }

  /// Validates a Dubai / UAE 10-digit Makani Number (e.g. `30032 95320`).
  static bool validateUaeMakani(String makani) {
    final clean = makani.trim();
    return _makaniPattern.hasMatch(clean);
  }

  /// Formats a UAE Makani code into standard 5-5 grouped format (e.g. `30032 95320`).
  static String? formatUaeMakani(String makani) {
    final digits = makani.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return null;
    return '${digits.substring(0, 5)} ${digits.substring(5, 10)}';
  }

  /// Validates a Qatar Blue Plate address specification.
  ///
  /// Criteria:
  /// - [zone]: 1..99
  /// - [street]: 1..9999
  /// - [building]: 1..9999
  static bool validateQatarBluePlate({
    required int zone,
    required int street,
    required int building,
  }) {
    if (zone < 1 || zone > 99) return false;
    if (street < 1 || street > 9999) return false;
    if (building < 1 || building > 9999) return false;
    return true;
  }

  /// Parses a Qatar Blue Plate formatted string (e.g. `23/840/56` or `23-840-56`).
  static Map<String, int>? parseQatarBluePlate(String input) {
    final parts = input.trim().split(RegExp(r'[/-\s]+'));
    if (parts.length != 3) return null;

    final zone = int.tryParse(parts[0]);
    final street = int.tryParse(parts[1]);
    final building = int.tryParse(parts[2]);

    if (zone == null || street == null || building == null) return null;

    if (validateQatarBluePlate(zone: zone, street: street, building: building)) {
      return {'zone': zone, 'street': street, 'building': building};
    }
    return null;
  }
}
