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
}
