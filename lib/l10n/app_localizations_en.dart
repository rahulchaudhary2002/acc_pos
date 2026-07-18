// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'POS';

  @override
  String get posHomeSelectCompanyLabel => 'Select a company';

  @override
  String get posHomeBottomNavSellLabel => 'Sell';

  @override
  String get posHomeBottomNavBuyLabel => 'Buy';

  @override
  String get posHomeBottomNavReportsLabel => 'Reports';

  @override
  String get posHomeBottomNavOthersLabel => 'Others';

  @override
  String get sellScreenTitle => 'Sell LPG';

  @override
  String get sellScreenSubtitle => 'Easy POS for Gas Dealers';

  @override
  String get sellScreenSelectCustomerOrNameError =>
      'Select an existing customer or enter a full name for a customer sale.';

  @override
  String get sellScreenVatNumberLengthError =>
      'VAT number must be exactly 9 alphanumeric characters.';

  @override
  String get sellScreenCashLimitExceededError =>
      'Cash sales cannot exceed NPR 25,000. Please switch to Customer Sale for higher amounts.';

  @override
  String sellScreenReturnCompletedMessage(String documentNo, String total) {
    return 'Return $documentNo completed — NPR $total';
  }

  @override
  String get sellScreenCashSaleLabel => 'Cash Sale';

  @override
  String get sellScreenCashSaleSubtitle => 'Up to NPR 25,000';

  @override
  String get sellScreenCustomerSaleLabel => 'Customer Sale';

  @override
  String get sellScreenCustomerSaleSubtitle => 'Linked account';

  @override
  String get sellScreenSalesReturnLabel => 'Sales Return';

  @override
  String get sellScreenSalesReturnSubtitle => 'Refund items';

  @override
  String get sellScreenVendorLabel => 'Vendor';

  @override
  String get sellScreenSelectVendorHint => 'Select vendor (optional)';

  @override
  String get sellScreenVendorFooterHint =>
      'Records which vendor this sale is attributed to for reporting.';

  @override
  String get sellScreenCurrentSaleTitle => 'Current Sale';

  @override
  String get sellScreenNoItemsAddedTitle => 'No items added yet';

  @override
  String get sellScreenNoItemsAddedSubtitle =>
      'Click the button below to add products';

  @override
  String get sellScreenAddProductsLabel => 'Add Products';

  @override
  String get sellScreenAddMoreProductsLabel => 'Add More Products';

  @override
  String get sellScreenClearAllLabel => 'Clear All';

  @override
  String get sellScreenGenerateVatBillLabel => 'Generate VAT Bill';

  @override
  String get sellScreenCustomerOptionalLabel => 'Customer (optional)';

  @override
  String get sellScreenWalkInNoCustomerLabel => 'Walk-in / No customer';

  @override
  String get sellScreenReturnItemsTitle => 'Return Items';

  @override
  String get sellScreenNoItemsSelectedTitle => 'No items selected';

  @override
  String get sellScreenSelectProductsToReturnSubtitle =>
      'Select products to return';

  @override
  String get sellScreenTotalReturnLabel => 'Total Return';

  @override
  String get sellScreenClearReturnLabel => 'Clear Return';

  @override
  String get sellScreenPostSalesReturnLabel => 'Post Sales Return';

  @override
  String get sellScreenCustomerInformationTitle => 'Customer Information';

  @override
  String get sellScreenExistingCustomerLabel => 'Existing Customer';

  @override
  String get sellScreenSelectCustomerLabel => 'Select customer';

  @override
  String get sellScreenAutoCreateCustomerHelper =>
      'Leave this blank and enter details below to auto-create a new customer when generating the bill.';

  @override
  String get sellScreenFullNameLabel => 'Full Name';

  @override
  String get sellScreenPhoneNumberLabel => 'Phone Number';

  @override
  String get sellScreenVatNumberLabel => 'VAT Number';

  @override
  String get sellScreenDeliveryAddressLabel => 'Delivery Address';

  @override
  String get buyScreenSelectVendorError => 'Please select or enter a vendor.';

  @override
  String get buyScreenSelectReturnSupplierError =>
      'Please select a supplier to return to.';

  @override
  String buyScreenReturnCompletedMessage(String documentNo, String total) {
    return 'Return $documentNo completed — NPR $total';
  }

  @override
  String get buyScreenTitle => 'Buy Stock';

  @override
  String get buyScreenSubtitle => 'Purchase from suppliers';

  @override
  String get buyScreenNewPurchaseLabel => 'New Purchase';

  @override
  String get buyScreenNewPurchaseSubtitle => 'From suppliers';

  @override
  String get buyScreenPurchaseReturnLabel => 'Purchase Return';

  @override
  String get buyScreenPurchaseReturnSubtitle => 'Return to vendor';

  @override
  String get buyScreenPurchaseFromSupplierHeader => 'Purchase from Supplier';

  @override
  String get buyScreenInvoiceNumberLabel => 'Invoice Number';

  @override
  String get buyScreenPurchaseDateLabel => 'Purchase Date';

  @override
  String get buyScreenVendorLabel => 'Vendor';

  @override
  String get buyScreenVendorNameLabel => 'Vendor Name (if not listed above)';

  @override
  String get buyScreenPurchaseSummaryTitle => 'Purchase Summary';

  @override
  String get buyScreenNoItemsSelectedTitle => 'No items selected';

  @override
  String get buyScreenNoItemsSelectedSubtitle =>
      'Click the button below to add products';

  @override
  String get buyScreenAddProductsLabel => 'Add Products';

  @override
  String get buyScreenAddMoreProductsLabel => 'Add More Products';

  @override
  String get buyScreenSubtotalLabel => 'Subtotal:';

  @override
  String get buyScreenVatLabel => 'VAT:';

  @override
  String get buyScreenTotalPurchaseLabel => 'Total Purchase:';

  @override
  String get buyScreenClearPurchaseLabel => 'Clear Purchase';

  @override
  String get buyScreenSavePurchaseLabel => 'Save Purchase';

  @override
  String get buyScreenSupplierLabel => 'Supplier';

  @override
  String get buyScreenReturnItemsTitle => 'Return Items';

  @override
  String get buyScreenNoItemsToReturnTitle => 'No items to return';

  @override
  String get buyScreenTotalAmountLabel => 'Total Amount';

  @override
  String get buyScreenClearReturnLabel => 'Clear Return';

  @override
  String get buyScreenPostReturnLabel => 'Post Return';

  @override
  String get othersScreenResetSystemDialogTitle => 'Reset System';

  @override
  String get othersScreenResetSystemDialogContent =>
      'This refreshes company, outlet, and product data from the server. Continue?';

  @override
  String get othersScreenCancelButton => 'Cancel';

  @override
  String get othersScreenResetButton => 'Reset';

  @override
  String get othersScreenRefreshSuccessMessage =>
      'System refreshed with the latest data.';

  @override
  String get othersScreenTitle => 'Settings';

  @override
  String get othersScreenSubtitle => 'System settings and POS controls';

  @override
  String get othersScreenPosConfigurationHeader => 'POS Configuration';

  @override
  String get othersScreenCompanyLabel => 'Company';

  @override
  String get othersScreenOutletLabel => 'Outlet';

  @override
  String get othersScreenFiscalYearLabel => 'Fiscal Year';

  @override
  String get othersScreenWarehouseLabel => 'Warehouse';

  @override
  String get othersScreenLogoutButton => 'Logout';

  @override
  String get othersScreenResetSystemButton => 'Reset System';

  @override
  String get othersScreenAccountHeader => 'Account';

  @override
  String get othersScreenChangePasswordTile => 'Change Password';

  @override
  String get othersScreenChangePasswordTileSubtitle =>
      'Update your login password';

  @override
  String get changePasswordScreenTitle => 'Change Password';

  @override
  String get changePasswordScreenSubtitle =>
      'Enter your current password and choose a new one.';

  @override
  String get changePasswordScreenCurrentPasswordLabel => 'Current Password';

  @override
  String get changePasswordScreenNewPasswordLabel => 'New Password';

  @override
  String get changePasswordScreenConfirmPasswordLabel => 'Confirm New Password';

  @override
  String get changePasswordScreenCurrentPasswordRequiredError =>
      'Current password is required.';

  @override
  String get changePasswordScreenNewPasswordLengthError =>
      'New password must be at least 8 characters.';

  @override
  String get changePasswordScreenConfirmPasswordMismatchError =>
      'Passwords do not match.';

  @override
  String get changePasswordScreenSubmitButton => 'Update Password';

  @override
  String get changePasswordScreenSuccessMessage =>
      'Password updated successfully.';

  @override
  String get languageCardHeader => 'Language';

  @override
  String get voicePromptCardHeader => 'POS Voice Prompt';

  @override
  String get voicePromptSoundStatusLabel => 'Sound Status';

  @override
  String get voicePromptOnLabel => 'On';

  @override
  String get voicePromptOffLabel => 'Off';

  @override
  String get voicePromptAnnouncementLanguageLabel => 'Announcement Language';

  @override
  String get voicePromptVolumeLabel => 'Volume';

  @override
  String get voicePromptHelperText =>
      'Plays only inside POS when switching between Sell, Buy, Reports, and Others.';

  @override
  String get voicePromptTestButton => 'Test Voice Prompt';

  @override
  String get reportsScreenTitle => 'Reports';

  @override
  String get reportsScreenSubtitle => 'Sales & Inventory Reports';

  @override
  String get reportsScreenPeriodLabel => 'Period:';

  @override
  String get reportsScreenChangeDateRangeTooltip => 'Change date range';

  @override
  String get reportsScreenPeriodToday => 'Today';

  @override
  String get reportsScreenPeriodYesterday => 'Yesterday';

  @override
  String get reportsScreenPeriodLast7Days => 'Last 7 Days';

  @override
  String get reportsScreenPeriodLast30Days => 'Last 30 Days';

  @override
  String get reportsScreenPeriodThisMonth => 'This Month';

  @override
  String get reportsScreenPeriodLastMonth => 'Last Month';

  @override
  String get reportsScreenPeriodLifetime => 'Lifetime';

  @override
  String get reportsScreenPeriodCustomRange => 'Custom Range';

  @override
  String get reportsScreenTabOverview => 'Overview';

  @override
  String get reportsScreenTabStores => 'Stores';

  @override
  String get reportsScreenTabVendors => 'Vendors';

  @override
  String get reportsScreenTabCustomers => 'Customers';

  @override
  String get reportsScreenTabMore => 'More';

  @override
  String get reportsScreenSalesPurchasesTrendTitle =>
      'Sales vs Purchases Trend';

  @override
  String reportsScreenTopProductsTitle(String period) {
    return 'Top Products · $period';
  }

  @override
  String reportsScreenPaymentModeTitle(String period) {
    return 'Sales by Payment Mode · $period';
  }

  @override
  String get reportsScreenRecentSalesTitle => 'Recent Sales';

  @override
  String get reportsScreenRecentPurchasesTitle => 'Recent Purchases';

  @override
  String get reportsScreenMonthlySalesTitle => 'Monthly Sales (incl. Returns)';

  @override
  String get reportsScreenGrossSalesLabel => 'Gross Sales';

  @override
  String get reportsScreenSalesReturnsLabel => 'Sales Returns';

  @override
  String get reportsScreenNetSalesLabel => 'Net Sales';

  @override
  String reportsScreenInvoicesCount(int count) {
    return '$count invoices';
  }

  @override
  String get reportsScreenMonthlyPurchaseTitle =>
      'Monthly Purchase (incl. Returns)';

  @override
  String get reportsScreenGrossPurchaseLabel => 'Gross Purchase';

  @override
  String get reportsScreenPurchaseReturnsLabel => 'Purchase Returns';

  @override
  String get reportsScreenNetPurchaseLabel => 'Net Purchase';

  @override
  String reportsScreenGrnCount(int count) {
    return '$count GRNs';
  }

  @override
  String get reportsScreenTotalSalesTitle => 'Total Sales';

  @override
  String reportsScreenPostedInvoicesSubtitle(int count, String period) {
    return '$count posted invoices · $period';
  }

  @override
  String get reportsScreenTotalPurchasesTitle => 'Total Purchases';

  @override
  String reportsScreenPostedStockIntakesSubtitle(int count, String period) {
    return '$count posted stock intakes · $period';
  }

  @override
  String get reportsScreenStockValueTitle => 'Stock Value';

  @override
  String get reportsScreenCurrentInventorySubtitle =>
      'Current inventory on hand';

  @override
  String get reportsScreenVatCollectedTitle => 'VAT Collected';

  @override
  String reportsScreenNetTaxSubtitle(String amount) {
    return 'Net tax NPR $amount';
  }

  @override
  String get reportsScreenVatPaidTitle => 'VAT Paid';

  @override
  String reportsScreenPostedPurchaseBillsSubtitle(String period) {
    return 'On posted purchase bills · $period';
  }

  @override
  String get posScreenHeaderLanguageEnglish => 'English';

  @override
  String get posScreenHeaderLanguageNepali => 'नेपाली (Nepali)';

  @override
  String cartPanelHeaderItemsTotalLabel(int itemCount, String total) {
    return 'Items: $itemCount | Total: NPR $total';
  }

  @override
  String get productPickerTitle => 'Add Product';

  @override
  String get productPickerSubtitle =>
      'Select products to add to the current sale';

  @override
  String get productPickerSearchHint => 'Search products…';

  @override
  String get productPickerCategoryProducts => 'Products';

  @override
  String get productPickerCategoryAccessories => 'Accessories';

  @override
  String get productPickerCategoryServices => 'Services';

  @override
  String get productPickerEmptyTitle => 'No records found';

  @override
  String get productPickerEmptySubtitle => 'No products in this category yet.';

  @override
  String get productPickerCloseButton => 'Close';

  @override
  String productCardStockLabel(String stock) {
    return 'Stock: $stock';
  }

  @override
  String get productCardNotTracked => 'Not tracked';

  @override
  String get productCardOutOfStock => 'Out of Stock';

  @override
  String get customerPickerFullNameRequired => 'Full name is required.';

  @override
  String get customerPickerVatFormatError =>
      'VAT number must be exactly 9 alphanumeric characters.';

  @override
  String get customerPickerTitle => 'Customer';

  @override
  String get customerPickerExistingCustomerLabel => 'Existing Customer';

  @override
  String get customerPickerWalkInHint =>
      'Or create a new walk-in customer below';

  @override
  String get customerPickerFullNameLabel => 'Full Name';

  @override
  String get customerPickerPhoneNumberLabel => 'Phone Number';

  @override
  String get customerPickerVatNumberLabel => 'VAT Number';

  @override
  String get customerPickerDeliveryAddressLabel => 'Delivery Address';

  @override
  String get customerPickerCancelButton => 'Cancel';

  @override
  String get customerPickerUseCustomerButton => 'Use Customer';

  @override
  String get cartLineQtyLabel => 'Qty';

  @override
  String get cartLineRateLabel => 'Rate';

  @override
  String get cartLineTotalLabel => 'Total';

  @override
  String get purchaseCartLineUnitCostLabel => 'Unit Cost';

  @override
  String get paymentTypeSectionHeader => 'Payment Type';

  @override
  String get paymentTypeSectionCashSaleLabel => 'Cash Sale';

  @override
  String get paymentTypeSectionCreditSaleLabel => 'Credit Sale';

  @override
  String get paymentTypeSectionOnlinePaymentLabel => 'Online Payment';

  @override
  String get paymentTypeSectionRemarksLabel => 'Remarks';

  @override
  String get paymentTypeSectionRemarksHint =>
      'Optional remarks for this cash sale';

  @override
  String get paymentTypeSectionReferenceNoLabel => 'Reference No.';

  @override
  String get paymentTypeSectionReferenceHint => 'Transaction ID / Ref. No.';

  @override
  String get paymentTypeSectionPaymentNoteLabel => 'Payment Note';

  @override
  String get paymentTypeSectionPaymentNoteHint => 'Wallet, bank, mobile number';

  @override
  String get totalsBlockSubtotalLabel => 'Subtotal:';

  @override
  String get totalsBlockVatLabel => 'VAT (13%):';

  @override
  String get totalsBlockDeliveryChargeLabel => 'Delivery Charge:';

  @override
  String get totalsBlockTotalAmountLabel => 'Total Amount';

  @override
  String get invoicePreviewInvoiceNoLabel => 'Invoice No';

  @override
  String get invoicePreviewRefNoLabel => 'Ref. No.';

  @override
  String get invoicePreviewInvoiceDateLabel => 'Invoice Date';

  @override
  String get invoicePreviewCounterNoLabel => 'Counter No.';

  @override
  String get invoicePreviewCustomerNameLabel => 'Customer Name';

  @override
  String get invoicePreviewWalkInCustomer => 'Walk-in Customer';

  @override
  String get invoicePreviewPaymentModeLabel => 'Payment Mode';

  @override
  String get invoicePreviewCashLabel => 'Cash';

  @override
  String get invoicePreviewCreditLabel => 'Credit';

  @override
  String get invoicePreviewCustomerPanLabel => 'Customer Pan';

  @override
  String get invoicePreviewPaymentRefLabel => 'Payment Ref.';

  @override
  String get invoicePreviewPaymentNoteLabel => 'Payment Note';

  @override
  String get invoicePreviewSignatureCustomerLabel => 'Customer';

  @override
  String get invoicePreviewPrintButton => 'Print';

  @override
  String get invoicePreviewShareButton => 'Share';

  @override
  String get invoicePreviewCloseButton => 'Close';

  @override
  String get purchaseInvoicePreviewBillNoLabel => 'Bill No';

  @override
  String get purchaseInvoicePreviewVendorInvNoLabel => 'Vendor Inv. No.';

  @override
  String get purchaseInvoicePreviewBillDateLabel => 'Bill Date';

  @override
  String get purchaseInvoicePreviewMrnNoLabel => 'MRN No.';

  @override
  String get purchaseInvoicePreviewVendorNameLabel => 'Vendor Name';

  @override
  String get purchaseInvoicePreviewVendorPanLabel => 'Vendor Pan';

  @override
  String get purchaseInvoicePreviewSignatureSupplierLabel => 'Supplier';

  @override
  String get purchaseInvoicePreviewTitle => 'PURCHASE INVOICE';

  @override
  String get purchaseInvoicePreviewShareButton => 'Share';

  @override
  String get purchaseInvoicePreviewCloseButton => 'Close';

  @override
  String posInvoicePhoneLabel(String phone) {
    return 'Phone No : $phone';
  }

  @override
  String posInvoiceVatLabel(String vatNo) {
    return 'VAT # : $vatNo';
  }

  @override
  String get posInvoiceDefaultTitle => 'TAX INVOICE';

  @override
  String get posInvoiceSrHeader => 'Sr.';

  @override
  String get posInvoiceHsCodeHeader => 'H.S. Code';

  @override
  String get posInvoiceDescriptionHeader => 'Description';

  @override
  String get posInvoiceQtyHeader => 'Qty.';

  @override
  String get posInvoiceRateHeader => 'Rate';

  @override
  String get posInvoiceTotalAmtHeader => 'Total Amt.';

  @override
  String get posInvoicePrintDateTimeLabel => 'Print Date/Time :';

  @override
  String get posInvoiceNepaliDateLabel => 'Nepali Date :';

  @override
  String get posInvoiceOriginalLabel => 'Original';

  @override
  String get posInvoiceTaxableLabel => 'Taxable :';

  @override
  String get posInvoiceNonTaxableLabel => 'Non Taxable :';

  @override
  String get posInvoiceSubTotalLabel => 'Sub Total :';

  @override
  String get posInvoiceDiscountLabel => 'Discount : 0 %';

  @override
  String get posInvoiceVatAmountLabel => 'VAT Amount :';

  @override
  String posInvoiceVatAmountWithRateLabel(String rate) {
    return 'VAT Amount ($rate) :';
  }

  @override
  String get posInvoiceNetTotalLabel => 'Net Total :';

  @override
  String get posInvoicePreparedByFallback => 'Prepared By';

  @override
  String get posInvoicePrepareByLabel => 'Prepare By';

  @override
  String get recentTransactionsEmptyMessage =>
      'No transactions for this period';

  @override
  String get topProductsEmptyMessage => 'No sales for this period';

  @override
  String get salesTrendChartNoDataMessage => 'No data for this period';

  @override
  String get salesTrendChartSalesLegend => 'Sales';

  @override
  String get salesTrendChartPurchasesLegend => 'Purchases';

  @override
  String get paymentModePieChartNoSalesMessage => 'No sales for this period';

  @override
  String get breakdownChartListNoDataMessage => 'No data for this period';

  @override
  String breakdownChartListVatLabel(String vatNo) {
    return 'VAT: $vatNo';
  }

  @override
  String breakdownChartListTransactionsCount(int count) {
    return '$count txns';
  }

  @override
  String get printerCardHeader => 'Printer Connection';

  @override
  String get printerCardNoPrinterMessage =>
      'No printer selected. Choose a paired Bluetooth printer to print bills directly.';

  @override
  String get printerCardForgetTooltip => 'Remove printer';

  @override
  String get printerCardPaperSizeLabel => 'Paper Size';

  @override
  String get printerCardPaperSize58Label => '58 mm (2 inch)';

  @override
  String get printerCardPaperSize80Label => '80 mm (3 inch)';

  @override
  String get printerCardSelectPrinterButton => 'Select Printer';

  @override
  String get printerCardChangePrinterButton => 'Change Printer';

  @override
  String get printerCardTestPrintButton => 'Test Print';

  @override
  String get printerCardHelperText =>
      'Pair the thermal printer in your phone\'s Bluetooth settings first, then select it here. Bills print on it directly from the invoice preview.';

  @override
  String get printerTestPrintSentMessage => 'Test print sent to printer';

  @override
  String get printerPickerTitle => 'Select Bluetooth Printer';

  @override
  String get printerPickerRefreshTooltip => 'Refresh list';

  @override
  String get printerPickerNoDevicesMessage =>
      'No paired Bluetooth devices found. Pair the printer in your phone\'s Bluetooth settings and refresh.';

  @override
  String get printerPickerHelperText =>
      'Tap a printer to save it for bill printing.';

  @override
  String get printerPrintingMessage => 'Printing bill…';

  @override
  String get printerPrintSuccessMessage => 'Bill sent to printer';

  @override
  String get printerErrorBluetoothOff =>
      'Bluetooth is turned off. Turn it on and try again.';

  @override
  String get printerErrorPermissionDenied =>
      'Bluetooth permission denied. Allow Bluetooth access for this app in settings.';

  @override
  String get printerErrorNoPrinterSelected =>
      'No printer selected. Choose a printer first.';

  @override
  String get printerErrorConnectionFailed =>
      'Could not connect to the printer. Make sure it is switched on and in range.';

  @override
  String get printerErrorPrintFailed =>
      'Printing failed. Check the printer and try again.';
}
