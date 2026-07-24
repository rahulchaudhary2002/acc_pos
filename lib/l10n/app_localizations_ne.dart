// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'पोस';

  @override
  String get posHomeSelectCompanyLabel => 'कम्पनी छान्नुहोस्';

  @override
  String get posHomeBottomNavSellLabel => 'बिक्री';

  @override
  String get posHomeBottomNavBuyLabel => 'खरिद';

  @override
  String get posHomeBottomNavReportsLabel => 'रिपोर्ट';

  @override
  String get posHomeBottomNavOthersLabel => 'अन्य';

  @override
  String get sellScreenTitle => 'एलपीजी बिक्री';

  @override
  String get sellScreenSubtitle => 'विक्रेताहरूका लागि सजिलो POS';

  @override
  String get sellScreenSelectCustomerOrNameError =>
      'ग्राहक बिक्रीको लागि विद्यमान ग्राहक छान्नुहोस् वा पूरा नाम प्रविष्ट गर्नुहोस्।';

  @override
  String get sellScreenVatNumberLengthError =>
      'भ्याट नम्बर ठ्याक्कै ९ अंकको हुनुपर्छ।';

  @override
  String get sellScreenCashLimitExceededError =>
      'नगद बिक्री NPR २५,००० भन्दा बढी हुन सक्दैन। बढी रकमको लागि ग्राहक बिक्रीमा जानुहोस्।';

  @override
  String get sellScreenPhoneNumberFormatError =>
      'फोन नम्बर ठ्याक्कै १० अंकको हुनुपर्छ।';

  @override
  String get sellScreenOnlineReferenceRequiredError =>
      'अनलाइन भुक्तानीको लागि सन्दर्भ नं. आवश्यक छ।';

  @override
  String sellScreenReturnCompletedMessage(String documentNo, String total) {
    return 'फिर्ता $documentNo सम्पन्न भयो — NPR $total';
  }

  @override
  String get sellScreenCashSaleLabel => 'नगद बिक्री';

  @override
  String get sellScreenCashSaleSubtitle => 'NPR २५,००० सम्म';

  @override
  String get sellScreenCustomerSaleLabel => 'ग्राहक बिक्री';

  @override
  String get sellScreenCustomerSaleSubtitle => 'लिङ्क गरिएको खाता';

  @override
  String get sellScreenSalesReturnLabel => 'बिक्री फिर्ता';

  @override
  String get sellScreenSalesReturnSubtitle => 'वस्तु फिर्ता';

  @override
  String get sellScreenVendorLabel => 'विक्रेता';

  @override
  String get sellScreenSelectVendorHint => 'विक्रेता छान्नुहोस् (वैकल्पिक)';

  @override
  String get sellScreenVendorFooterHint =>
      'यो बिक्री कुन विक्रेतासँग सम्बन्धित छ भनी रेकर्ड गर्दछ।';

  @override
  String get sellScreenCurrentSaleTitle => 'हालको बिक्री';

  @override
  String get sellScreenNoItemsAddedTitle => 'अहिलेसम्म कुनै वस्तु थपिएको छैन';

  @override
  String get sellScreenNoItemsAddedSubtitle =>
      'उत्पादन थप्न तलको बटन क्लिक गर्नुहोस्';

  @override
  String get sellScreenAddProductsLabel => 'उत्पादन थप्नुहोस्';

  @override
  String get sellScreenAddMoreProductsLabel => 'थप उत्पादन थप्नुहोस्';

  @override
  String get sellScreenClearAllLabel => 'सबै हटाउनुहोस्';

  @override
  String get sellScreenGenerateVatBillLabel => 'भ्याट बिल बनाउनुहोस्';

  @override
  String get sellScreenCustomerOptionalLabel => 'ग्राहक (वैकल्पिक)';

  @override
  String get sellScreenWalkInNoCustomerLabel => 'वाक-इन / ग्राहक नभएको';

  @override
  String get sellScreenInvoiceNumberLabel => 'बिल नम्बर लेख्नुहोस्';

  @override
  String get sellScreenInvoiceNumberHint => 'जस्तै XXXX-001';

  @override
  String get sellScreenInvoiceLookupButton => 'खोज्नुहोस्';

  @override
  String get sellScreenInvoiceLookupLoading => 'बीजक खोजिँदैछ...';

  @override
  String get sellScreenInvoiceLookupNotFound =>
      'त्यो नम्बरको कुनै पोस्ट गरिएको बीजक भेटिएन।';

  @override
  String sellScreenInvoiceLookupFound(
    int count,
    String plural,
    String invoiceNo,
  ) {
    return 'बीजक $invoiceNo बाट $count वस्तु$plural लोड भयो';
  }

  @override
  String get sellScreenReturnItemsTitle => 'फिर्ता वस्तुहरू';

  @override
  String get sellScreenNoItemsSelectedTitle => 'कुनै वस्तु छानिएको छैन';

  @override
  String get sellScreenSelectProductsToReturnSubtitle =>
      'फिर्ता गर्ने उत्पादन छान्नुहोस्';

  @override
  String get sellScreenTotalReturnLabel => 'कुल फिर्ता';

  @override
  String get sellScreenClearReturnLabel => 'फिर्ता हटाउनुहोस्';

  @override
  String get sellScreenPostSalesReturnLabel => 'बिक्री फिर्ता पेश गर्नुहोस्';

  @override
  String get sellScreenCustomerInformationTitle => 'ग्राहक जानकारी';

  @override
  String get sellScreenExistingCustomerLabel => 'विद्यमान ग्राहक';

  @override
  String get sellScreenSelectCustomerLabel => 'ग्राहक छान्नुहोस्';

  @override
  String get sellScreenAutoCreateCustomerHelper =>
      'यसलाई खाली छाडेर तल विवरण भर्नुहोस्, बिल बनाउँदा नयाँ ग्राहक स्वतः सिर्जना हुनेछ।';

  @override
  String get sellScreenFullNameLabel => 'पूरा नाम';

  @override
  String get sellScreenPhoneNumberLabel => 'फोन नम्बर';

  @override
  String get sellScreenVatNumberLabel => 'भ्याट नम्बर';

  @override
  String get sellScreenDeliveryAddressLabel => 'डेलिभरी ठेगाना';

  @override
  String get buyScreenSelectVendorError =>
      'कृपया विक्रेता छान्नुहोस् वा नाम लेख्नुहोस्।';

  @override
  String get buyScreenSelectReturnSupplierError =>
      'कृपया फिर्ता गर्ने आपूर्तिकर्ता छान्नुहोस्।';

  @override
  String buyScreenReturnCompletedMessage(String documentNo, String total) {
    return 'फिर्ता $documentNo सम्पन्न भयो — NPR $total';
  }

  @override
  String get buyScreenTitle => 'स्टक खरिद';

  @override
  String get buyScreenSubtitle => 'आपूर्तिकर्ताबाट खरिद';

  @override
  String get buyScreenNewPurchaseLabel => 'नयाँ खरिद';

  @override
  String get buyScreenNewPurchaseSubtitle => 'आपूर्तिकर्ताबाट';

  @override
  String get buyScreenPurchaseReturnLabel => 'खरिद फिर्ता';

  @override
  String get buyScreenPurchaseReturnSubtitle => 'विक्रेतालाई फिर्ता';

  @override
  String get buyScreenPurchaseFromSupplierHeader => 'आपूर्तिकर्ताबाट खरिद';

  @override
  String get buyScreenInvoiceNumberLabel => 'बिल नम्बर';

  @override
  String get buyScreenPurchaseDateLabel => 'खरिद मिति';

  @override
  String get buyScreenVendorLabel => 'विक्रेता';

  @override
  String get buyScreenVendorNameLabel => 'विक्रेताको नाम (माथि सूचीमा नभएमा)';

  @override
  String get buyScreenPurchaseSummaryTitle => 'खरिद सारांश';

  @override
  String get buyScreenNoItemsSelectedTitle => 'कुनै वस्तु छानिएको छैन';

  @override
  String get buyScreenNoItemsSelectedSubtitle =>
      'उत्पादन थप्न तलको बटन क्लिक गर्नुहोस्';

  @override
  String get buyScreenAddProductsLabel => 'उत्पादन थप्नुहोस्';

  @override
  String get buyScreenAddMoreProductsLabel => 'थप उत्पादन थप्नुहोस्';

  @override
  String get buyScreenSubtotalLabel => 'उप-जम्मा:';

  @override
  String get buyScreenVatLabel => 'भ्याट:';

  @override
  String get buyScreenTotalPurchaseLabel => 'कुल खरिद:';

  @override
  String get buyScreenClearPurchaseLabel => 'खरिद खाली गर्नुहोस्';

  @override
  String get buyScreenSavePurchaseLabel => 'खरिद सुरक्षित गर्नुहोस्';

  @override
  String get buyScreenSupplierLabel => 'आपूर्तिकर्ता';

  @override
  String get buyScreenReturnBillNumberLabel => 'बिल नम्बर लेख्नुहोस्';

  @override
  String get buyScreenReturnBillNumberHint => 'जस्तै PB-POS-...';

  @override
  String get buyScreenReturnBillLookupButton => 'खोज्नुहोस्';

  @override
  String get buyScreenReturnBillLookupLoading => 'बिल खोजिँदैछ...';

  @override
  String get buyScreenReturnBillLookupNotFound =>
      'त्यो नम्बरको कुनै पोस्ट गरिएको बिल भेटिएन।';

  @override
  String buyScreenReturnBillLookupFound(
    int count,
    String plural,
    String billNo,
  ) {
    return 'बिल $billNo बाट $count वस्तु$plural लोड भयो';
  }

  @override
  String get buyScreenReturnItemsTitle => 'फिर्ता वस्तुहरू';

  @override
  String get buyScreenNoItemsToReturnTitle => 'फिर्ता गर्ने कुनै वस्तु छैन';

  @override
  String get buyScreenTotalAmountLabel => 'कुल रकम';

  @override
  String get buyScreenClearReturnLabel => 'फिर्ता खाली गर्नुहोस्';

  @override
  String get buyScreenPostReturnLabel => 'फिर्ता पोस्ट गर्नुहोस्';

  @override
  String get othersScreenResetSystemDialogTitle => 'प्रणाली रिसेट गर्नुहोस्';

  @override
  String get othersScreenResetSystemDialogContent =>
      'यसले सर्भरबाट कम्पनी, आउटलेट, र उत्पादन डाटा पुनः प्राप्त गर्छ। जारी राख्ने?';

  @override
  String get othersScreenCancelButton => 'रद्द गर्नुहोस्';

  @override
  String get othersScreenResetButton => 'रिसेट गर्नुहोस्';

  @override
  String get othersScreenRefreshSuccessMessage =>
      'प्रणाली नवीनतम डाटासँग रिफ्रेस भयो।';

  @override
  String get othersScreenTitle => 'सेटिङहरू';

  @override
  String get othersScreenSubtitle => 'प्रणाली सेटिङहरू र POS नियन्त्रणहरू';

  @override
  String get othersScreenPosConfigurationHeader => 'POS कन्फिगरेसन';

  @override
  String get othersScreenCompanyLabel => 'कम्पनी';

  @override
  String get othersScreenOutletLabel => 'आउटलेट';

  @override
  String get othersScreenFiscalYearLabel => 'आर्थिक वर्ष';

  @override
  String get othersScreenWarehouseLabel => 'गोदाम';

  @override
  String get othersScreenLogoutButton => 'लगआउट';

  @override
  String get othersScreenResetSystemButton => 'प्रणाली रिसेट गर्नुहोस्';

  @override
  String get othersScreenAccountHeader => 'खाता';

  @override
  String get othersScreenChangePasswordTile => 'पासवर्ड परिवर्तन गर्नुहोस्';

  @override
  String get othersScreenChangePasswordTileSubtitle =>
      'आफ्नो लगइन पासवर्ड अद्यावधिक गर्नुहोस्';

  @override
  String get changePasswordScreenTitle => 'पासवर्ड परिवर्तन गर्नुहोस्';

  @override
  String get changePasswordScreenSubtitle =>
      'आफ्नो हालको पासवर्ड प्रविष्ट गर्नुहोस् र नयाँ छान्नुहोस्।';

  @override
  String get changePasswordScreenCurrentPasswordLabel => 'हालको पासवर्ड';

  @override
  String get changePasswordScreenNewPasswordLabel => 'नयाँ पासवर्ड';

  @override
  String get changePasswordScreenConfirmPasswordLabel =>
      'नयाँ पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get changePasswordScreenCurrentPasswordRequiredError =>
      'हालको पासवर्ड आवश्यक छ।';

  @override
  String get changePasswordScreenNewPasswordLengthError =>
      'नयाँ पासवर्ड कम्तिमा ८ अक्षरको हुनुपर्छ।';

  @override
  String get changePasswordScreenConfirmPasswordMismatchError =>
      'पासवर्डहरू मेल खाँदैनन्।';

  @override
  String get changePasswordScreenSubmitButton => 'पासवर्ड अद्यावधिक गर्नुहोस्';

  @override
  String get changePasswordScreenSuccessMessage =>
      'पासवर्ड सफलतापूर्वक अद्यावधिक भयो।';

  @override
  String get languageCardHeader => 'भाषा';

  @override
  String get voicePromptCardHeader => 'POS भ्वाइस प्रोम्प्ट';

  @override
  String get voicePromptSoundStatusLabel => 'आवाज स्थिति';

  @override
  String get voicePromptOnLabel => 'सक्रिय';

  @override
  String get voicePromptOffLabel => 'निष्क्रिय';

  @override
  String get voicePromptAnnouncementLanguageLabel => 'घोषणा भाषा';

  @override
  String get voicePromptVolumeLabel => 'आवाजको मात्रा';

  @override
  String get voicePromptHelperText =>
      'बिक्री, खरिद, प्रतिवेदन, र अन्य बीच स्विच गर्दा POS भित्र मात्र बज्छ।';

  @override
  String get voicePromptTestButton => 'भ्वाइस प्रोम्प्ट परीक्षण गर्नुहोस्';

  @override
  String get reportsScreenTitle => 'प्रतिवेदनहरू';

  @override
  String get reportsScreenSubtitle => 'बिक्री र स्टक प्रतिवेदनहरू';

  @override
  String get reportsScreenPeriodLabel => 'अवधि:';

  @override
  String get reportsScreenChangeDateRangeTooltip =>
      'मिति दायरा परिवर्तन गर्नुहोस्';

  @override
  String get reportsScreenPeriodToday => 'आज';

  @override
  String get reportsScreenPeriodYesterday => 'हिजो';

  @override
  String get reportsScreenPeriodLast7Days => 'गत ७ दिन';

  @override
  String get reportsScreenPeriodLast30Days => 'गत ३० दिन';

  @override
  String get reportsScreenPeriodThisMonth => 'यो महिना';

  @override
  String get reportsScreenPeriodLastMonth => 'गत महिना';

  @override
  String get reportsScreenPeriodLifetime => 'सम्पूर्ण अवधि';

  @override
  String get reportsScreenPeriodCustomRange => 'अनुकूल दायरा';

  @override
  String get reportsScreenTabOverview => 'सिंहावलोकन';

  @override
  String get reportsScreenTabStores => 'पसलहरू';

  @override
  String get reportsScreenTabVendors => 'विक्रेताहरू';

  @override
  String get reportsScreenTabCustomers => 'ग्राहकहरू';

  @override
  String get reportsScreenTabVendorSales => 'विक्रेता बिक्री';

  @override
  String get reportsScreenTabMore => 'थप';

  @override
  String get reportsScreenSalesPurchasesTrendTitle =>
      'बिक्री बनाम खरिद प्रवृत्ति';

  @override
  String reportsScreenTopProductsTitle(String period) {
    return 'बढी बिक्री हुने उत्पादनहरू · $period';
  }

  @override
  String reportsScreenPaymentModeTitle(String period) {
    return 'भुक्तानी माध्यम अनुसार बिक्री · $period';
  }

  @override
  String get reportsScreenRecentSalesTitle => 'हालैका बिक्रीहरू';

  @override
  String get reportsScreenRecentPurchasesTitle => 'हालैका खरिदहरू';

  @override
  String get reportsScreenMonthlySalesTitle => 'मासिक बिक्री (फिर्ता सहित)';

  @override
  String get reportsScreenGrossSalesLabel => 'कुल बिक्री';

  @override
  String get reportsScreenSalesReturnsLabel => 'बिक्री फिर्ता';

  @override
  String get reportsScreenNetSalesLabel => 'खुद बिक्री';

  @override
  String reportsScreenInvoicesCount(int count) {
    return '$count बिल';
  }

  @override
  String get reportsScreenMonthlyPurchaseTitle => 'मासिक खरिद (फिर्ता सहित)';

  @override
  String get reportsScreenGrossPurchaseLabel => 'कुल खरिद';

  @override
  String get reportsScreenPurchaseReturnsLabel => 'खरिद फिर्ता';

  @override
  String get reportsScreenNetPurchaseLabel => 'खुद खरिद';

  @override
  String reportsScreenGrnCount(int count) {
    return '$count GRN';
  }

  @override
  String get reportsScreenTotalSalesTitle => 'कुल बिक्री';

  @override
  String reportsScreenPostedInvoicesSubtitle(int count, String period) {
    return '$count पोस्ट गरिएका बिल · $period';
  }

  @override
  String get reportsScreenTotalPurchasesTitle => 'कुल खरिद';

  @override
  String reportsScreenPostedStockIntakesSubtitle(int count, String period) {
    return '$count पोस्ट गरिएको स्टक प्रविष्टि · $period';
  }

  @override
  String get reportsScreenStockValueTitle => 'स्टक मूल्य';

  @override
  String get reportsScreenCurrentInventorySubtitle => 'हालको मौज्दात स्टक';

  @override
  String get reportsScreenVatCollectedTitle => 'उठेको भ्याट';

  @override
  String reportsScreenNetTaxSubtitle(String amount) {
    return 'खुद कर NPR $amount';
  }

  @override
  String get reportsScreenVatPaidTitle => 'तिरेको भ्याट';

  @override
  String reportsScreenPostedPurchaseBillsSubtitle(String period) {
    return 'पोस्ट गरिएका खरिद बिलमा · $period';
  }

  @override
  String get posScreenHeaderLanguageEnglish => 'English';

  @override
  String get posScreenHeaderLanguageNepali => 'नेपाली (Nepali)';

  @override
  String cartPanelHeaderItemsTotalLabel(int itemCount, String total) {
    return 'वस्तुहरू: $itemCount | कुल: NPR $total';
  }

  @override
  String get productPickerTitle => 'उत्पादन थप्नुहोस्';

  @override
  String get productPickerSubtitle =>
      'हालको बिक्रीमा थप्न उत्पादनहरू छान्नुहोस्';

  @override
  String get productPickerSearchHint => 'उत्पादनहरू खोज्नुहोस्…';

  @override
  String get productPickerCategoryProducts => 'उत्पादनहरू';

  @override
  String get productPickerCategoryAccessories => 'सामग्रीहरू';

  @override
  String get productPickerCategoryServices => 'सेवाहरू';

  @override
  String get productPickerEmptyTitle => 'कुनै रेकर्ड फेला परेन';

  @override
  String get productPickerEmptySubtitle =>
      'यस श्रेणीमा हालसम्म कुनै उत्पादन छैन।';

  @override
  String get productPickerCloseButton => 'बन्द गर्नुहोस्';

  @override
  String productCardStockLabel(String stock) {
    return 'स्टक: $stock';
  }

  @override
  String get productCardNotTracked => 'ट्र्याक नगरिएको';

  @override
  String get productCardOutOfStock => 'स्टक सकियो';

  @override
  String get customerPickerFullNameRequired => 'पूरा नाम आवश्यक छ।';

  @override
  String get customerPickerVatFormatError =>
      'भ्याट नम्बर ठ्याक्कै ९ अंकको हुनुपर्छ।';

  @override
  String get customerPickerTitle => 'ग्राहक';

  @override
  String get customerPickerExistingCustomerLabel => 'पुरानो ग्राहक';

  @override
  String get customerPickerWalkInHint => 'वा तल नयाँ ग्राहक थप्नुहोस्';

  @override
  String get customerPickerFullNameLabel => 'पूरा नाम';

  @override
  String get customerPickerPhoneNumberLabel => 'फोन नम्बर';

  @override
  String get customerPickerVatNumberLabel => 'भ्याट नम्बर';

  @override
  String get customerPickerDeliveryAddressLabel => 'डेलिभरी ठेगाना';

  @override
  String get customerPickerCancelButton => 'रद्द गर्नुहोस्';

  @override
  String get customerPickerUseCustomerButton => 'ग्राहक प्रयोग गर्नुहोस्';

  @override
  String get cartLineQtyLabel => 'मात्रा';

  @override
  String get cartLineRateLabel => 'दर';

  @override
  String get cartLineTotalLabel => 'जम्मा';

  @override
  String get purchaseCartLineUnitCostLabel => 'एकाइ लागत';

  @override
  String get paymentTypeSectionHeader => 'भुक्तानी प्रकार';

  @override
  String get paymentTypeSectionCashSaleLabel => 'नगद बिक्री';

  @override
  String get paymentTypeSectionCreditSaleLabel => 'उधारो बिक्री';

  @override
  String get paymentTypeSectionOnlinePaymentLabel => 'अनलाइन भुक्तानी';

  @override
  String get paymentTypeSectionRemarksLabel => 'कैफियत';

  @override
  String get paymentTypeSectionRemarksHint =>
      'यो नगद बिक्रीको लागि वैकल्पिक कैफियत';

  @override
  String get paymentTypeSectionReferenceNoLabel => 'सन्दर्भ नं.';

  @override
  String get paymentTypeSectionReferenceHint => 'कारोबार आईडी / सन्दर्भ नं.';

  @override
  String get paymentTypeSectionPaymentNoteLabel => 'भुक्तानी टिप्पणी';

  @override
  String get paymentTypeSectionPaymentNoteHint => 'वालेट, बैंक, मोबाइल नम्बर';

  @override
  String get totalsBlockSubtotalLabel => 'उप-जम्मा:';

  @override
  String get totalsBlockVatLabel => 'भ्याट (१३%):';

  @override
  String get totalsBlockDeliveryChargeLabel => 'डेलिभरी शुल्क:';

  @override
  String get totalsBlockTotalAmountLabel => 'कुल रकम';

  @override
  String get invoicePreviewInvoiceNoLabel => 'बीजक नं';

  @override
  String get invoicePreviewRefNoLabel => 'सन्दर्भ नं.';

  @override
  String get invoicePreviewInvoiceDateLabel => 'बीजक मिति';

  @override
  String get invoicePreviewCounterNoLabel => 'काउन्टर नं.';

  @override
  String get invoicePreviewCustomerNameLabel => 'ग्राहकको नाम';

  @override
  String get invoicePreviewWalkInCustomer => 'वाक-इन ग्राहक';

  @override
  String get invoicePreviewPaymentModeLabel => 'भुक्तानी माध्यम';

  @override
  String get invoicePreviewCashLabel => 'नगद';

  @override
  String get invoicePreviewCreditLabel => 'उधारो';

  @override
  String get invoicePreviewCustomerPanLabel => 'ग्राहक प्यान';

  @override
  String get invoicePreviewPaymentRefLabel => 'भुक्तानी सन्दर्भ';

  @override
  String get invoicePreviewPaymentNoteLabel => 'भुक्तानी टिप्पणी';

  @override
  String get invoicePreviewSignatureCustomerLabel => 'ग्राहक';

  @override
  String get invoicePreviewPrintButton => 'प्रिन्ट गर्नुहोस्';

  @override
  String get invoicePreviewShareButton => 'सेयर गर्नुहोस्';

  @override
  String get invoicePreviewCloseButton => 'बन्द गर्नुहोस्';

  @override
  String get purchaseInvoicePreviewBillNoLabel => 'बिल नं';

  @override
  String get purchaseInvoicePreviewVendorInvNoLabel => 'विक्रेता बीजक नं.';

  @override
  String get purchaseInvoicePreviewBillDateLabel => 'बिल मिति';

  @override
  String get purchaseInvoicePreviewMrnNoLabel => 'MRN नं.';

  @override
  String get purchaseInvoicePreviewVendorNameLabel => 'विक्रेताको नाम';

  @override
  String get purchaseInvoicePreviewVendorPanLabel => 'विक्रेता प्यान';

  @override
  String get purchaseInvoicePreviewSignatureSupplierLabel => 'आपूर्तिकर्ता';

  @override
  String get purchaseInvoicePreviewTitle => 'खरिद बीजक';

  @override
  String get purchaseInvoicePreviewShareButton => 'सेयर गर्नुहोस्';

  @override
  String get purchaseInvoicePreviewCloseButton => 'बन्द गर्नुहोस्';

  @override
  String posInvoicePhoneLabel(String phone) {
    return 'फोन नं. : $phone';
  }

  @override
  String posInvoiceVatLabel(String vatNo) {
    return 'भ्याट नं. : $vatNo';
  }

  @override
  String get posInvoiceDefaultTitle => 'कर बिल';

  @override
  String get posInvoiceSrHeader => 'क्र.सं.';

  @override
  String get posInvoiceHsCodeHeader => 'एच.एस. कोड';

  @override
  String get posInvoiceDescriptionHeader => 'विवरण';

  @override
  String get posInvoiceQtyHeader => 'मात्रा';

  @override
  String get posInvoiceRateHeader => 'दर';

  @override
  String get posInvoiceTotalAmtHeader => 'कुल रकम';

  @override
  String get posInvoicePrintDateTimeLabel => 'प्रिन्ट मिति/समय :';

  @override
  String get posInvoiceNepaliDateLabel => 'नेपाली मिति :';

  @override
  String get posInvoiceOriginalLabel => 'मूल प्रति';

  @override
  String get posInvoiceTaxableLabel => 'कर लाग्ने :';

  @override
  String get posInvoiceNonTaxableLabel => 'कर नलाग्ने :';

  @override
  String get posInvoiceSubTotalLabel => 'उप-जम्मा :';

  @override
  String get posInvoiceDiscountLabel => 'छुट : ० %';

  @override
  String get posInvoiceVatAmountLabel => 'भ्याट रकम :';

  @override
  String posInvoiceVatAmountWithRateLabel(String rate) {
    return 'भ्याट रकम ($rate) :';
  }

  @override
  String get posInvoiceNetTotalLabel => 'खुद जम्मा :';

  @override
  String get posInvoicePreparedByFallback => 'तयार गर्ने';

  @override
  String get posInvoicePrepareByLabel => 'तयार गर्ने';

  @override
  String get recentTransactionsEmptyMessage =>
      'यो अवधिको लागि कुनै कारोबार छैन';

  @override
  String get topProductsEmptyMessage => 'यो अवधिको लागि कुनै बिक्री छैन';

  @override
  String get salesTrendChartNoDataMessage => 'यस अवधिको लागि डाटा छैन';

  @override
  String get salesTrendChartSalesLegend => 'बिक्री';

  @override
  String get salesTrendChartPurchasesLegend => 'खरिद';

  @override
  String get paymentModePieChartNoSalesMessage =>
      'यस अवधिको लागि कुनै बिक्री छैन';

  @override
  String get breakdownChartListNoDataMessage => 'यस अवधिको लागि डाटा छैन';

  @override
  String breakdownChartListVatLabel(String vatNo) {
    return 'भ्याट: $vatNo';
  }

  @override
  String breakdownChartListTransactionsCount(int count) {
    return '$count कारोबार';
  }

  @override
  String get printerCardHeader => 'प्रिन्टर जडान';

  @override
  String get printerCardNoPrinterMessage =>
      'कुनै प्रिन्टर छानिएको छैन। बिल सिधै प्रिन्ट गर्न पेयर गरिएको ब्लुटुथ प्रिन्टर छान्नुहोस्।';

  @override
  String get printerCardForgetTooltip => 'प्रिन्टर हटाउनुहोस्';

  @override
  String get printerCardPaperSizeLabel => 'कागजको साइज';

  @override
  String get printerCardPaperSize58Label => '५८ मिमी (२ इन्च)';

  @override
  String get printerCardPaperSize80Label => '८० मिमी (३ इन्च)';

  @override
  String get printerCardSelectPrinterButton => 'प्रिन्टर छान्नुहोस्';

  @override
  String get printerCardChangePrinterButton => 'प्रिन्टर परिवर्तन गर्नुहोस्';

  @override
  String get printerCardTestPrintButton => 'टेस्ट प्रिन्ट';

  @override
  String get printerCardHelperText =>
      'पहिले फोनको ब्लुटुथ सेटिङमा थर्मल प्रिन्टर पेयर गर्नुहोस्, त्यसपछि यहाँ छान्नुहोस्। बिलहरू इनभ्वाइस प्रिभ्युबाट सिधै प्रिन्ट हुन्छन्।';

  @override
  String get printerTestPrintSentMessage => 'टेस्ट प्रिन्ट प्रिन्टरमा पठाइयो';

  @override
  String get printerPickerTitle => 'ब्लुटुथ प्रिन्टर छान्नुहोस्';

  @override
  String get printerPickerRefreshTooltip => 'सूची रिफ्रेस गर्नुहोस्';

  @override
  String get printerPickerNoDevicesMessage =>
      'कुनै पेयर गरिएको ब्लुटुथ डिभाइस भेटिएन। फोनको ब्लुटुथ सेटिङमा प्रिन्टर पेयर गरेर रिफ्रेस गर्नुहोस्।';

  @override
  String get printerPickerHelperText =>
      'बिल प्रिन्टका लागि सुरक्षित गर्न प्रिन्टरमा ट्याप गर्नुहोस्।';

  @override
  String get printerPrintingMessage => 'बिल प्रिन्ट हुँदैछ…';

  @override
  String get printerPrintSuccessMessage => 'बिल प्रिन्टरमा पठाइयो';

  @override
  String get printerErrorBluetoothOff =>
      'ब्लुटुथ बन्द छ। खोलेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get printerErrorPermissionDenied =>
      'ब्लुटुथ अनुमति अस्वीकार गरियो। सेटिङमा गएर यो एपलाई ब्लुटुथ पहुँच दिनुहोस्।';

  @override
  String get printerErrorNoPrinterSelected =>
      'कुनै प्रिन्टर छानिएको छैन। पहिले प्रिन्टर छान्नुहोस्।';

  @override
  String get printerErrorConnectionFailed =>
      'प्रिन्टरसँग जडान हुन सकेन। प्रिन्टर खुला र नजिकै छ भनी सुनिश्चित गर्नुहोस्।';

  @override
  String get printerErrorPrintFailed =>
      'प्रिन्ट असफल भयो। प्रिन्टर जाँचेर फेरि प्रयास गर्नुहोस्।';
}
