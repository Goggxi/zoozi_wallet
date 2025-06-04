# 🏦 Zoozi Wallet

> **Modern Flutter Wallet Application with Clean Architecture**

Zoozi Wallet adalah aplikasi mobile wallet modern yang dibangun menggunakan Flutter dengan implementasi Clean Architecture, BLoC Pattern, dan fitur-fitur komprehensif untuk pengelolaan keuangan digital.

![Flutter](https://img.shields.io/badge/Flutter-3.3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## 📱 Demo & Screenshots

<details>
<summary>📹 Demo Video</summary>

> **Coming Soon**: Demo video akan tersedia di `assets/readme/demo.mp4`

</details>

<details>
<summary>📸 Screenshots</summary>

> **Coming Soon**: Screenshots aplikasi akan ditambahkan untuk menunjukkan:
>
> - Splash Screen & Authentication
> - Homepage dengan Dashboard
> - Wallet Management
> - Transaction History
> - Settings & Themes
> - Multi-language Support

</details>

## 🏗️ Architecture & Design Patterns

### Clean Architecture Implementation

```
lib/
├── core/                     # Shared utilities & infrastructure
│   ├── router/              # Navigation routing
│   ├── theme/               # App theming
│   ├── utils/               # Shared utilities
│   ├── widgets/             # Reusable widgets
│   └── storage/             # Local storage
├── features/                # Feature-based modules
│   ├── auth/               # Authentication feature
│   │   ├── data/           # Data layer
│   │   │   ├── datasources/    # Remote & Local data sources
│   │   │   ├── models/         # Data models
│   │   │   └── repositories/   # Repository implementations
│   │   ├── domain/         # Domain layer
│   │   │   ├── entities/       # Business entities
│   │   │   ├── repositories/   # Repository interfaces
│   │   │   └── usecases/       # Business logic
│   │   └── presentation/   # Presentation layer
│   │       ├── bloc/           # BLoC state management
│   │       ├── pages/          # UI screens
│   │       └── widgets/        # Feature-specific widgets
│   ├── wallet/             # Wallet management
│   ├── home/               # Homepage & dashboard
│   ├── settings/           # App settings
│   └── splash/             # Splash screen
├── di/                     # Dependency injection
└── l10n/                   # Internationalization
```

### 🧩 Design Patterns Implemented

#### 1. **Repository Pattern**

```dart
// Interface (Domain)
abstract class IAuthRepository {
  Future<ApiResult<AuthModel>> login(String email, String password);
  Future<ApiResult<AuthModel>> register({required String email, required String password, String? name});
}

// Implementation (Data)
@Injectable(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  // Repository encapsulates data access logic
}
```

#### 2. **BLoC Pattern for State Management**

```dart
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }
}
```

#### 3. **Dependency Injection with GetIt**

```dart
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

// Usage
final authBloc = getIt<AuthBloc>();
```

#### 4. **Strategy Pattern untuk API Results**

```dart
abstract class ApiResult<T> {
  void fold({
    required Function(T data) onSuccess,
    required Function(ApiException error) onError,
  });
}
```

## ✨ Features Overview

### 🔐 Authentication & Security

- **Smart Registration Flow**: Auto-login setelah registrasi sukses
- **Secure Token Management**: JWT token handling dengan local storage
- **Form Validation**: Comprehensive validation untuk semua input
- **Logout Confirmation**: Dialog konfirmasi dengan consistent styling

### 💰 Wallet Management

- **Multi-Currency Support**: USD, EUR, GBP dengan proper formatting
- **Real-time Balance**: Live balance updates dari API
- **Transaction History**: Complete transaction tracking
- **Deposit & Withdrawal**: Full transaction flow dengan confirmations

### 📊 Dashboard & Analytics

- **Beautiful Homepage**: Modern UI dengan data visualisasi
- **Pie Chart Visualization**: Wallet distribution menggunakan FL Chart
- **Currency Grouping**: Smart grouping berdasarkan mata uang
- **Quick Actions**: Fast access untuk deposit, withdraw, transfer

### 🎨 UI/UX Excellence

- **Material Design 3**: Modern design system implementation
- **Dark/Light Themes**: Automatic theme switching dengan persistence
- **Responsive Design**: Adaptive layouts untuk berbagai screen sizes
- **Smooth Animations**: Transition animations dan loading states

### 🌍 Internationalization

- **Multi-language Support**: English & Indonesian
- **Dynamic Language Switching**: Real-time language changes
- **Complete Localization**: Semua text menggunakan translation keys
- **Date & Number Formatting**: Locale-aware formatting

### ⚙️ Advanced Settings

- **Theme Management**: Persistent theme selection
- **Language Preferences**: Save user language preference
- **App Information**: About section untuk app details

## 🛠️ Technical Implementation

### State Management Architecture

```dart
// Event-driven architecture
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;
}

// State management
abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthAuthenticated extends AuthState {
  final AuthModel user;
  const AuthAuthenticated(this.user);
}
```

### Networking & API Integration

```dart
// HTTP Client dengan error handling
class HttpClient {
  Future<http.Response> apiRequest({
    required String url,
    required RequestMethod method,
    required String apiPath,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  });
}

// API Result handling
sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends ApiResult<T> {
  final ApiException error;
  const Error(this.error);
}
```

### Local Storage & Caching

```dart
// Abstracted storage interface
abstract class IAuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(AuthModel user);
  Future<AuthModel?> getUser();
  Future<void> clearAll();
}
```

### Error Handling System

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final BuildContext? context;

  // Localized error messages
  String getLocalizedMessage() {
    if (context == null) return message;

    switch (errorCode) {
      case 'UNAUTHORIZED':
        return AppLocalizations.of(context!).unauthorizedError;
      // ... more error cases
    }
  }
}
```

## 🔧 Configuration & Setup

### Environment Configuration

**⚠️ Important**: File `dart_define.json` berisi konfigurasi environment:

```json
{
  "BASE_URL": "https://wallet-testing-murex.vercel.app"
}
```

> **Note**: File ini di-push sebagai contoh konfigurasi. Dalam production, file ini harus ada di `.gitignore` dan berisi credential yang sesungguhnya seperti API keys, database URLs, dll.

### Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.4 # State management
  get_it: ^7.6.7 # Dependency injection
  injectable: ^2.3.2 # DI annotations
  go_router: ^15.1.2 # Navigation
  fl_chart: ^0.69.0 # Charts & graphs
  google_fonts: ^6.2.1 # Typography
  http: ^1.2.0 # Networking
  shared_preferences: ^2.2.2 # Local storage
  intl: ^0.20.2 # Internationalization
  equatable: ^2.0.5 # Value equality
  logger: ^2.0.2+1 # Logging
  json_annotation: ^4.8.1 # JSON serialization

dev_dependencies:
  build_runner: ^2.4.8 # Code generation
  injectable_generator: ^2.4.1 # DI code generation
  json_serializable: ^6.7.1 # JSON code generation
```

### Build & Run Instructions

1. **Clone & Setup**

   ```bash
   git clone <repository-url>
   cd zoozi_wallet
   flutter pub get
   ```

2. **Code Generation**

   ```bash
   # Generate dependency injection
   flutter packages pub run build_runner build

   # Generate translations
   flutter gen-l10n
   ```

3. **Run Application**

   ```bash
   # Development
   flutter run

   # Production build
   flutter build apk --release
   ```

## 📋 Code Quality & Standards

### Code Generation & Build Tools

- **Injectable**: Automatic dependency injection code generation
- **JSON Serializable**: Model serialization/deserialization
- **Build Runner**: Code generation orchestration
- **Flutter Gen L10n**: Automatic localization code generation

### Code Architecture Principles

- **Single Responsibility**: Setiap class memiliki satu tanggung jawab
- **Open/Closed Principle**: Open for extension, closed for modification
- **Dependency Inversion**: High-level modules tidak depend pada low-level modules
- **SOLID Principles**: Implemented throughout the codebase

### Testing Strategy

```dart
// Unit Testing structure
test_driver/
├── blocs/              # BLoC testing
├── repositories/       # Repository testing
├── utils/             # Utility testing
└── integration/       # Integration testing
```

## 🚀 Advanced Features Implementation

### Smart Registration Flow

```dart
Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
  // Step 1: Register user
  final registerResult = await _authRepository.register(/*...*/);

  await registerResult.fold(
    onSuccess: (user) async {
      // Step 2: Auto-login if no token
      if (user.token == null || user.token!.isEmpty) {
        final loginResult = await _authRepository.login(event.email, event.password);
        // Handle auto-login result...
      }
    },
    onError: (error) => emit(AuthError(error.getLocalizedMessage())),
  );
}
```

### Dynamic Theme System

```dart
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  // Persistent theme management
  Future<void> _onChangeTheme(ChangeThemeEvent event, Emitter<ThemeState> emit) async {
    await _themeRepository.saveTheme(event.themeType);
    emit(ThemeLoaded(event.themeType));
  }
}
```

### Multi-Currency Support

```dart
String _formatCurrency(double amount, String currency) {
  final numberFormat = NumberFormat.currency(
    symbol: _getCurrencySymbol(currency),
    decimalDigits: currency == 'USD' || currency == 'EUR' ? 2 : 0,
  );
  return numberFormat.format(amount);
}
```

## 📈 Performance Optimizations

- **Lazy Loading**: Dependencies loaded on-demand dengan GetIt
- **Widget Optimization**: Efficient widget rebuilds dengan BlocBuilder
- **Memory Management**: Proper disposal of controllers dan streams
- **Image Optimization**: Optimized asset loading
- **Network Caching**: Intelligent API response caching

## 🔒 Security Features

- **Token Management**: Secure JWT token storage
- **Input Validation**: Comprehensive form validation
- **Error Boundary**: Graceful error handling
- **Network Security**: HTTPS-only API communications
- **Data Encryption**: Sensitive data encryption in local storage

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Lead Developer**: [Your Name]
- **UI/UX Designer**: [Designer Name]
- **Backend Developer**: [Backend Developer Name]

---

<div align="center">

**Made with ❤️ using Flutter**

[📱 Download APK](releases) | [📖 Documentation](docs) | [🐛 Report Bug](issues) | [💡 Request Feature](issues)

</div>
