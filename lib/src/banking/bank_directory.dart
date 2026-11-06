import '../core/gcc_country.dart';
import 'bank_info.dart';

/// Comprehensive directory of commercial and Islamic banks across the 6 GCC member states.
class BankDirectory {
  const BankDirectory._();

  static const List<BankInfo> banks = [
    // --- Saudi Arabia (Bank code: 2 numeric digits) ---
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '10',
      shortName: 'SNB',
      nameEn: 'The Saudi National Bank',
      nameAr: 'البنك الأهلي السعودي',
      bic: 'NCBKSAJE',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '80',
      shortName: 'Al Rajhi',
      nameEn: 'Al Rajhi Bank',
      nameAr: 'مصرف الراجحي',
      bic: 'RJHISARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '20',
      shortName: 'Riyad Bank',
      nameEn: 'Riyad Bank',
      nameAr: 'بنك الرياض',
      bic: 'RIYDSARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '05',
      shortName: 'Alinma',
      nameEn: 'Alinma Bank',
      nameAr: 'مصرف الإنماء',
      bic: 'INMASARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '55',
      shortName: 'BSF',
      nameEn: 'Banque Saudi Fransi',
      nameAr: 'البنك السعودي الفرنسي',
      bic: 'BSFRSARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '40',
      shortName: 'ANB',
      nameEn: 'Arab National Bank',
      nameAr: 'البنك العربي الوطني',
      bic: 'ARBNSARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '45',
      shortName: 'SAB',
      nameEn: 'Saudi Awwal Bank',
      nameAr: 'البنك السعودي الأول',
      bic: 'SABBSARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '15',
      shortName: 'Albilad',
      nameEn: 'Bank Albilad',
      nameAr: 'بنك البلاد',
      bic: 'ALBISARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '65',
      shortName: 'AlJazira',
      nameEn: 'Bank AlJazira',
      nameAr: 'بنك الجزيرة',
      bic: 'BJAZSARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '60',
      shortName: 'GIB',
      nameEn: 'Gulf International Bank Saudi Arabia',
      nameAr: 'بنك الخليج الدولي - السعودية',
      bic: 'GIBKSARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '50',
      shortName: 'Alawwal (Legacy)',
      nameEn: 'Alawwal Bank',
      nameAr: 'البنك الأول',
      bic: 'AAALSARI',
    ),
    BankInfo(
      country: GccCountry.saudiArabia,
      bankCode: '76',
      shortName: 'D360',
      nameEn: 'D360 Bank',
      nameAr: 'بنك D360',
      bic: 'DTHRSARI',
    ),

    // --- United Arab Emirates (Bank code: 3 numeric digits) ---
    BankInfo(
      country: GccCountry.uae,
      bankCode: '035',
      shortName: 'FAB',
      nameEn: 'First Abu Dhabi Bank',
      nameAr: 'بنك أبوظبي الأول',
      bic: 'NBADAEAA',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '023',
      shortName: 'ENBD',
      nameEn: 'Emirates NBD',
      nameAr: 'بنك الإمارات دبي الوطني',
      bic: 'EBILAEAD',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '003',
      shortName: 'ADCB',
      nameEn: 'Abu Dhabi Commercial Bank',
      nameAr: 'بنك أبوظبي التجاري',
      bic: 'ADCBAEAA',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '024',
      shortName: 'DIB',
      nameEn: 'Dubai Islamic Bank',
      nameAr: 'بنك دبي الإسلامي',
      bic: 'DUBIAEAA',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '033',
      shortName: 'Mashreq',
      nameEn: 'Mashreq Bank',
      nameAr: 'بنك المشرق',
      bic: 'BOMLAEAD',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '025',
      shortName: 'CBD',
      nameEn: 'Commercial Bank of Dubai',
      nameAr: 'بنك دبي التجاري',
      bic: 'CBDUAEAD',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '040',
      shortName: 'RAKBANK',
      nameEn: 'National Bank of Ras Al Khaimah (RAKBANK)',
      nameAr: 'بنك رأس الخيمة الوطني',
      bic: 'NBRKAEAA',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '046',
      shortName: 'SIB',
      nameEn: 'Sharjah Islamic Bank',
      nameAr: 'مصرف الشارقة الإسلامي',
      bic: 'SHJBAEAA',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '012',
      shortName: 'ADIB',
      nameEn: 'Abu Dhabi Islamic Bank',
      nameAr: 'مصرف أبوظبي الإسلامي',
      bic: 'ADIBAEAA',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '026',
      shortName: 'EI',
      nameEn: 'Emirates Islamic Bank',
      nameAr: 'الإمارات الإسلامي',
      bic: 'MEBIAEAA',
    ),
    BankInfo(
      country: GccCountry.uae,
      bankCode: '086',
      shortName: 'Wio',
      nameEn: 'Wio Bank',
      nameAr: 'بنك ويو',
      bic: 'WIOBAEAA',
    ),

    // --- State of Kuwait (Bank code: 4 alpha characters) ---
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'NBOK',
      shortName: 'NBK',
      nameEn: 'National Bank of Kuwait',
      nameAr: 'بنك الكويت الوطني',
      bic: 'NBOKKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'KFHX',
      shortName: 'KFH',
      nameEn: 'Kuwait Finance House',
      nameAr: 'بيت التمويل الكويتي (بيتك)',
      bic: 'KFHXKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'BURG',
      shortName: 'Burgan',
      nameEn: 'Burgan Bank',
      nameAr: 'بنك برقان',
      bic: 'BURGKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'GULB',
      shortName: 'Gulf Bank',
      nameEn: 'Gulf Bank',
      nameAr: 'بنك الخليج',
      bic: 'GULBKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'BOUK',
      shortName: 'Boubyan',
      nameEn: 'Boubyan Bank',
      nameAr: 'بنك بوبيان',
      bic: 'BOUKKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'CBKU',
      shortName: 'CBK',
      nameEn: 'Commercial Bank of Kuwait',
      nameAr: 'البنك التجاري الكويتي',
      bic: 'CBKUKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'ABKK',
      shortName: 'ABK',
      nameEn: 'Al Ahli Bank of Kuwait',
      nameAr: 'البنك الأهلي الكويتي',
      bic: 'ABKKKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'WARB',
      shortName: 'Warba',
      nameEn: 'Warba Bank',
      nameAr: 'بنك وربة',
      bic: 'WARBKWKW',
    ),
    BankInfo(
      country: GccCountry.kuwait,
      bankCode: 'AUBK',
      shortName: 'AUB Kuwait',
      nameEn: 'Ahli United Bank Kuwait',
      nameAr: 'البنك الأهلي المتحد - الكويت',
      bic: 'AUBKKWKW',
    ),

    // --- State of Qatar (Bank code: 4 alpha characters) ---
    BankInfo(
      country: GccCountry.qatar,
      bankCode: 'QNBA',
      shortName: 'QNB',
      nameEn: 'Qatar National Bank',
      nameAr: 'بنك قطر الوطني',
      bic: 'QNBAQAQA',
    ),
    BankInfo(
      country: GccCountry.qatar,
      bankCode: 'CBQA',
      shortName: 'CBQ',
      nameEn: 'Commercial Bank of Qatar',
      nameAr: 'البنك التجاري',
      bic: 'CBQAQAQA',
    ),
    BankInfo(
      country: GccCountry.qatar,
      bankCode: 'QISB',
      shortName: 'QIB',
      nameEn: 'Qatar Islamic Bank',
      nameAr: 'مصرف قطر الإسلامي',
      bic: 'QISBQAQA',
    ),
    BankInfo(
      country: GccCountry.qatar,
      bankCode: 'DOHB',
      shortName: 'Doha Bank',
      nameEn: 'Doha Bank',
      nameAr: 'بنك الدوحة',
      bic: 'DOHBQAQA',
    ),
    BankInfo(
      country: GccCountry.qatar,
      bankCode: 'RAYN',
      shortName: 'Al Rayan',
      nameEn: 'Masraf Al Rayan',
      nameAr: 'مصرف الريان',
      bic: 'RAYNQAQA',
    ),
    BankInfo(
      country: GccCountry.qatar,
      bankCode: 'BARQ',
      shortName: 'Dukhan',
      nameEn: 'Dukhan Bank',
      nameAr: 'بنك دخان',
      bic: 'BARQQAQA',
    ),
    BankInfo(
      country: GccCountry.qatar,
      bankCode: 'QIIB',
      shortName: 'QIIB',
      nameEn: 'Qatar International Islamic Bank',
      nameAr: 'بنك قطر الدولي الإسلامي',
      bic: 'QIIBQAQA',
    ),

    // --- Kingdom of Bahrain (Bank code: 4 alpha characters) ---
    BankInfo(
      country: GccCountry.bahrain,
      bankCode: 'NBOB',
      shortName: 'NBB',
      nameEn: 'National Bank of Bahrain',
      nameAr: 'بنك البحرين الوطني',
      bic: 'NBOBBHBM',
    ),
    BankInfo(
      country: GccCountry.bahrain,
      bankCode: 'BBKU',
      shortName: 'BBK',
      nameEn: 'Bank of Bahrain and Kuwait',
      nameAr: 'بنك البحرين والكويت',
      bic: 'BBKUBHBM',
    ),
    BankInfo(
      country: GccCountry.bahrain,
      bankCode: 'AUBB',
      shortName: 'AUB',
      nameEn: 'Ahli United Bank',
      nameAr: 'البنك الأهلي المتحد',
      bic: 'AUBBBHBM',
    ),
    BankInfo(
      country: GccCountry.bahrain,
      bankCode: 'BISB',
      shortName: 'BisB',
      nameEn: 'Bahrain Islamic Bank',
      nameAr: 'بنك البحرين الإسلامي',
      bic: 'BISBBHBM',
    ),
    BankInfo(
      country: GccCountry.bahrain,
      bankCode: 'BARK',
      shortName: 'Al Baraka',
      nameEn: 'Al Baraka Islamic Bank',
      nameAr: 'بنك البركة الإسلامي',
      bic: 'BARKBHBM',
    ),
    BankInfo(
      country: GccCountry.bahrain,
      bankCode: 'ITHB',
      shortName: 'Ithmaar',
      nameEn: 'Ithmaar Bank',
      nameAr: 'بنك إثمار',
      bic: 'ITHBBHBM',
    ),
    BankInfo(
      country: GccCountry.bahrain,
      bankCode: 'KHCB',
      shortName: 'Khaleeji',
      nameEn: 'Khaleeji Bank',
      nameAr: 'مصرف خليجي',
      bic: 'KHCBBHBM',
    ),

    // --- Sultanate of Oman (Bank code: 3 alpha/numeric or BIC prefix) ---
    BankInfo(
      country: GccCountry.oman,
      bankCode: 'BMU',
      shortName: 'Bank Muscat',
      nameEn: 'Bank Muscat',
      nameAr: 'بنك مسقط',
      bic: 'BMUSOMRX',
    ),
    BankInfo(
      country: GccCountry.oman,
      bankCode: 'BDO',
      shortName: 'Bank Dhofar',
      nameEn: 'Bank Dhofar',
      nameAr: 'بنك ظفار',
      bic: 'BDOFOMRX',
    ),
    BankInfo(
      country: GccCountry.oman,
      bankCode: 'NBO',
      shortName: 'NBO',
      nameEn: 'National Bank of Oman',
      nameAr: 'البنك الوطني العماني',
      bic: 'NBOOOMRX',
    ),
    BankInfo(
      country: GccCountry.oman,
      bankCode: 'BSR',
      shortName: 'Sohar',
      nameEn: 'Sohar International Bank',
      nameAr: 'صحار الدولي',
      bic: 'BSRBOMRX',
    ),
    BankInfo(
      country: GccCountry.oman,
      bankCode: 'NIZ',
      shortName: 'Nizwa',
      nameEn: 'Bank Nizwa',
      nameAr: 'بنك نزوى',
      bic: 'NIZWOMRX',
    ),
    BankInfo(
      country: GccCountry.oman,
      bankCode: 'OAB',
      shortName: 'OAB',
      nameEn: 'Oman Arab Bank',
      nameAr: 'بنك عمان العربي',
      bic: 'OABOOMRX',
    ),
    BankInfo(
      country: GccCountry.oman,
      bankCode: 'ALZ',
      shortName: 'Alizz',
      nameEn: 'Alizz Islamic Bank',
      nameAr: 'بنك العز الإسلامي',
      bic: 'ALIZOMRX',
    ),
  ];

  /// Finds [BankInfo] by bank code and country.
  static BankInfo? findBank(GccCountry country, String bankCode) {
    final clean = bankCode.trim().toUpperCase();
    for (final b in banks) {
      if (b.country == country && b.bankCode.toUpperCase() == clean) {
        return b;
      }
    }
    // Also try matching prefix
    for (final b in banks) {
      if (b.country == country &&
          (clean.startsWith(b.bankCode.toUpperCase()) ||
              b.bankCode.toUpperCase().startsWith(clean))) {
        return b;
      }
    }
    return null;
  }

  /// Finds [BankInfo] by BIC/SWIFT code.
  static BankInfo? findByBic(String bic) {
    final clean = bic.trim().toUpperCase();
    for (final b in banks) {
      if (b.bic == clean || clean.startsWith(b.bic.substring(0, 6))) {
        return b;
      }
    }
    return null;
  }
}
