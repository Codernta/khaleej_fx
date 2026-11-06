/// Arabic text normalization and Tashkeel (diacritics) stripping utility.
class ArabicNormalizer {
  const ArabicNormalizer._();

  // Unicode ranges for Tashkeel / Harakat
  // Fathatan (064B), Dammatan (064C), Kasratan (064D), Fatha (064E), Damma (064F),
  // Kasra (0650), Shadda (0651), Sukun (0652), Maddah (0653), Hamza Above (0654), etc.
  static final RegExp _tashkeelRegex = RegExp(r'[\u064B-\u065F\u0670]');

  // Tatweel / Kashida (ـ)
  static final RegExp _tatweelRegex = RegExp(r'\u0640');

  // Alef variants: أ (0623), إ (0625), آ (0622), ٱ (0671)
  static final RegExp _alefRegex = RegExp(r'[إأآٱ]');

  // Alif Maqsura: ى (0649)
  static final RegExp _alifMaqsuraRegex = RegExp(r'ى');

  // Taa Marbuta: ة (0629)
  static final RegExp _taaMarbutaRegex = RegExp(r'ة');

  /// Strips all Arabic Tashkeel / diacritics (Harakat) from [input].
  static String stripTashkeel(String input) {
    return input.replaceAll(_tashkeelRegex, '');
  }

  /// Strips Arabic Tatweel / Kashida (elongation character `ـ`) from [input].
  static String stripTatweel(String input) {
    return input.replaceAll(_tatweelRegex, '');
  }

  /// Normalizes Arabic text for consistent search, indexing, and matching.
  ///
  /// Transformations:
  /// - Strips Tashkeel diacritics.
  /// - Strips Tatweel (ـ).
  /// - Replaces `أ`, `إ`, `آ`, `ٱ` with plain `ا`.
  /// - Replaces `ى` (Alif Maqsura) with `ي` (Yaa).
  /// - Optionally replaces `ة` (Taa Marbuta) with `ه` (Haa) if [normalizeTaaMarbuta] is true.
  static String normalize(
    String input, {
    bool normalizeAlef = true,
    bool normalizeYaa = true,
    bool normalizeTaaMarbuta = true,
    bool removeTashkeel = true,
    bool removeTatweel = true,
  }) {
    var result = input;

    if (removeTashkeel) {
      result = stripTashkeel(result);
    }

    if (removeTatweel) {
      result = stripTatweel(result);
    }

    if (normalizeAlef) {
      result = result.replaceAll(_alefRegex, 'ا');
    }

    if (normalizeYaa) {
      result = result.replaceAll(_alifMaqsuraRegex, 'ي');
    }

    if (normalizeTaaMarbuta) {
      result = result.replaceAll(_taaMarbutaRegex, 'ه');
    }

    return result;
  }
}
