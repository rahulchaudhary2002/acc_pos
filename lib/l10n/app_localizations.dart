import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get appTitle;

  /// No description provided for @posHomeSelectCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a company'**
  String get posHomeSelectCompanyLabel;

  /// No description provided for @posHomeBottomNavSellLabel.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get posHomeBottomNavSellLabel;

  /// No description provided for @posHomeBottomNavBuyLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get posHomeBottomNavBuyLabel;

  /// No description provided for @posHomeBottomNavReportsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get posHomeBottomNavReportsLabel;

  /// No description provided for @posHomeBottomNavOthersLabel.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get posHomeBottomNavOthersLabel;

  /// No description provided for @sellScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell LPG'**
  String get sellScreenTitle;

  /// No description provided for @sellScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easy POS for Gas Dealers'**
  String get sellScreenSubtitle;

  /// No description provided for @sellScreenSelectCustomerOrNameError.
  ///
  /// In en, this message translates to:
  /// **'Select an existing customer or enter a full name for a customer sale.'**
  String get sellScreenSelectCustomerOrNameError;

  /// No description provided for @sellScreenVatNumberLengthError.
  ///
  /// In en, this message translates to:
  /// **'VAT number must be exactly 9 alphanumeric characters.'**
  String get sellScreenVatNumberLengthError;

  /// No description provided for @sellScreenCashLimitExceededError.
  ///
  /// In en, this message translates to:
  /// **'Cash sales cannot exceed NPR 25,000. Please switch to Customer Sale for higher amounts.'**
  String get sellScreenCashLimitExceededError;

  /// No description provided for @sellScreenPhoneNumberFormatError.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly 10 digits.'**
  String get sellScreenPhoneNumberFormatError;

  /// No description provided for @sellScreenOnlineReferenceRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Reference No. is required for online payments.'**
  String get sellScreenOnlineReferenceRequiredError;

  /// No description provided for @sellScreenReturnCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Return {documentNo} completed — NPR {total}'**
  String sellScreenReturnCompletedMessage(String documentNo, String total);

  /// No description provided for @sellScreenCashSaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash Sale'**
  String get sellScreenCashSaleLabel;

  /// No description provided for @sellScreenCashSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to NPR 25,000'**
  String get sellScreenCashSaleSubtitle;

  /// No description provided for @sellScreenCustomerSaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Sale'**
  String get sellScreenCustomerSaleLabel;

  /// No description provided for @sellScreenCustomerSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Linked account'**
  String get sellScreenCustomerSaleSubtitle;

  /// No description provided for @sellScreenSalesReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales Return'**
  String get sellScreenSalesReturnLabel;

  /// No description provided for @sellScreenSalesReturnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Refund items'**
  String get sellScreenSalesReturnSubtitle;

  /// No description provided for @sellScreenVendorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get sellScreenVendorLabel;

  /// No description provided for @sellScreenSelectVendorHint.
  ///
  /// In en, this message translates to:
  /// **'Select vendor (optional)'**
  String get sellScreenSelectVendorHint;

  /// No description provided for @sellScreenVendorFooterHint.
  ///
  /// In en, this message translates to:
  /// **'Records which vendor this sale is attributed to for reporting.'**
  String get sellScreenVendorFooterHint;

  /// No description provided for @sellScreenCurrentSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Sale'**
  String get sellScreenCurrentSaleTitle;

  /// No description provided for @sellScreenNoItemsAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get sellScreenNoItemsAddedTitle;

  /// No description provided for @sellScreenNoItemsAddedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click the button below to add products'**
  String get sellScreenNoItemsAddedSubtitle;

  /// No description provided for @sellScreenAddProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Products'**
  String get sellScreenAddProductsLabel;

  /// No description provided for @sellScreenAddMoreProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Add More Products'**
  String get sellScreenAddMoreProductsLabel;

  /// No description provided for @sellScreenClearAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get sellScreenClearAllLabel;

  /// No description provided for @sellScreenGenerateVatBillLabel.
  ///
  /// In en, this message translates to:
  /// **'Generate VAT Bill'**
  String get sellScreenGenerateVatBillLabel;

  /// No description provided for @sellScreenCustomerOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer (optional)'**
  String get sellScreenCustomerOptionalLabel;

  /// No description provided for @sellScreenWalkInNoCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Walk-in / No customer'**
  String get sellScreenWalkInNoCustomerLabel;

  /// No description provided for @sellScreenInvoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter Bill Number'**
  String get sellScreenInvoiceNumberLabel;

  /// No description provided for @sellScreenInvoiceNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. XXXX-001'**
  String get sellScreenInvoiceNumberHint;

  /// No description provided for @sellScreenInvoiceLookupButton.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get sellScreenInvoiceLookupButton;

  /// No description provided for @sellScreenInvoiceLookupLoading.
  ///
  /// In en, this message translates to:
  /// **'Looking up invoice...'**
  String get sellScreenInvoiceLookupLoading;

  /// No description provided for @sellScreenInvoiceLookupNotFound.
  ///
  /// In en, this message translates to:
  /// **'No posted invoice found for that number.'**
  String get sellScreenInvoiceLookupNotFound;

  /// No description provided for @sellScreenInvoiceLookupFound.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} item{plural} from invoice {invoiceNo}'**
  String sellScreenInvoiceLookupFound(
    int count,
    String plural,
    String invoiceNo,
  );

  /// No description provided for @sellScreenReturnItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Items'**
  String get sellScreenReturnItemsTitle;

  /// No description provided for @sellScreenNoItemsSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'No items selected'**
  String get sellScreenNoItemsSelectedTitle;

  /// No description provided for @sellScreenSelectProductsToReturnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select products to return'**
  String get sellScreenSelectProductsToReturnSubtitle;

  /// No description provided for @sellScreenTotalReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Return'**
  String get sellScreenTotalReturnLabel;

  /// No description provided for @sellScreenClearReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Return'**
  String get sellScreenClearReturnLabel;

  /// No description provided for @sellScreenPostSalesReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Post Sales Return'**
  String get sellScreenPostSalesReturnLabel;

  /// No description provided for @sellScreenCustomerInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get sellScreenCustomerInformationTitle;

  /// No description provided for @sellScreenExistingCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Existing Customer'**
  String get sellScreenExistingCustomerLabel;

  /// No description provided for @sellScreenSelectCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Select customer'**
  String get sellScreenSelectCustomerLabel;

  /// No description provided for @sellScreenAutoCreateCustomerHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave this blank and enter details below to auto-create a new customer when generating the bill.'**
  String get sellScreenAutoCreateCustomerHelper;

  /// No description provided for @sellScreenFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get sellScreenFullNameLabel;

  /// No description provided for @sellScreenPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get sellScreenPhoneNumberLabel;

  /// No description provided for @sellScreenVatNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get sellScreenVatNumberLabel;

  /// No description provided for @sellScreenDeliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get sellScreenDeliveryAddressLabel;

  /// No description provided for @buyScreenSelectVendorError.
  ///
  /// In en, this message translates to:
  /// **'Please select or enter a vendor.'**
  String get buyScreenSelectVendorError;

  /// No description provided for @buyScreenSelectReturnSupplierError.
  ///
  /// In en, this message translates to:
  /// **'Please select a supplier to return to.'**
  String get buyScreenSelectReturnSupplierError;

  /// No description provided for @buyScreenReturnCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Return {documentNo} completed — NPR {total}'**
  String buyScreenReturnCompletedMessage(String documentNo, String total);

  /// No description provided for @buyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy Stock'**
  String get buyScreenTitle;

  /// No description provided for @buyScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase from suppliers'**
  String get buyScreenSubtitle;

  /// No description provided for @buyScreenNewPurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'New Purchase'**
  String get buyScreenNewPurchaseLabel;

  /// No description provided for @buyScreenNewPurchaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From suppliers'**
  String get buyScreenNewPurchaseSubtitle;

  /// No description provided for @buyScreenPurchaseReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Return'**
  String get buyScreenPurchaseReturnLabel;

  /// No description provided for @buyScreenPurchaseReturnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to vendor'**
  String get buyScreenPurchaseReturnSubtitle;

  /// No description provided for @buyScreenPurchaseFromSupplierHeader.
  ///
  /// In en, this message translates to:
  /// **'Purchase from Supplier'**
  String get buyScreenPurchaseFromSupplierHeader;

  /// No description provided for @buyScreenInvoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get buyScreenInvoiceNumberLabel;

  /// No description provided for @buyScreenPurchaseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get buyScreenPurchaseDateLabel;

  /// No description provided for @buyScreenVendorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get buyScreenVendorLabel;

  /// No description provided for @buyScreenVendorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor Name (if not listed above)'**
  String get buyScreenVendorNameLabel;

  /// No description provided for @buyScreenPurchaseSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Summary'**
  String get buyScreenPurchaseSummaryTitle;

  /// No description provided for @buyScreenNoItemsSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'No items selected'**
  String get buyScreenNoItemsSelectedTitle;

  /// No description provided for @buyScreenNoItemsSelectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Click the button below to add products'**
  String get buyScreenNoItemsSelectedSubtitle;

  /// No description provided for @buyScreenAddProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Products'**
  String get buyScreenAddProductsLabel;

  /// No description provided for @buyScreenAddMoreProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Add More Products'**
  String get buyScreenAddMoreProductsLabel;

  /// No description provided for @buyScreenSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal:'**
  String get buyScreenSubtotalLabel;

  /// No description provided for @buyScreenVatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT:'**
  String get buyScreenVatLabel;

  /// No description provided for @buyScreenTotalPurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Purchase:'**
  String get buyScreenTotalPurchaseLabel;

  /// No description provided for @buyScreenClearPurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Purchase'**
  String get buyScreenClearPurchaseLabel;

  /// No description provided for @buyScreenSavePurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Purchase'**
  String get buyScreenSavePurchaseLabel;

  /// No description provided for @buyScreenSupplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get buyScreenSupplierLabel;

  /// No description provided for @buyScreenReturnBillNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter Bill Number'**
  String get buyScreenReturnBillNumberLabel;

  /// No description provided for @buyScreenReturnBillNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. PB-POS-...'**
  String get buyScreenReturnBillNumberHint;

  /// No description provided for @buyScreenReturnBillLookupButton.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get buyScreenReturnBillLookupButton;

  /// No description provided for @buyScreenReturnBillLookupLoading.
  ///
  /// In en, this message translates to:
  /// **'Looking up bill...'**
  String get buyScreenReturnBillLookupLoading;

  /// No description provided for @buyScreenReturnBillLookupNotFound.
  ///
  /// In en, this message translates to:
  /// **'No posted bill found for that number.'**
  String get buyScreenReturnBillLookupNotFound;

  /// No description provided for @buyScreenReturnBillLookupFound.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} item{plural} from bill {billNo}'**
  String buyScreenReturnBillLookupFound(
    int count,
    String plural,
    String billNo,
  );

  /// No description provided for @buyScreenReturnItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Return Items'**
  String get buyScreenReturnItemsTitle;

  /// No description provided for @buyScreenNoItemsToReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'No items to return'**
  String get buyScreenNoItemsToReturnTitle;

  /// No description provided for @buyScreenTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get buyScreenTotalAmountLabel;

  /// No description provided for @buyScreenClearReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Return'**
  String get buyScreenClearReturnLabel;

  /// No description provided for @buyScreenPostReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Post Return'**
  String get buyScreenPostReturnLabel;

  /// No description provided for @othersScreenResetSystemDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset System'**
  String get othersScreenResetSystemDialogTitle;

  /// No description provided for @othersScreenResetSystemDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This refreshes company, outlet, and product data from the server. Continue?'**
  String get othersScreenResetSystemDialogContent;

  /// No description provided for @othersScreenCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get othersScreenCancelButton;

  /// No description provided for @othersScreenResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get othersScreenResetButton;

  /// No description provided for @othersScreenRefreshSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'System refreshed with the latest data.'**
  String get othersScreenRefreshSuccessMessage;

  /// No description provided for @othersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get othersScreenTitle;

  /// No description provided for @othersScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System settings and POS controls'**
  String get othersScreenSubtitle;

  /// No description provided for @othersScreenPosConfigurationHeader.
  ///
  /// In en, this message translates to:
  /// **'POS Configuration'**
  String get othersScreenPosConfigurationHeader;

  /// No description provided for @othersScreenCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get othersScreenCompanyLabel;

  /// No description provided for @othersScreenOutletLabel.
  ///
  /// In en, this message translates to:
  /// **'Outlet'**
  String get othersScreenOutletLabel;

  /// No description provided for @othersScreenFiscalYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Fiscal Year'**
  String get othersScreenFiscalYearLabel;

  /// No description provided for @othersScreenWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get othersScreenWarehouseLabel;

  /// No description provided for @othersScreenLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get othersScreenLogoutButton;

  /// No description provided for @othersScreenResetSystemButton.
  ///
  /// In en, this message translates to:
  /// **'Reset System'**
  String get othersScreenResetSystemButton;

  /// No description provided for @othersScreenAccountHeader.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get othersScreenAccountHeader;

  /// No description provided for @othersScreenChangePasswordTile.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get othersScreenChangePasswordTile;

  /// No description provided for @othersScreenChangePasswordTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your login password'**
  String get othersScreenChangePasswordTileSubtitle;

  /// No description provided for @changePasswordScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordScreenTitle;

  /// No description provided for @changePasswordScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new one.'**
  String get changePasswordScreenSubtitle;

  /// No description provided for @changePasswordScreenCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get changePasswordScreenCurrentPasswordLabel;

  /// No description provided for @changePasswordScreenNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordScreenNewPasswordLabel;

  /// No description provided for @changePasswordScreenConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordScreenConfirmPasswordLabel;

  /// No description provided for @changePasswordScreenCurrentPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Current password is required.'**
  String get changePasswordScreenCurrentPasswordRequiredError;

  /// No description provided for @changePasswordScreenNewPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters.'**
  String get changePasswordScreenNewPasswordLengthError;

  /// No description provided for @changePasswordScreenConfirmPasswordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get changePasswordScreenConfirmPasswordMismatchError;

  /// No description provided for @changePasswordScreenSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get changePasswordScreenSubmitButton;

  /// No description provided for @changePasswordScreenSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get changePasswordScreenSuccessMessage;

  /// No description provided for @languageCardHeader.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageCardHeader;

  /// No description provided for @voicePromptCardHeader.
  ///
  /// In en, this message translates to:
  /// **'POS Voice Prompt'**
  String get voicePromptCardHeader;

  /// No description provided for @voicePromptSoundStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound Status'**
  String get voicePromptSoundStatusLabel;

  /// No description provided for @voicePromptOnLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get voicePromptOnLabel;

  /// No description provided for @voicePromptOffLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get voicePromptOffLabel;

  /// No description provided for @voicePromptAnnouncementLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Announcement Language'**
  String get voicePromptAnnouncementLanguageLabel;

  /// No description provided for @voicePromptVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get voicePromptVolumeLabel;

  /// No description provided for @voicePromptHelperText.
  ///
  /// In en, this message translates to:
  /// **'Plays only inside POS when switching between Sell, Buy, Reports, and Others.'**
  String get voicePromptHelperText;

  /// No description provided for @voicePromptTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test Voice Prompt'**
  String get voicePromptTestButton;

  /// No description provided for @reportsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsScreenTitle;

  /// No description provided for @reportsScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sales & Inventory Reports'**
  String get reportsScreenSubtitle;

  /// No description provided for @reportsScreenPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period:'**
  String get reportsScreenPeriodLabel;

  /// No description provided for @reportsScreenChangeDateRangeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change date range'**
  String get reportsScreenChangeDateRangeTooltip;

  /// No description provided for @reportsScreenPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reportsScreenPeriodToday;

  /// No description provided for @reportsScreenPeriodYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get reportsScreenPeriodYesterday;

  /// No description provided for @reportsScreenPeriodLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get reportsScreenPeriodLast7Days;

  /// No description provided for @reportsScreenPeriodLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get reportsScreenPeriodLast30Days;

  /// No description provided for @reportsScreenPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get reportsScreenPeriodThisMonth;

  /// No description provided for @reportsScreenPeriodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get reportsScreenPeriodLastMonth;

  /// No description provided for @reportsScreenPeriodLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get reportsScreenPeriodLifetime;

  /// No description provided for @reportsScreenPeriodCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get reportsScreenPeriodCustomRange;

  /// No description provided for @reportsScreenTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get reportsScreenTabOverview;

  /// No description provided for @reportsScreenTabStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get reportsScreenTabStores;

  /// No description provided for @reportsScreenTabVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get reportsScreenTabVendors;

  /// No description provided for @reportsScreenTabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get reportsScreenTabCustomers;

  /// No description provided for @reportsScreenTabVendorSales.
  ///
  /// In en, this message translates to:
  /// **'Vendor Sales'**
  String get reportsScreenTabVendorSales;

  /// No description provided for @reportsScreenTabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get reportsScreenTabMore;

  /// No description provided for @reportsScreenSalesPurchasesTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales vs Purchases Trend'**
  String get reportsScreenSalesPurchasesTrendTitle;

  /// No description provided for @reportsScreenTopProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Products · {period}'**
  String reportsScreenTopProductsTitle(String period);

  /// No description provided for @reportsScreenPaymentModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales by Payment Mode · {period}'**
  String reportsScreenPaymentModeTitle(String period);

  /// No description provided for @reportsScreenRecentSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Sales'**
  String get reportsScreenRecentSalesTitle;

  /// No description provided for @reportsScreenRecentPurchasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Purchases'**
  String get reportsScreenRecentPurchasesTitle;

  /// No description provided for @reportsScreenMonthlySalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Sales (incl. Returns)'**
  String get reportsScreenMonthlySalesTitle;

  /// No description provided for @reportsScreenGrossSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Gross Sales'**
  String get reportsScreenGrossSalesLabel;

  /// No description provided for @reportsScreenSalesReturnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales Returns'**
  String get reportsScreenSalesReturnsLabel;

  /// No description provided for @reportsScreenNetSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Sales'**
  String get reportsScreenNetSalesLabel;

  /// No description provided for @reportsScreenInvoicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} invoices'**
  String reportsScreenInvoicesCount(int count);

  /// No description provided for @reportsScreenMonthlyPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Purchase (incl. Returns)'**
  String get reportsScreenMonthlyPurchaseTitle;

  /// No description provided for @reportsScreenGrossPurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Gross Purchase'**
  String get reportsScreenGrossPurchaseLabel;

  /// No description provided for @reportsScreenPurchaseReturnsLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Returns'**
  String get reportsScreenPurchaseReturnsLabel;

  /// No description provided for @reportsScreenNetPurchaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Purchase'**
  String get reportsScreenNetPurchaseLabel;

  /// No description provided for @reportsScreenGrnCount.
  ///
  /// In en, this message translates to:
  /// **'{count} GRNs'**
  String reportsScreenGrnCount(int count);

  /// No description provided for @reportsScreenTotalSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get reportsScreenTotalSalesTitle;

  /// No description provided for @reportsScreenPostedInvoicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} posted invoices · {period}'**
  String reportsScreenPostedInvoicesSubtitle(int count, String period);

  /// No description provided for @reportsScreenTotalPurchasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get reportsScreenTotalPurchasesTitle;

  /// No description provided for @reportsScreenPostedStockIntakesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} posted stock intakes · {period}'**
  String reportsScreenPostedStockIntakesSubtitle(int count, String period);

  /// No description provided for @reportsScreenStockValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get reportsScreenStockValueTitle;

  /// No description provided for @reportsScreenCurrentInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current inventory on hand'**
  String get reportsScreenCurrentInventorySubtitle;

  /// No description provided for @reportsScreenVatCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'VAT Collected'**
  String get reportsScreenVatCollectedTitle;

  /// No description provided for @reportsScreenNetTaxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Net tax NPR {amount}'**
  String reportsScreenNetTaxSubtitle(String amount);

  /// No description provided for @reportsScreenVatPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'VAT Paid'**
  String get reportsScreenVatPaidTitle;

  /// No description provided for @reportsScreenPostedPurchaseBillsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On posted purchase bills · {period}'**
  String reportsScreenPostedPurchaseBillsSubtitle(String period);

  /// No description provided for @posScreenHeaderLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get posScreenHeaderLanguageEnglish;

  /// No description provided for @posScreenHeaderLanguageNepali.
  ///
  /// In en, this message translates to:
  /// **'नेपाली (Nepali)'**
  String get posScreenHeaderLanguageNepali;

  /// No description provided for @cartPanelHeaderItemsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Items: {itemCount} | Total: NPR {total}'**
  String cartPanelHeaderItemsTotalLabel(int itemCount, String total);

  /// No description provided for @productPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get productPickerTitle;

  /// No description provided for @productPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select products to add to the current sale'**
  String get productPickerSubtitle;

  /// No description provided for @productPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get productPickerSearchHint;

  /// No description provided for @productPickerCategoryProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productPickerCategoryProducts;

  /// No description provided for @productPickerCategoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get productPickerCategoryAccessories;

  /// No description provided for @productPickerCategoryServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get productPickerCategoryServices;

  /// No description provided for @productPickerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No records found'**
  String get productPickerEmptyTitle;

  /// No description provided for @productPickerEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No products in this category yet.'**
  String get productPickerEmptySubtitle;

  /// No description provided for @productPickerCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get productPickerCloseButton;

  /// No description provided for @productCardStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {stock}'**
  String productCardStockLabel(String stock);

  /// No description provided for @productCardNotTracked.
  ///
  /// In en, this message translates to:
  /// **'Not tracked'**
  String get productCardNotTracked;

  /// No description provided for @productCardOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productCardOutOfStock;

  /// No description provided for @customerPickerFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get customerPickerFullNameRequired;

  /// No description provided for @customerPickerVatFormatError.
  ///
  /// In en, this message translates to:
  /// **'VAT number must be exactly 9 digits.'**
  String get customerPickerVatFormatError;

  /// No description provided for @customerPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerPickerTitle;

  /// No description provided for @customerPickerExistingCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Existing Customer'**
  String get customerPickerExistingCustomerLabel;

  /// No description provided for @customerPickerWalkInHint.
  ///
  /// In en, this message translates to:
  /// **'Or create a new walk-in customer below'**
  String get customerPickerWalkInHint;

  /// No description provided for @customerPickerFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get customerPickerFullNameLabel;

  /// No description provided for @customerPickerPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get customerPickerPhoneNumberLabel;

  /// No description provided for @customerPickerVatNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT Number'**
  String get customerPickerVatNumberLabel;

  /// No description provided for @customerPickerDeliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get customerPickerDeliveryAddressLabel;

  /// No description provided for @customerPickerCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get customerPickerCancelButton;

  /// No description provided for @customerPickerUseCustomerButton.
  ///
  /// In en, this message translates to:
  /// **'Use Customer'**
  String get customerPickerUseCustomerButton;

  /// No description provided for @cartLineQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get cartLineQtyLabel;

  /// No description provided for @cartLineRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get cartLineRateLabel;

  /// No description provided for @cartLineTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartLineTotalLabel;

  /// No description provided for @purchaseCartLineUnitCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Cost'**
  String get purchaseCartLineUnitCostLabel;

  /// No description provided for @paymentTypeSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get paymentTypeSectionHeader;

  /// No description provided for @paymentTypeSectionCashSaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash Sale'**
  String get paymentTypeSectionCashSaleLabel;

  /// No description provided for @paymentTypeSectionCreditSaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit Sale'**
  String get paymentTypeSectionCreditSaleLabel;

  /// No description provided for @paymentTypeSectionOnlinePaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get paymentTypeSectionOnlinePaymentLabel;

  /// No description provided for @paymentTypeSectionRemarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get paymentTypeSectionRemarksLabel;

  /// No description provided for @paymentTypeSectionRemarksHint.
  ///
  /// In en, this message translates to:
  /// **'Optional remarks for this cash sale'**
  String get paymentTypeSectionRemarksHint;

  /// No description provided for @paymentTypeSectionReferenceNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference No.'**
  String get paymentTypeSectionReferenceNoLabel;

  /// No description provided for @paymentTypeSectionReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID / Ref. No.'**
  String get paymentTypeSectionReferenceHint;

  /// No description provided for @paymentTypeSectionPaymentNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Note'**
  String get paymentTypeSectionPaymentNoteLabel;

  /// No description provided for @paymentTypeSectionPaymentNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Wallet, bank, mobile number'**
  String get paymentTypeSectionPaymentNoteHint;

  /// No description provided for @totalsBlockSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal:'**
  String get totalsBlockSubtotalLabel;

  /// No description provided for @totalsBlockVatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT (13%):'**
  String get totalsBlockVatLabel;

  /// No description provided for @totalsBlockDeliveryChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge:'**
  String get totalsBlockDeliveryChargeLabel;

  /// No description provided for @totalsBlockTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalsBlockTotalAmountLabel;

  /// No description provided for @invoicePreviewInvoiceNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice No'**
  String get invoicePreviewInvoiceNoLabel;

  /// No description provided for @invoicePreviewRefNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Ref. No.'**
  String get invoicePreviewRefNoLabel;

  /// No description provided for @invoicePreviewInvoiceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice Date'**
  String get invoicePreviewInvoiceDateLabel;

  /// No description provided for @invoicePreviewCounterNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Counter No.'**
  String get invoicePreviewCounterNoLabel;

  /// No description provided for @invoicePreviewCustomerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get invoicePreviewCustomerNameLabel;

  /// No description provided for @invoicePreviewWalkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get invoicePreviewWalkInCustomer;

  /// No description provided for @invoicePreviewPaymentModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Mode'**
  String get invoicePreviewPaymentModeLabel;

  /// No description provided for @invoicePreviewCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get invoicePreviewCashLabel;

  /// No description provided for @invoicePreviewCreditLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get invoicePreviewCreditLabel;

  /// No description provided for @invoicePreviewCustomerPanLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Pan'**
  String get invoicePreviewCustomerPanLabel;

  /// No description provided for @invoicePreviewPaymentRefLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Ref.'**
  String get invoicePreviewPaymentRefLabel;

  /// No description provided for @invoicePreviewPaymentNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Note'**
  String get invoicePreviewPaymentNoteLabel;

  /// No description provided for @invoicePreviewSignatureCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get invoicePreviewSignatureCustomerLabel;

  /// No description provided for @invoicePreviewPrintButton.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get invoicePreviewPrintButton;

  /// No description provided for @invoicePreviewShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get invoicePreviewShareButton;

  /// No description provided for @invoicePreviewCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get invoicePreviewCloseButton;

  /// No description provided for @purchaseInvoicePreviewBillNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill No'**
  String get purchaseInvoicePreviewBillNoLabel;

  /// No description provided for @purchaseInvoicePreviewVendorInvNoLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor Inv. No.'**
  String get purchaseInvoicePreviewVendorInvNoLabel;

  /// No description provided for @purchaseInvoicePreviewBillDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill Date'**
  String get purchaseInvoicePreviewBillDateLabel;

  /// No description provided for @purchaseInvoicePreviewMrnNoLabel.
  ///
  /// In en, this message translates to:
  /// **'MRN No.'**
  String get purchaseInvoicePreviewMrnNoLabel;

  /// No description provided for @purchaseInvoicePreviewVendorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor Name'**
  String get purchaseInvoicePreviewVendorNameLabel;

  /// No description provided for @purchaseInvoicePreviewVendorPanLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor Pan'**
  String get purchaseInvoicePreviewVendorPanLabel;

  /// No description provided for @purchaseInvoicePreviewSignatureSupplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get purchaseInvoicePreviewSignatureSupplierLabel;

  /// No description provided for @purchaseInvoicePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'PURCHASE INVOICE'**
  String get purchaseInvoicePreviewTitle;

  /// No description provided for @purchaseInvoicePreviewShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get purchaseInvoicePreviewShareButton;

  /// No description provided for @purchaseInvoicePreviewCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get purchaseInvoicePreviewCloseButton;

  /// No description provided for @posInvoicePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone No : {phone}'**
  String posInvoicePhoneLabel(String phone);

  /// No description provided for @posInvoiceVatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT # : {vatNo}'**
  String posInvoiceVatLabel(String vatNo);

  /// No description provided for @posInvoiceDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'TAX INVOICE'**
  String get posInvoiceDefaultTitle;

  /// No description provided for @posInvoiceSrHeader.
  ///
  /// In en, this message translates to:
  /// **'Sr.'**
  String get posInvoiceSrHeader;

  /// No description provided for @posInvoiceHsCodeHeader.
  ///
  /// In en, this message translates to:
  /// **'H.S. Code'**
  String get posInvoiceHsCodeHeader;

  /// No description provided for @posInvoiceDescriptionHeader.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get posInvoiceDescriptionHeader;

  /// No description provided for @posInvoiceQtyHeader.
  ///
  /// In en, this message translates to:
  /// **'Qty.'**
  String get posInvoiceQtyHeader;

  /// No description provided for @posInvoiceRateHeader.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get posInvoiceRateHeader;

  /// No description provided for @posInvoiceTotalAmtHeader.
  ///
  /// In en, this message translates to:
  /// **'Total Amt.'**
  String get posInvoiceTotalAmtHeader;

  /// No description provided for @posInvoicePrintDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Print Date/Time :'**
  String get posInvoicePrintDateTimeLabel;

  /// No description provided for @posInvoiceNepaliDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Nepali Date :'**
  String get posInvoiceNepaliDateLabel;

  /// No description provided for @posInvoiceOriginalLabel.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get posInvoiceOriginalLabel;

  /// No description provided for @posInvoiceTaxableLabel.
  ///
  /// In en, this message translates to:
  /// **'Taxable :'**
  String get posInvoiceTaxableLabel;

  /// No description provided for @posInvoiceNonTaxableLabel.
  ///
  /// In en, this message translates to:
  /// **'Non Taxable :'**
  String get posInvoiceNonTaxableLabel;

  /// No description provided for @posInvoiceSubTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Sub Total :'**
  String get posInvoiceSubTotalLabel;

  /// No description provided for @posInvoiceDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount : 0 %'**
  String get posInvoiceDiscountLabel;

  /// No description provided for @posInvoiceVatAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT Amount :'**
  String get posInvoiceVatAmountLabel;

  /// No description provided for @posInvoiceVatAmountWithRateLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT Amount ({rate}) :'**
  String posInvoiceVatAmountWithRateLabel(String rate);

  /// No description provided for @posInvoiceNetTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Total :'**
  String get posInvoiceNetTotalLabel;

  /// No description provided for @posInvoicePreparedByFallback.
  ///
  /// In en, this message translates to:
  /// **'Prepared By'**
  String get posInvoicePreparedByFallback;

  /// No description provided for @posInvoicePrepareByLabel.
  ///
  /// In en, this message translates to:
  /// **'Prepare By'**
  String get posInvoicePrepareByLabel;

  /// No description provided for @recentTransactionsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No transactions for this period'**
  String get recentTransactionsEmptyMessage;

  /// No description provided for @topProductsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No sales for this period'**
  String get topProductsEmptyMessage;

  /// No description provided for @salesTrendChartNoDataMessage.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get salesTrendChartNoDataMessage;

  /// No description provided for @salesTrendChartSalesLegend.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesTrendChartSalesLegend;

  /// No description provided for @salesTrendChartPurchasesLegend.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get salesTrendChartPurchasesLegend;

  /// No description provided for @paymentModePieChartNoSalesMessage.
  ///
  /// In en, this message translates to:
  /// **'No sales for this period'**
  String get paymentModePieChartNoSalesMessage;

  /// No description provided for @breakdownChartListNoDataMessage.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get breakdownChartListNoDataMessage;

  /// No description provided for @breakdownChartListVatLabel.
  ///
  /// In en, this message translates to:
  /// **'VAT: {vatNo}'**
  String breakdownChartListVatLabel(String vatNo);

  /// No description provided for @breakdownChartListTransactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} txns'**
  String breakdownChartListTransactionsCount(int count);

  /// No description provided for @printerCardHeader.
  ///
  /// In en, this message translates to:
  /// **'Printer Connection'**
  String get printerCardHeader;

  /// No description provided for @printerCardNoPrinterMessage.
  ///
  /// In en, this message translates to:
  /// **'No printer selected. Choose a paired Bluetooth printer to print bills directly.'**
  String get printerCardNoPrinterMessage;

  /// No description provided for @printerCardForgetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove printer'**
  String get printerCardForgetTooltip;

  /// No description provided for @printerCardPaperSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Paper Size'**
  String get printerCardPaperSizeLabel;

  /// No description provided for @printerCardPaperSize58Label.
  ///
  /// In en, this message translates to:
  /// **'58 mm (2 inch)'**
  String get printerCardPaperSize58Label;

  /// No description provided for @printerCardPaperSize80Label.
  ///
  /// In en, this message translates to:
  /// **'80 mm (3 inch)'**
  String get printerCardPaperSize80Label;

  /// No description provided for @printerCardSelectPrinterButton.
  ///
  /// In en, this message translates to:
  /// **'Select Printer'**
  String get printerCardSelectPrinterButton;

  /// No description provided for @printerCardChangePrinterButton.
  ///
  /// In en, this message translates to:
  /// **'Change Printer'**
  String get printerCardChangePrinterButton;

  /// No description provided for @printerCardTestPrintButton.
  ///
  /// In en, this message translates to:
  /// **'Test Print'**
  String get printerCardTestPrintButton;

  /// No description provided for @printerCardHelperText.
  ///
  /// In en, this message translates to:
  /// **'Pair the thermal printer in your phone\'s Bluetooth settings first, then select it here. Bills print on it directly from the invoice preview.'**
  String get printerCardHelperText;

  /// No description provided for @printerTestPrintSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Test print sent to printer'**
  String get printerTestPrintSentMessage;

  /// No description provided for @printerPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Bluetooth Printer'**
  String get printerPickerTitle;

  /// No description provided for @printerPickerRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh list'**
  String get printerPickerRefreshTooltip;

  /// No description provided for @printerPickerNoDevicesMessage.
  ///
  /// In en, this message translates to:
  /// **'No paired Bluetooth devices found. Pair the printer in your phone\'s Bluetooth settings and refresh.'**
  String get printerPickerNoDevicesMessage;

  /// No description provided for @printerPickerHelperText.
  ///
  /// In en, this message translates to:
  /// **'Tap a printer to save it for bill printing.'**
  String get printerPickerHelperText;

  /// No description provided for @printerPrintingMessage.
  ///
  /// In en, this message translates to:
  /// **'Printing bill…'**
  String get printerPrintingMessage;

  /// No description provided for @printerPrintSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Bill sent to printer'**
  String get printerPrintSuccessMessage;

  /// No description provided for @printerErrorBluetoothOff.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is turned off. Turn it on and try again.'**
  String get printerErrorBluetoothOff;

  /// No description provided for @printerErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission denied. Allow Bluetooth access for this app in settings.'**
  String get printerErrorPermissionDenied;

  /// No description provided for @printerErrorNoPrinterSelected.
  ///
  /// In en, this message translates to:
  /// **'No printer selected. Choose a printer first.'**
  String get printerErrorNoPrinterSelected;

  /// No description provided for @printerErrorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the printer. Make sure it is switched on and in range.'**
  String get printerErrorConnectionFailed;

  /// No description provided for @printerErrorPrintFailed.
  ///
  /// In en, this message translates to:
  /// **'Printing failed. Check the printer and try again.'**
  String get printerErrorPrintFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
