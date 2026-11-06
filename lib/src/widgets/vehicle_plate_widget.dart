import 'package:flutter/material.dart';
import '../core/gcc_country.dart';
import '../utils/numeral_converter.dart';

/// Style / registration classification of a vehicle plate.
enum GccPlateType {
  /// Private passenger vehicle (white background).
  privateVehicle,

  /// Commercial transport / truck (blue or yellow strip).
  commercial,

  /// Public Taxi.
  taxi,

  /// Diplomatic Corps.
  diplomatic,
}

/// Bilingual GCC vehicle registration plate widget supporting Saudi Arabia and UAE layouts.
///
/// Realistic metallic embossed styling with dual Arabic / Latin typography,
/// authentic regional layouts, and mounting bolt holes.
class GccVehiclePlateWidget extends StatelessWidget {
  const GccVehiclePlateWidget.saudi({
    super.key,
    required this.digits,
    required this.lettersAr,
    required this.lettersEn,
    this.plateType = GccPlateType.privateVehicle,
    this.width = 320,
    this.height = 110,
  })  : country = GccCountry.saudiArabia,
        uaeEmirate = null,
        uaePlateCode = null;

  const GccVehiclePlateWidget.uae({
    super.key,
    required this.digits,
    this.uaeEmirate = 'DUBAI',
    this.uaePlateCode = 'A',
    this.plateType = GccPlateType.privateVehicle,
    this.width = 320,
    this.height = 110,
  })  : country = GccCountry.uae,
        lettersAr = null,
        lettersEn = null;

  final GccCountry country;
  final String digits;
  final String? lettersAr;
  final String? lettersEn;
  final String? uaeEmirate;
  final String? uaePlateCode;
  final GccPlateType plateType;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 3.5),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDFDFD),
            Color(0xFFF1F1F1),
            Color(0xFFE8E8E8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Bolt holes
          _boltHole(left: 8, top: 8),
          _boltHole(right: 8, top: 8),
          _boltHole(left: 8, bottom: 8),
          _boltHole(right: 8, bottom: 8),

          // Plate Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: country == GccCountry.saudiArabia
                ? _buildSaudiPlate()
                : _buildUaePlate(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaudiPlate() {
    final arabicDigits = NumeralConverter.toArabicIndic(digits);

    return Row(
      children: [
        // Numbers column (Arabic Indic on top, Western Arabic on bottom)
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    arabicDigits,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.black,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: double.infinity,
                height: 1.5,
                child: ColoredBox(color: Colors.black54),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    digits,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 16, thickness: 2, color: Colors.black87),

        // Letters column (Arabic on top, English on bottom)
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    lettersAr ?? 'أ ب ج',
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: double.infinity,
                height: 1.5,
                child: ColoredBox(color: Colors.black54),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    lettersEn ?? 'A B J',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 16, thickness: 2, color: Colors.black87),

        // Saudi National Emblem strip (Right side)
        SizedBox(
          width: 52,
          child: Container(
            decoration: BoxDecoration(
              color: plateType == GccPlateType.commercial
                  ? Colors.blue.shade800
                  : (plateType == GccPlateType.taxi ? Colors.amber.shade700 : Colors.transparent),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, size: 20, color: Color(0xFF006C35)),
                SizedBox(height: 2),
                Text(
                  'KSA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'السعودية',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUaePlate() {
    return Row(
      children: [
        // Emirate Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                uaeEmirate ?? 'DUBAI',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'دبي',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Plate Code (e.g. A, B, 1, 2)
        if (uaePlateCode != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              uaePlateCode!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

        const SizedBox(width: 16),

        // Plate Number
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              digits,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _boltHole({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black38, width: 1),
        ),
      ),
    );
  }
}
