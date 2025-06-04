import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Zoozi Wallet'**
  String get appName;

  /// Welcome message shown on the home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zoozi Wallet'**
  String get welcome;

  /// Welcome back message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back\nto Zoozi wallet'**
  String get welcomeBack;

  /// Create account message on register screen
  ///
  /// In en, this message translates to:
  /// **'Create an account\nit\'s free and easy'**
  String get createAccount;

  /// Login text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Sign up text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Text asking if user has account
  ///
  /// In en, this message translates to:
  /// **'You have account? '**
  String get haveAccount;

  /// Text asking if user doesn't have account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? '**
  String get dontHaveAccount;

  /// Error message when email is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Error message when email is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// Error message when password is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Error message when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordLength;

  /// Error message when name is empty
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Error message when name is too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameLength;

  /// Error message when confirm password is empty
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// Error message when passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Security setting label
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// About setting label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Error message for unauthorized access
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access. Please login again.'**
  String get unauthorizedError;

  /// Error message for invalid credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get invalidCredentialsError;

  /// Error message for resource not found
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get notFoundError;

  /// Error message for internal server error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get internalServerError;

  /// Error message for unknown errors
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownError;

  /// Error message for password length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long.'**
  String get passwordLengthError;

  /// Error message for invalid currency
  ///
  /// In en, this message translates to:
  /// **'Invalid currency. Please select USD, EUR, or GBP.'**
  String get invalidCurrencyError;

  /// Error message for password type validation
  ///
  /// In en, this message translates to:
  /// **'Password must be text.'**
  String get passwordTypeError;

  /// Error message for amount validation
  ///
  /// In en, this message translates to:
  /// **'Amount must be a valid positive number.'**
  String get amountValidationError;

  /// Error message for invalid JSON format
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON format. Please check your input.'**
  String get invalidJsonError;

  /// Error message for network errors
  ///
  /// In en, this message translates to:
  /// **'Network error occurred. Please check your connection.'**
  String get networkError;

  /// Error message for request timeout
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get requestTimeout;

  /// Error message for forbidden access
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this resource.'**
  String get forbiddenError;

  /// Error message for bad request
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input.'**
  String get badRequestError;

  /// Error message for validation errors
  ///
  /// In en, this message translates to:
  /// **'Validation failed. Please check your input.'**
  String get validationError;

  /// Error message for cache read errors
  ///
  /// In en, this message translates to:
  /// **'Failed to read {key} from cache.'**
  String cacheReadError(String key);

  /// Error message for cache write errors
  ///
  /// In en, this message translates to:
  /// **'Failed to write {key} to cache.'**
  String cacheWriteError(String key);

  /// Error message for cache delete errors
  ///
  /// In en, this message translates to:
  /// **'Failed to delete {key} from cache.'**
  String cacheDeleteError(String key);

  /// Error message for cache clear operation
  ///
  /// In en, this message translates to:
  /// **'Failed to clear storage data.'**
  String get cacheClearError;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Theme selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Indonesian language option
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// Title for the wallets list screen
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get myWallets;

  /// Message shown when no wallets are available
  ///
  /// In en, this message translates to:
  /// **'No wallets found'**
  String get noWalletsFound;

  /// Message encouraging user to add a wallet
  ///
  /// In en, this message translates to:
  /// **'Add one to get started!'**
  String get addWalletToStart;

  /// Button text to add a new wallet
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get addWallet;

  /// Title for the wallet details screen
  ///
  /// In en, this message translates to:
  /// **'Wallet Details'**
  String get walletDetails;

  /// Button text for deposit action
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// Button text for withdraw action
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// Button text for transfer action
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// Title for recent transactions list
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Title for add wallet screen
  ///
  /// In en, this message translates to:
  /// **'Add New Wallet'**
  String get addNewWallet;

  /// Section title for wallet information
  ///
  /// In en, this message translates to:
  /// **'Wallet Information'**
  String get walletInformation;

  /// Label for wallet name input
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get walletName;

  /// Validation message for wallet name
  ///
  /// In en, this message translates to:
  /// **'Please enter a wallet name'**
  String get pleaseEnterWalletName;

  /// Label for initial balance input
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// Validation message for initial balance
  ///
  /// In en, this message translates to:
  /// **'Please enter initial balance'**
  String get pleaseEnterInitialBalance;

  /// Validation message for number input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Button text to create a new wallet
  ///
  /// In en, this message translates to:
  /// **'Create Wallet'**
  String get createWallet;

  /// Success message after creating a wallet
  ///
  /// In en, this message translates to:
  /// **'Wallet created successfully!'**
  String get walletCreatedSuccessfully;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Title for transactions screen
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Error message when wallets fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load wallets'**
  String get failedToLoadWallets;

  /// Button text to try again
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Label for wallet card
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get myWallet;

  /// Label for current balance
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// Wallet ID label
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String walletId(String id);

  /// Label showing last update time
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updated(String time);

  /// Time format for days ago
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// Time format for hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// Time format for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// Time format for just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Label for total income stat
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// Label for total expense stat
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// Button text to view all items
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Message when no transactions exist
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// Subtitle for empty transactions
  ///
  /// In en, this message translates to:
  /// **'Your transactions will appear here'**
  String get transactionsWillAppearHere;

  /// Message when all transactions are loaded
  ///
  /// In en, this message translates to:
  /// **'All transactions loaded'**
  String get allTransactionsLoaded;

  /// Shows total transaction count
  ///
  /// In en, this message translates to:
  /// **'{count} transaction{suffix} in total'**
  String transactionInTotal(int count, String suffix);

  /// Error title message
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// Menu option to edit wallet
  ///
  /// In en, this message translates to:
  /// **'Edit Wallet'**
  String get editWallet;

  /// Menu option for transaction history
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// Menu option for wallet settings
  ///
  /// In en, this message translates to:
  /// **'Wallet Settings'**
  String get walletSettings;

  /// Loading message for transactions
  ///
  /// In en, this message translates to:
  /// **'Loading transactions...'**
  String get loadingTransactions;

  /// Loading message for pagination
  ///
  /// In en, this message translates to:
  /// **'Loading more transactions...'**
  String get loadingMoreTransactions;

  /// Pull to refresh instruction
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// Refreshing status message
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// Title for all transactions page
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// Filter transactions option
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterTransactions;

  /// Button to create new transaction
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransaction;

  /// Deposit page title
  ///
  /// In en, this message translates to:
  /// **'Deposit Money'**
  String get depositMoney;

  /// Withdraw page title
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money'**
  String get withdrawMoney;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Amount field hint
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Description field hint
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get enterDescription;

  /// Reference ID field label
  ///
  /// In en, this message translates to:
  /// **'Reference ID'**
  String get referenceId;

  /// Reference ID field hint
  ///
  /// In en, this message translates to:
  /// **'Enter reference ID (optional)'**
  String get enterReferenceId;

  /// Proceed button text
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// Processing status message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Success message for completed transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction Successful!'**
  String get transactionSuccessful;

  /// Error message for failed transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed'**
  String get transactionFailed;

  /// Validation message for amount field
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// Validation message for invalid amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// Validation message for minimum amount
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is {amount}'**
  String minimumAmount(String amount);

  /// Validation message for maximum amount
  ///
  /// In en, this message translates to:
  /// **'Maximum amount is {amount}'**
  String maximumAmount(String amount);

  /// Error message for insufficient balance
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// Shows available balance
  ///
  /// In en, this message translates to:
  /// **'Available Balance: {balance}'**
  String availableBalance(String balance);

  /// Confirm transaction dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Transaction'**
  String get confirmTransaction;

  /// Confirm deposit message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deposit {amount}?'**
  String confirmDepositMessage(String amount);

  /// Confirm withdraw message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw {amount}?'**
  String confirmWithdrawMessage(String amount);

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Transaction details title
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// Transaction type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactionType;

  /// Transaction date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionDate;

  /// Transaction reference label
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get transactionReference;

  /// No reference available text
  ///
  /// In en, this message translates to:
  /// **'No Reference'**
  String get noReference;

  /// Income transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Filter by type option
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
  String get filterByType;

  /// Filter by date option
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// All transaction types filter option
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// Last 7 days filter option
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// Last 30 days filter option
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// This month filter option
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Custom date range filter option
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// Apply filter button text
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// Clear filter button text
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Default welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zoozi Wallet'**
  String get welcomeToZooziWallet;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Welcome back message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome back,\n{userName}!'**
  String welcomeBackUser(String userName);

  /// Wallet overview subtitle
  ///
  /// In en, this message translates to:
  /// **'Here\'s your wallet overview'**
  String get walletOverview;

  /// Total balance card title
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No wallets available message
  ///
  /// In en, this message translates to:
  /// **'No wallets'**
  String get noWallets;

  /// Last updated timestamp
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Transfer feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Transfer feature coming soon!'**
  String get transferFeatureComingSoon;

  /// Empty wallet chart message
  ///
  /// In en, this message translates to:
  /// **'No wallets to display'**
  String get noWalletsToDisplay;

  /// Wallet distribution chart title
  ///
  /// In en, this message translates to:
  /// **'Wallet Distribution'**
  String get walletDistribution;

  /// Empty wallet list title
  ///
  /// In en, this message translates to:
  /// **'No wallets yet'**
  String get noWalletsYet;

  /// Empty wallet list subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your first wallet to get started'**
  String get createFirstWallet;

  /// Mock transaction title
  ///
  /// In en, this message translates to:
  /// **'Deposit to Main Wallet'**
  String get depositToMainWallet;

  /// Mock transaction title
  ///
  /// In en, this message translates to:
  /// **'Transfer to Savings'**
  String get transferToSavings;

  /// Mock transaction title
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// Mock transactions footer message
  ///
  /// In en, this message translates to:
  /// **'Connect to API to see real transactions'**
  String get connectToApiMessage;

  /// Logout confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// Logout confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationMessage;

  /// Logging out progress message
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// Message shown when registration is successful but user needs to login manually
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login to continue.'**
  String get registrationSuccessfulPleaseLogin;

  /// Message shown in logout dialog about redirecting to login page
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to the login page.'**
  String get logoutRedirectMessage;

  /// Currency field label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Currency validation message
  ///
  /// In en, this message translates to:
  /// **'Please select a currency'**
  String get pleaseSelectCurrency;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
