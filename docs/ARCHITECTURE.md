# 🏗️ Architecture Documentation

## Clean Architecture Layers

### 1. Presentation Layer (`presentation/`)

**Tanggung Jawab**: User Interface dan State Management

```dart
// BLoC for State Management
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  // Smart Registration with Auto-Login
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final registerResult = await _authRepository.register(/*...*/);

    await registerResult.fold(
      onSuccess: (user) async {
        if (user.token == null || user.token!.isEmpty) {
          // Auto-login untuk mendapatkan token
          final loginResult = await _authRepository.login(event.email, event.password);
          loginResult.fold(
            onSuccess: (loggedInUser) => emit(AuthAuthenticated(loggedInUser)),
            onError: (error) => emit(AuthRegisteredButNotLoggedIn(user.email)),
          );
        } else {
          emit(AuthAuthenticated(user));
        }
      },
      onError: (error) => emit(AuthError(error.getLocalizedMessage())),
    );
  }
}
```

**Key Components**:

- **Pages**: UI screens dengan lifecycle management
- **Widgets**: Reusable UI components
- **BLoC**: State management dengan event-driven architecture

### 2. Domain Layer (`domain/`)

**Tanggung Jawab**: Business Logic dan Rules

```dart
// Repository Interface (Contract)
abstract class IAuthRepository {
  Future<ApiResult<AuthModel>> login(String email, String password);
  Future<ApiResult<AuthModel>> register({
    required String email,
    required String password,
    String? name,
  });
  Future<ApiResult<void>> logout();
  AuthModel? getCurrentUser();
  bool get isAuthenticated;
}

// Use Cases (Business Logic)
@injectable
class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<ApiResult<AuthModel>> call(String email, String password) {
    return _authRepository.login(email, password);
  }
}
```

**Key Components**:

- **Entities**: Core business objects
- **Repository Interfaces**: Contracts untuk data access
- **Use Cases**: Specific business logic operations

### 3. Data Layer (`data/`)

**Tanggung Jawab**: Data Access dan External Services

```dart
// Repository Implementation
@Injectable(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  AuthRepository(this._remoteDataSource, this._localDataSource);

  @override
  Future<ApiResult<AuthModel>> login(String email, String password) async {
    try {
      final user = await _remoteDataSource.login(email, password);

      // Save token dan user data locally
      if (user.token != null) {
        await _localDataSource.saveToken(user.token!);
      }
      await _localDataSource.saveUser(user);

      return Success(user);
    } on ApiException catch (e) {
      return Error(e);
    }
  }
}

// Remote Data Source
@Injectable(as: IAuthRemoteDataSource)
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final HttpClient _client;
  final IAppLogger _logger;
  final String baseUrl;

  AuthRemoteDataSource(this._client, this._logger)
      : baseUrl = const String.fromEnvironment('BASE_URL');

  @override
  Future<AuthModel> login(String email, String password) async {
    _logger.info('Logging in user: $email');

    final request = LoginRequest(email: email, password: password);

    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.post,
      apiPath: '/auth/login',
      body: request.toJson(),
    );

    final loginResponse = LoginResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    return AuthModel(
      id: -1,
      email: email,
      accessToken: loginResponse.accessToken,
    );
  }
}
```

## Dependency Injection Architecture

### GetIt + Injectable Configuration

```dart
// DI Setup
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

// Module Registration
@module
abstract class RegisterModule {
  @singleton
  http.Client get httpClient => http.Client();

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}

// Injectable Services
@Injectable(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  // Auto-injected dependencies
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Auto-injected repository
}
```

**Benefits**:

- **Automatic Dependency Resolution**: GetIt automatically resolves dependencies
- **Singleton Management**: Shared instances untuk services
- **Lazy Loading**: Dependencies loaded only when needed
- **Type Safety**: Compile-time dependency checking

## State Management dengan BLoC Pattern

### Event-Driven Architecture

```dart
// Events (User Actions)
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context; // For localized error messages
}

// States (UI State)
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final AuthModel user;
  const AuthAuthenticated(this.user);
}
class AuthRegisteredButNotLoggedIn extends AuthState {
  final String email;
  const AuthRegisteredButNotLoggedIn(this.email);
}
```

### BLoC Implementation

```dart
@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final IWalletRepository _walletRepository;

  WalletBloc(this._walletRepository) : super(WalletInitial()) {
    on<GetWalletsEvent>(_onGetWallets);
    on<CreateWalletEvent>(_onCreateWallet);
    on<GetTransactionsEvent>(_onGetTransactions);
  }

  Future<void> _onGetWallets(GetWalletsEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());

    final result = await _walletRepository.getWallets(forceRefresh: event.forceRefresh);

    result.fold(
      onSuccess: (wallets) => emit(WalletsLoaded(wallets)),
      onError: (error) => emit(WalletError(error.message)),
    );
  }
}
```

## API Result Pattern

### Type-Safe Error Handling

```dart
// Sealed class untuk Result pattern
sealed class ApiResult<T> {
  const ApiResult();

  // Fold pattern untuk handling
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiException error) onError,
  }) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      Error<T>(error: final error) => onError(error),
    };
  }
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends ApiResult<T> {
  final ApiException error;
  const Error(this.error);
}

// Usage
final result = await repository.login(email, password);
result.fold(
  onSuccess: (user) => print('Login successful: ${user.email}'),
  onError: (error) => print('Login failed: ${error.message}'),
);
```

## Navigation dengan GoRouter

### Declarative Routing

```dart
@lazySingleton
class AppRouter {
  final IAuthRepository _authRepository;

  // Route definitions
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String wallet = '/wallet';

  // Route guards
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggingIn = state.matchedLocation == login;
    final isRegistering = state.matchedLocation == register;
    final isSplash = state.matchedLocation == splash;

    // Authentication guard
    if (!isAuthenticated && !isLoggingIn && !isRegistering && !isSplash) {
      return login;
    }

    // Authenticated redirect
    if (isAuthenticated && (isLoggingIn || isRegistering)) {
      return home;
    }

    return null;
  }

  // Nested routes dengan StatefulShellRoute
  final _goRouter = GoRouter(
    initialLocation: splash,
    redirect: _handleRedirect,
    routes: [
      // Authentication routes
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(path: register, builder: (context, state) => const RegisterPage()),

      // Main app dengan bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
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

## Multi-Language Support

### Internationalization Implementation

```dart
// l10n.yaml Configuration
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations

// Translation files
// lib/l10n/app_en.arb
{
  "welcomeBackUser": "Welcome back,\n{userName}!",
  "@welcomeBackUser": {
    "placeholders": {
      "userName": {"type": "String"}
    }
  }
}

// lib/l10n/app_id.arb
{
  "welcomeBackUser": "Selamat datang kembali,\n{userName}!"
}

// Usage in code
Text(context.l10n.welcomeBackUser(userName))
```

### Language BLoC

```dart
@injectable
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final ILanguageRepository _languageRepository;

  LanguageBloc(this._languageRepository) : super(LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    await _languageRepository.saveLanguage(event.locale.languageCode);
    emit(LanguageLoaded(event.locale));
  }
}
```

## Theme System

### Dynamic Theme Management

```dart
// Theme definitions
class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
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

// Theme BLoC
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final IThemeRepository _themeRepository;

  ThemeBloc(this._themeRepository) : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    await _themeRepository.saveTheme(event.themeType);
    emit(ThemeLoaded(event.themeType));
  }
}
```

## Error Handling Strategy

### Comprehensive Error Management

```dart
// Custom Exception dengan Localization
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final BuildContext? context;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.context,
  });

  // Localized error messages
  String getLocalizedMessage() {
    if (context == null) return message;

    final l10n = AppLocalizations.of(context!);

    return switch (errorCode) {
      'UNAUTHORIZED' => l10n.unauthorizedError,
      'INVALID_CREDENTIALS' => l10n.invalidCredentialsError,
      'NOT_FOUND' => l10n.notFoundError,
      'INTERNAL_SERVER_ERROR' => l10n.internalServerError,
      'NETWORK_ERROR' => l10n.networkError,
      'REQUEST_TIMEOUT' => l10n.requestTimeout,
      _ => message,
    };
  }

  ApiException copyWith({BuildContext? context}) {
    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      context: context ?? this.context,
    );
  }
}

// HTTP Client dengan Error Handling
class HttpClient {
  Future<http.Response> apiRequest({
    required String url,
    required RequestMethod method,
    required String apiPath,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$url$apiPath');
      final requestHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await switch (method) {
        RequestMethod.get => http.get(uri, headers: requestHeaders),
        RequestMethod.post => http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ),
        RequestMethod.put => http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ),
        RequestMethod.delete => http.delete(uri, headers: requestHeaders),
      };

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw ApiException(
          message: _parseErrorMessage(response),
          statusCode: response.statusCode,
          errorCode: _mapStatusCodeToErrorCode(response.statusCode),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error occurred',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }
}
```

## Performance Optimizations

### Widget Optimization

```dart
// Efficient BlocBuilder usage
BlocBuilder<WalletBloc, WalletState>(
  buildWhen: (previous, current) {
    // Only rebuild when specific state changes
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

// Optimized ListView dengan caching
class OptimizedTransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const OptimizedTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      cacheExtent: 500, // Cache additional items
      itemBuilder: (context, index) {
        return TransactionItem(
          key: ValueKey(transactions[index].id), // Stable keys
          transaction: transactions[index],
        );
      },
    );
  }
}
```

### Memory Management

```dart
// Proper disposal dalam StatefulWidget
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TransactionModel> _allTransactions = [];
  bool _loadingTransactions = false;

  @override
  void initState() {
    super.initState();
    // Safe way to add event menggunakan context.read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WalletBloc>().add(const GetWalletsEvent());
      }
    });
  }

  @override
  void dispose() {
    // Clean up resources
    _allTransactions.clear();
    super.dispose();
  }
}
```

## Security Implementation

### Token Management

```dart
// Secure token storage
abstract class IAuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(AuthModel user);
  Future<AuthModel?> getUser();
  Future<void> clearAll();
}

@Injectable(as: IAuthLocalDataSource)
class AuthLocalDataSource implements IAuthLocalDataSource {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthLocalDataSource(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
```

### Input Validation

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

## Testing Strategy

### Unit Testing

```dart
// BLoC Testing
group('AuthBloc', () {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepository);
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login succeeds',
    build: () {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => Success(mockUser));
      return authBloc;
    },
    act: (bloc) => bloc.add(LoginEvent(
      email: 'test@example.com',
      password: 'password123',
      context: mockContext,
    )),
    expect: () => [AuthLoading(), AuthAuthenticated(mockUser)],
  );
});

// Repository Testing
group('AuthRepository', () {
  late AuthRepository authRepository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    authRepository = AuthRepository(mockRemoteDataSource, mockLocalDataSource);
  });

  test('login success saves token and user locally', () async {
    // Arrange
    when(() => mockRemoteDataSource.login(any(), any()))
        .thenAnswer((_) async => mockUser);
    when(() => mockLocalDataSource.saveToken(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDataSource.saveUser(any()))
        .thenAnswer((_) async {});

    // Act
    final result = await authRepository.login('test@example.com', 'password');

    // Assert
    expect(result, isA<Success<AuthModel>>());
    verify(() => mockLocalDataSource.saveToken(mockUser.token!)).called(1);
    verify(() => mockLocalDataSource.saveUser(mockUser)).called(1);
  });
});
```

### Integration Testing

```dart
// Integration test untuk authentication flow
void main() {
  group('Authentication Integration Test', () {
    testWidgets('complete login flow', (WidgetTester tester) async {
      // Setup
      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      // Navigate to login page
      expect(find.byType(LoginPage), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify navigation to home page
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
```

Dokumentasi ini memberikan panduan lengkap tentang implementasi teknis aplikasi Zoozi Wallet, mulai dari arsitektur hingga strategi testing. Setiap komponen dirancang dengan prinsip Clean Architecture dan best practices Flutter development.
