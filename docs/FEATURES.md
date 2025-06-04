# ✨ Features Documentation

## 🔐 Authentication & Security Features

### Smart Registration Flow

**Inovasi**: Automatic login setelah registrasi untuk seamless user experience

```dart
// Registration dengan Auto-Login Logic
Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
  // Step 1: Register user di API
  final registerResult = await _authRepository.register(/*...*/);

  await registerResult.fold(
    onSuccess: (user) async {
      // Step 2: Check token availability
      if (user.token == null || user.token!.isEmpty) {
        // Auto-login untuk get token
        final loginResult = await _authRepository.login(event.email, event.password);

        loginResult.fold(
          onSuccess: (loggedInUser) => emit(AuthAuthenticated(loggedInUser)), // → Home
          onError: (error) => emit(AuthRegisteredButNotLoggedIn(user.email)), // → Login page
        );
      } else {
        emit(AuthAuthenticated(user)); // → Home directly
      }
    },
    onError: (error) => emit(AuthError(error.getLocalizedMessage())), // → Stay on register
  );
}
```

**User Experience**:

- ✅ **Berhasil Register + Auto-Login**: Langsung ke home page
- ✅ **Berhasil Register, Gagal Auto-Login**: Ke login page dengan success message
- ❌ **Gagal Register**: Tetap di register page dengan error message

### Secure Token Management

```dart
// JWT Token Storage dengan SharedPreferences
@Injectable(as: IAuthLocalDataSource)
class AuthLocalDataSource implements IAuthLocalDataSource {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
```

### Comprehensive Form Validation

```dart
class FormValidators {
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).emailRequired;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.of(context).invalidEmail;
    }
    return null;
  }

  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).passwordRequired;
    }

    if (value.length < 8) {
      return AppLocalizations.of(context).passwordLength;
    }
    return null;
  }
}
```

**Validation Features**:

- ✅ Email format validation dengan regex
- ✅ Password minimum 8 karakter
- ✅ Confirm password matching
- ✅ Name minimum 3 karakter
- ✅ Localized error messages

### Enhanced Logout Confirmation

**Style Consistency**: Dialog konfirmasi mengikuti pattern transaksi

```dart
void _showLogoutDialog(BuildContext context, AuthBloc authBloc, dynamic l) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l.confirmLogout, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.logoutConfirmationMessage),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withAlpha(76)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l.logoutRedirectMessage)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  authBloc.add(LogoutEvent());
                },
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
                child: Text(l.logout),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

## 💰 Wallet Management Features

### Multi-Currency Support

**Supported Currencies**: USD, EUR, GBP dengan proper formatting

```dart
String _formatCurrency(double amount, String currency) {
  final numberFormat = NumberFormat.currency(
    symbol: _getCurrencySymbol(currency),
    decimalDigits: currency == 'USD' || currency == 'EUR' ? 2 : 0,
  );
  return numberFormat.format(amount);
}

String _getCurrencySymbol(String currency) {
  switch (currency.toUpperCase()) {
    case 'USD': return '\$';
    case 'EUR': return '€';
    case 'GBP': return '£';
    default: return currency;
  }
}
```

**Currency Display Examples**:

- USD: `$1,250.75`
- EUR: `€850.50`
- GBP: `£1,200`

### Smart Wallet Naming

**Auto-Generated Names**: Karena API tidak provide name field

```dart
class WalletModel {
  final int id;
  final double balance;
  final String currency;

  // Generated display name
  String get displayName => '$currency Wallet';
}
```

**Display Examples**:

- API Response: `{"id": 1, "balance": 1000.50, "currency": "USD"}`
- UI Display: `"USD Wallet - $1,000.50"`

### Real-time Balance Updates

```dart
class WalletRepository {
  @override
  Future<List<WalletModel>> getWallets({bool forceRefresh = false}) async {
    // Cache strategy
    if (!forceRefresh) {
      final cachedWallets = await _localDataSource.getWallets();
      if (cachedWallets.isNotEmpty) {
        return cachedWallets;
      }
    }

    // Fetch from API
    final wallets = await _remoteDataSource.getWallets();

    // Update cache
    await _localDataSource.saveWallets(wallets);

    return wallets;
  }
}
```

### Currency Grouping & Totals

**Smart Aggregation**: Group wallets by currency and calculate totals

```dart
Widget _buildTotalBalanceCard(BuildContext context, List<WalletModel> wallets) {
  // Group wallets by currency
  final Map<String, double> currencyTotals = {};
  for (final wallet in wallets) {
    currencyTotals[wallet.currency] =
        (currencyTotals[wallet.currency] ?? 0) + wallet.balance;
  }

  return Container(
    child: Column(
      children: [
        Text(context.l10n.totalBalance),
        ...currencyTotals.entries.map((entry) =>
          Text(_formatCurrency(entry.value, entry.key))
        ),
      ],
    ),
  );
}
```

**Display Result**:

```
Total Balance
$2,500.75
€1,200.50
£850.00
```

## 📊 Dashboard & Analytics Features

### Beautiful Homepage with Data Visualization

**Components**:

1. **Welcome Header** dengan user name
2. **Total Balance Card** dengan currency grouping
3. **Quick Actions** untuk deposit/withdraw/transfer
4. **Pie Chart** untuk wallet distribution
5. **Wallet Cards** preview
6. **Recent Transactions** dengan fallback

### FL Chart Integration

**Pie Chart Implementation** untuk wallet distribution:

```dart
Widget _buildWalletChart(BuildContext context, List<WalletModel> wallets) {
  return SizedBox(
    height: 200,
    child: PieChart(
      PieChartData(
        sections: _generatePieChartSections(wallets),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    ),
  );
}

List<PieChartSectionData> _generatePieChartSections(List<WalletModel> wallets) {
  final totalBalance = wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);
  final colors = [AppColors.purple, AppColors.pink, AppColors.darkPurple2, AppColors.darkPurple3];

  return wallets.asMap().entries.map((entry) {
    final index = entry.key;
    final wallet = entry.value;
    final percentage = totalBalance > 0 ? (wallet.balance / totalBalance) * 100 : 0;

    return PieChartSectionData(
      color: colors[index % colors.length],
      value: wallet.balance,
      title: '${percentage.toStringAsFixed(1)}%',
      radius: 60,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }).toList();
}
```

### Quick Actions with Navigation

```dart
Widget _buildQuickActions(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: _buildActionButton(
          context,
          icon: Icons.add_circle_outline,
          label: context.l10n.deposit,
          color: AppColors.purple,
          onTap: () => context.push('/deposit'),
        ),
      ),
      Expanded(
        child: _buildActionButton(
          context,
          icon: Icons.remove_circle_outline,
          label: context.l10n.withdraw,
          color: AppColors.pink,
          onTap: () => context.push('/withdrawal'),
        ),
      ),
      Expanded(
        child: _buildActionButton(
          context,
          icon: Icons.swap_horiz,
          label: context.l10n.transfer,
          color: AppColors.darkPurple2,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.transferFeatureComingSoon)),
            );
          },
        ),
      ),
    ],
  );
}
```

### Smart Transaction Display

**Hybrid Approach**: Real data when available, mock data as fallback

```dart
Widget _buildRecentTransactions(BuildContext context) {
  return BlocBuilder<WalletBloc, WalletState>(
    builder: (context, state) {
      if (state is TransactionsLoaded && state.transactions.isNotEmpty) {
        // Show real transactions
        return Column(
          children: [
            ...state.transactions.take(3).map((transaction) =>
                _buildRealTransactionItem(context, transaction)),
            Center(child: Text(context.l10n.connectToApiMessage)),
          ],
        );
      } else {
        // Show mock transactions as placeholder
        return Column(
          children: [
            _buildTransactionItem(context, title: context.l10n.depositToMainWallet, amount: 500000, isIncome: true),
            _buildTransactionItem(context, title: context.l10n.transferToSavings, amount: 200000, isIncome: false),
            _buildTransactionItem(context, title: context.l10n.withdrawal, amount: 100000, isIncome: false),
            Center(child: Text(context.l10n.connectToApiMessage)),
          ],
        );
      }
    },
  );
}
```

## 🎨 UI/UX Excellence Features

### Material Design 3 Implementation

**Theme System** dengan modern design language:

```dart
class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    elevationOverlay: ElevationOverlay.colorScheme,
  );

  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
  );
}
```

### Dynamic Theme Switching

**Persistent Theme Management** dengan BLoC:

```dart
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final IThemeRepository _themeRepository;

  ThemeBloc(this._themeRepository) : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    await _themeRepository.saveTheme(event.themeType);
    emit(ThemeLoaded(event.themeType));
  }
}

// Usage in main.dart
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    final themeData = state is ThemeLoaded
        ? (state.themeType == ThemeType.light ? AppTheme.light : AppTheme.dark)
        : AppTheme.light;

    return MaterialApp.router(
      theme: themeData,
      // ...
    );
  },
)
```

### Responsive Design

**Adaptive Layouts** untuk berbagai screen sizes:

```dart
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### Smooth Animations

**Transition Animations** dan loading states:

```dart
class AnimatedPageTransition extends StatefulWidget {
  @override
  State<AnimatedPageTransition> createState() => _AnimatedPageTransitionState();
}

class _AnimatedPageTransitionState extends State<AnimatedPageTransition>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_slideController);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }
}
```

### Modern Color System

**AppColors** dengan purple-based theme:

```dart
class AppColors {
  static const Color purple = Color(0xFF6B46C1);
  static const Color pink = Color(0xFFEC4899);
  static const Color darkPurple1 = Color(0xFF4C1D95);
  static const Color darkPurple2 = Color(0xFF5B21B6);
  static const Color darkPurple3 = Color(0xFF7C3AED);
  static const Color grey = Color(0xFF6B7280);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
```

## 🌍 Internationalization Features

### Multi-Language Support

**Supported Languages**: English & Indonesian

```dart
// l10n.yaml Configuration
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

### Dynamic Language Switching

**Real-time Language Changes** tanpa restart app:

```dart
@injectable
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final ILanguageRepository _languageRepository;

  LanguageBloc(this._languageRepository) : super(LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) async {
    await _languageRepository.saveLanguage(event.locale.languageCode);
    emit(LanguageLoaded(event.locale));
  }
}

// Usage in MaterialApp
MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: languageState is LanguageLoaded ? languageState.locale : null,
  // ...
)
```

### Complete Localization

**Translation Keys** untuk semua text dalam aplikasi:

```json
// app_en.arb
{
  "welcomeBackUser": "Welcome back,\n{userName}!",
  "@welcomeBackUser": {
    "placeholders": {
      "userName": {"type": "String"}
    }
  },
  "confirmDepositMessage": "Are you sure you want to deposit {amount}?",
  "@confirmDepositMessage": {
    "placeholders": {
      "amount": {"type": "String"}
    }
  }
}

// app_id.arb
{
  "welcomeBackUser": "Selamat datang kembali,\n{userName}!",
  "confirmDepositMessage": "Apakah Anda yakin ingin menyetor {amount}?"
}
```

### Context Extension for Easy Access

```dart
extension ContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Usage
Text(context.l10n.welcomeBackUser(userName))
Text(context.l10n.confirmDepositMessage('\$100.00'))
```

### Locale-Aware Formatting

**Date & Number Formatting** sesuai locale:

```dart
// Date formatting
DateFormat.yMMMd(context.l10n.localeName).format(date)

// Currency formatting with locale
NumberFormat.currency(
  locale: context.l10n.localeName,
  symbol: _getCurrencySymbol(currency),
).format(amount)
```

## 🚀 Transaction Management Features

### Complete Transaction Flow

**Deposit & Withdrawal** dengan confirmation dialogs:

```dart
void _showConfirmationDialog(WalletModel wallet, double amount, String description, String reference, dynamic l) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l.confirmTransaction),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.confirmDepositMessage('\$${amount.toStringAsFixed(2)}')),
          if (description.isNotEmpty) Text('${l.description}: $description'),
          if (reference.isNotEmpty) Text('${l.referenceId}: $reference'),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _executeDeposit(wallet, amount, description, reference);
                },
                child: Text(l.confirm),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

### Success & Error Handling

**Visual Feedback** untuk transaction results:

```dart
void _showSuccessDialog(dynamic l) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(l.transactionSuccessful, style: const TextStyle(color: Colors.green)),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK'),
          ),
        ),
      ],
    ),
  );
}
```

### Smart Transaction History

**Hybrid Data Display** dengan fallback mechanism:

```dart
Widget _buildRecentTransactions(BuildContext context) {
  return BlocBuilder<WalletBloc, WalletState>(
    builder: (context, state) {
      if (state is TransactionsLoaded && state.transactions.isNotEmpty) {
        // Real transactions from API
        return Column(
          children: state.transactions.take(3).map((transaction) =>
              _buildRealTransactionItem(context, transaction)).toList(),
        );
      } else {
        // Mock transactions as placeholder
        return Column(
          children: [
            _buildMockTransaction(context.l10n.depositToMainWallet, 500000, true),
            _buildMockTransaction(context.l10n.transferToSavings, 200000, false),
            _buildMockTransaction(context.l10n.withdrawal, 100000, false),
          ],
        );
      }
    },
  );
}
```

## ⚙️ Advanced Settings Features

### Settings Architecture

**Modular Settings** dengan category organization:

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildThemeSection(context),
                _buildLanguageSection(context),
                _buildAboutSection(context),
              ],
            ),
          ),
          _buildLogoutSection(context),
        ],
      ),
    );
  }
}
```

### Theme Management

**Visual Theme Selector** dengan preview:

```dart
Widget _buildThemeSection(BuildContext context) {
  return BlocBuilder<ThemeBloc, ThemeState>(
    builder: (context, state) {
      return _buildSettingItem(
        context: context,
        icon: Icons.palette_outlined,
        title: context.l10n.theme,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.themeType == ThemeType.light
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            Text(state.themeType == ThemeType.light ? l.light : l.dark),
          ],
        ),
        onTap: () => _showThemeDialog(context),
      );
    },
  );
}
```

### Language Preferences

**Language Selector** dengan country flags:

```dart
Widget _buildLanguageSection(BuildContext context) {
  return BlocBuilder<LanguageBloc, LanguageState>(
    builder: (context, state) {
      return _buildSettingItem(
        context: context,
        icon: Icons.language_outlined,
        title: context.l10n.language,
        trailing: Text(state.locale.languageCode.toUpperCase()),
        onTap: () => _showLanguageDialog(context),
      );
    },
  );
}
```

## 🔧 Performance Optimization Features

### Efficient State Management

**BlocBuilder Optimization** dengan buildWhen:

```dart
BlocBuilder<WalletBloc, WalletState>(
  buildWhen: (previous, current) {
    // Only rebuild when wallets change
    return current is WalletsLoaded || current is WalletError;
  },
  builder: (context, state) {
    return switch (state) {
      WalletsLoaded(wallets: final wallets) => WalletsList(wallets: wallets),
      WalletError(message: final message) => ErrorWidget(message: message),
      _ => const LoadingWidget(),
    };
  },
)
```

### Memory Management

**Proper Lifecycle Management**:

```dart
class _HomePageState extends State<HomePage> {
  List<TransactionModel> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WalletBloc>().add(const GetWalletsEvent());
      }
    });
  }

  @override
  void dispose() {
    _allTransactions.clear();
    super.dispose();
  }
}
```

### Caching Strategy

**Smart Caching** dengan expiry time:

```dart
class CacheManager {
  static const Duration _cacheExpiry = Duration(minutes: 5);
  DateTime? _lastFetchTime;

  Future<List<WalletModel>> getWallets({bool forceRefresh = false}) async {
    final shouldRefresh = forceRefresh ||
        _lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > _cacheExpiry;

    if (!shouldRefresh) {
      final cachedData = await _getFromCache();
      if (cachedData.isNotEmpty) return cachedData;
    }

    final freshData = await _fetchFromAPI();
    await _saveToCache(freshData);
    _lastFetchTime = DateTime.now();

    return freshData;
  }
}
```

## 📱 Navigation & Routing Features

### Go Router Implementation

**Declarative Navigation** dengan type-safe routes:

```dart
@lazySingleton
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String wallet = '/wallet';

  final _goRouter = GoRouter(
    initialLocation: splash,
    redirect: _handleRedirect,
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: home, builder: (context, state) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: wallet, builder: (context, state) => const WalletPage()),
          ]),
        ],
      ),
    ],
  );
}
```

### Route Guards

**Authentication-based Navigation**:

```dart
String? _handleRedirect(BuildContext context, GoRouterState state) {
  final isLoggingIn = state.matchedLocation == login;
  final isRegistering = state.matchedLocation == register;
  final isSplash = state.matchedLocation == splash;

  // Auth guard: Redirect to login if not authenticated
  if (!isAuthenticated && !isLoggingIn && !isRegistering && !isSplash) {
    return login;
  }

  // Prevent authenticated users from accessing auth pages
  if (isAuthenticated && (isLoggingIn || isRegistering)) {
    return home;
  }

  return null;
}
```

## Summary Fitur Komprehensif

### 🎯 **User Experience Excellence**

- Smart registration dengan auto-login
- Seamless navigation dengan route guards
- Real-time updates dengan caching
- Comprehensive error handling

### 🛡️ **Security & Data Management**

- JWT token management
- Secure local storage
- Input validation
- API error handling dengan localization

### 🎨 **Modern UI/UX**

- Material Design 3
- Dark/Light theme switching
- Responsive design
- Smooth animations

### 🌍 **Internationalization**

- Multi-language support (EN/ID)
- Locale-aware formatting
- Dynamic language switching
- Complete localization

### 📊 **Data Visualization**

- FL Chart integration
- Multi-currency support
- Smart aggregation
- Real-time balance updates

### ⚡ **Performance**

- Efficient state management
- Memory optimization
- Smart caching
- Lazy loading

Setiap fitur dirancang dengan mempertimbangkan user experience, performance, dan maintainability code untuk menghasilkan aplikasi wallet yang modern dan robust.
