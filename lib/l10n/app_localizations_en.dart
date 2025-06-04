// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Zoozi Wallet';

  @override
  String get welcome => 'Welcome to Zoozi Wallet';

  @override
  String get welcomeBack => 'Welcome back\nto Zoozi wallet';

  @override
  String get createAccount => 'Create an account\nit\'s free and easy';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get signUp => 'Sign up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get haveAccount => 'You have account? ';

  @override
  String get dontHaveAccount => 'Don\'t have an account yet? ';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordLength => 'Password must be at least 8 characters';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameLength => 'Name must be at least 3 characters';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get unauthorizedError => 'Unauthorized access. Please login again.';

  @override
  String get invalidCredentialsError =>
      'Invalid email or password. Please try again.';

  @override
  String get notFoundError => 'The requested resource was not found.';

  @override
  String get internalServerError =>
      'Something went wrong. Please try again later.';

  @override
  String get unknownError => 'An unexpected error occurred. Please try again.';

  @override
  String get passwordLengthError =>
      'Password must be at least 8 characters long.';

  @override
  String get invalidCurrencyError =>
      'Invalid currency. Please select USD, EUR, or GBP.';

  @override
  String get passwordTypeError => 'Password must be text.';

  @override
  String get amountValidationError => 'Amount must be a valid positive number.';

  @override
  String get invalidJsonError =>
      'Invalid JSON format. Please check your input.';

  @override
  String get networkError =>
      'Network error occurred. Please check your connection.';

  @override
  String get requestTimeout => 'Request timed out. Please try again.';

  @override
  String get forbiddenError =>
      'You don\'t have permission to access this resource.';

  @override
  String get badRequestError => 'Invalid request. Please check your input.';

  @override
  String get validationError => 'Validation failed. Please check your input.';

  @override
  String cacheReadError(String key) {
    return 'Failed to read $key from cache.';
  }

  @override
  String cacheWriteError(String key) {
    return 'Failed to write $key to cache.';
  }

  @override
  String cacheDeleteError(String key) {
    return 'Failed to delete $key from cache.';
  }

  @override
  String get cacheClearError => 'Failed to clear storage data.';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get english => 'English';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get myWallets => 'My Wallets';

  @override
  String get noWalletsFound => 'No wallets found';

  @override
  String get addWalletToStart => 'Add one to get started!';

  @override
  String get addWallet => 'Add Wallet';

  @override
  String get walletDetails => 'Wallet Details';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get transfer => 'Transfer';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get addNewWallet => 'Add New Wallet';

  @override
  String get walletInformation => 'Wallet Information';

  @override
  String get walletName => 'Wallet Name';

  @override
  String get pleaseEnterWalletName => 'Please enter a wallet name';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get pleaseEnterInitialBalance => 'Please enter initial balance';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get createWallet => 'Create Wallet';

  @override
  String get walletCreatedSuccessfully => 'Wallet created successfully!';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get transactions => 'Transactions';

  @override
  String get failedToLoadWallets => 'Failed to load wallets';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get myWallet => 'My Wallet';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String walletId(String id) {
    return 'Wallet ID: $id';
  }

  @override
  String updated(String time) {
    return 'Updated $time';
  }

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get viewAll => 'View All';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get transactionsWillAppearHere => 'Your transactions will appear here';

  @override
  String get allTransactionsLoaded => 'All transactions loaded';

  @override
  String transactionInTotal(int count, String suffix) {
    return '$count transaction$suffix in total';
  }

  @override
  String get oopsSomethingWentWrong => 'Oops! Something went wrong';

  @override
  String get editWallet => 'Edit Wallet';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get walletSettings => 'Wallet Settings';
}
