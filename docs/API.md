# 🌐 API Documentation

## Base Configuration

### Environment Setup

```dart
// dart_define.json (Contoh - Jangan commit credentials real)
{
  "BASE_URL": "https://wallet-testing-murex.vercel.app"
}
```

> **⚠️ Security Note**: File `dart_define.json` berisi konfigurasi environment. Dalam production:
>
> - File ini harus ada di `.gitignore`
> - Gunakan credential management yang aman
> - Implementasikan different environments (dev, staging, prod)

### HTTP Client Implementation

```dart
class HttpClient {
  Future<http.Response> apiRequest({
    required String url,
    required RequestMethod method,
    required String apiPath,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$url$apiPath');
    final requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    // Add authentication token if available
    final token = await _getAuthToken();
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await _makeRequest(method, uri, requestHeaders, body);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
```

## Authentication Endpoints

### 1. Login

**Endpoint**: `POST /auth/login`

**Request Body**:

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response**:

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Implementation**:

```dart
@override
Future<AuthModel> login(String email, String password) async {
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

  // Create user model dengan token
  return AuthModel(
    id: -1, // API tidak return ID pada login
    email: email,
    accessToken: loginResponse.accessToken,
  );
}
```

### 2. Register

**Endpoint**: `POST /auth/register`

**Request Body**:

```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Response**:

```json
{
  "id": 123,
  "email": "user@example.com",
  "name": "John Doe",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Smart Registration Flow**:

```dart
@override
Future<AuthModel> register({
  required String email,
  required String password,
  String? name,
}) async {
  final request = RegisterRequest(
    email: email,
    password: password,
    name: name,
  );

  final response = await _client.apiRequest(
    url: baseUrl,
    method: RequestMethod.post,
    apiPath: '/auth/register',
    body: request.toJson(),
  );

  final user = AuthModel.fromJson(
    jsonDecode(response.body) as Map<String, dynamic>,
  );

  // Note: Register response tidak include token
  // Auto-login akan dilakukan di BLoC level
  return user;
}
```

## Wallet Management Endpoints

### 1. Get Wallets

**Endpoint**: `GET /wallets`

**Headers**:

```
Authorization: Bearer {access_token}
```

**Response**:

```json
[
  {
    "id": 1,
    "balance": 1000.5,
    "currency": "USD",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:35:00Z"
  },
  {
    "id": 2,
    "balance": 850.75,
    "currency": "EUR",
    "createdAt": "2024-01-15T11:00:00Z",
    "updatedAt": "2024-01-15T11:00:00Z"
  }
]
```

**Implementation**:

```dart
@override
Future<List<WalletModel>> getWallets({bool forceRefresh = false}) async {
  // Check cache first (jika tidak force refresh)
  if (!forceRefresh) {
    final cachedWallets = await _localDataSource.getWallets();
    if (cachedWallets.isNotEmpty) {
      return cachedWallets;
    }
  }

  final response = await _client.apiRequest(
    url: baseUrl,
    method: RequestMethod.get,
    apiPath: '/wallets',
  );

  final walletsJson = jsonDecode(response.body) as List<dynamic>;
  final wallets = walletsJson
      .map((json) => WalletModel.fromJson(json as Map<String, dynamic>))
      .toList();

  // Cache wallets locally
  await _localDataSource.saveWallets(wallets);

  return wallets;
}
```

### 2. Create Wallet

**Endpoint**: `POST /wallets`

**Request Body**:

```json
{
  "currency": "USD",
  "initialBalance": 500.0
}
```

**Response**:

```json
{
  "id": 3,
  "balance": 500.0,
  "currency": "USD",
  "createdAt": "2024-01-15T12:00:00Z",
  "updatedAt": "2024-01-15T12:00:00Z"
}
```

### 3. Get Wallet by ID

**Endpoint**: `GET /wallets/{id}`

**Response**: Same as individual wallet object

## Transaction Endpoints

### 1. Get Transactions

**Endpoint**: `GET /wallets/{walletId}/transactions`

**Query Parameters**:

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10)
- `type`: Transaction type filter (optional)

**Response**:

```json
{
  "data": [
    {
      "id": 1,
      "title": "Deposit",
      "description": "Monthly salary deposit",
      "amount": 1000.0,
      "type": {
        "id": 1,
        "name": "income"
      },
      "typeString": "DEPOSIT",
      "timestamp": "2024-01-15T10:30:00Z",
      "referenceId": "REF123456"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 45,
    "itemsPerPage": 10
  }
}
```

**Implementation**:

```dart
@override
Future<List<TransactionModel>> getTransactions({
  required String walletId,
  int page = 1,
  int limit = 10,
}) async {
  final response = await _client.apiRequest(
    url: baseUrl,
    method: RequestMethod.get,
    apiPath: '/wallets/$walletId/transactions?page=$page&limit=$limit',
  );

  final responseData = jsonDecode(response.body) as Map<String, dynamic>;
  final transactionsJson = responseData['data'] as List<dynamic>;

  return transactionsJson
      .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
      .toList();
}
```

### 2. Create Deposit

**Endpoint**: `POST /wallets/{walletId}/deposit`

**Request Body**:

```json
{
  "amount": 100.0,
  "description": "Salary deposit",
  "referenceId": "REF789"
}
```

**Response**:

```json
{
  "id": 15,
  "title": "Deposit",
  "description": "Salary deposit",
  "amount": 100.0,
  "type": {
    "id": 1,
    "name": "income"
  },
  "typeString": "DEPOSIT",
  "timestamp": "2024-01-15T14:30:00Z",
  "referenceId": "REF789"
}
```

### 3. Create Withdrawal

**Endpoint**: `POST /wallets/{walletId}/withdrawal`

**Request Body**:

```json
{
  "amount": 50.0,
  "description": "ATM withdrawal",
  "referenceId": "REF456"
}
```

**Response**: Same as transaction object

## Data Models

### AuthModel

```dart
@JsonSerializable()
class AuthModel extends Equatable {
  final int id;
  final String email;
  final String? name;
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const AuthModel({
    required this.id,
    required this.email,
    this.name,
    this.accessToken,
    this.createdAt,
    this.updatedAt,
  });

  String? get token => accessToken;

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);
}
```

### WalletModel

```dart
@JsonSerializable()
class WalletModel extends Equatable {
  final int id;
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  // Generated display name karena API tidak provide name
  String get displayName => '$currency Wallet';

  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$WalletModelToJson(this);
}
```

### TransactionModel

```dart
@JsonSerializable()
class TransactionModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final String typeString;
  final DateTime timestamp;
  final String? referenceId;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.typeString,
    required this.timestamp,
    this.referenceId,
  });

  // Helper methods
  bool get isIncome =>
      type.name == 'income' || typeString.toUpperCase() == 'DEPOSIT';

  bool get isExpense =>
      type.name == 'expense' || typeString.toUpperCase() == 'WITHDRAWAL';

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}

@JsonSerializable()
class TransactionType extends Equatable {
  final int id;
  final String name;

  const TransactionType({
    required this.id,
    required this.name,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) =>
      _$TransactionTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionTypeToJson(this);
}
```

## Error Handling

### API Exception Mapping

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final BuildContext? context;

  String getLocalizedMessage() {
    if (context == null) return message;

    final l10n = AppLocalizations.of(context!);

    return switch (statusCode) {
      400 => l10n.badRequestError,
      401 => l10n.unauthorizedError,
      403 => l10n.forbiddenError,
      404 => l10n.notFoundError,
      500 => l10n.internalServerError,
      _ => switch (errorCode) {
        'INVALID_CREDENTIALS' => l10n.invalidCredentialsError,
        'NETWORK_ERROR' => l10n.networkError,
        'REQUEST_TIMEOUT' => l10n.requestTimeout,
        _ => message,
      },
    };
  }
}
```

### Status Code Handling

```dart
ApiException _mapStatusCodeToException(http.Response response) {
  final statusCode = response.statusCode;

  return switch (statusCode) {
    400 => ApiException(
      message: 'Bad request',
      statusCode: statusCode,
      errorCode: 'BAD_REQUEST',
    ),
    401 => ApiException(
      message: 'Unauthorized access',
      statusCode: statusCode,
      errorCode: 'UNAUTHORIZED',
    ),
    403 => ApiException(
      message: 'Forbidden access',
      statusCode: statusCode,
      errorCode: 'FORBIDDEN',
    ),
    404 => ApiException(
      message: 'Resource not found',
      statusCode: statusCode,
      errorCode: 'NOT_FOUND',
    ),
    500 => ApiException(
      message: 'Internal server error',
      statusCode: statusCode,
      errorCode: 'INTERNAL_SERVER_ERROR',
    ),
    _ => ApiException(
      message: 'Unknown error occurred',
      statusCode: statusCode,
      errorCode: 'UNKNOWN_ERROR',
    ),
  };
}
```

## Caching Strategy

### Local Data Source

```dart
@Injectable(as: IWalletLocalDataSource)
class WalletLocalDataSource implements IWalletLocalDataSource {
  final SharedPreferences _prefs;
  static const String _walletsKey = 'cached_wallets';
  static const String _transactionsKey = 'cached_transactions';

  @override
  Future<void> saveWallets(List<WalletModel> wallets) async {
    final walletsJson = wallets.map((w) => w.toJson()).toList();
    await _prefs.setString(_walletsKey, jsonEncode(walletsJson));
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    final walletsString = _prefs.getString(_walletsKey);
    if (walletsString == null) return [];

    final walletsJson = jsonDecode(walletsString) as List<dynamic>;
    return walletsJson
        .map((json) => WalletModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_walletsKey);
    await _prefs.remove(_transactionsKey);
  }
}
```

## Authentication Flow

### Token Management

```dart
class AuthRepository implements IAuthRepository {
  @override
  Future<ApiResult<AuthModel>> login(String email, String password) async {
    try {
      final user = await _remoteDataSource.login(email, password);

      // Save token untuk future requests
      if (user.token != null) {
        await _localDataSource.saveToken(user.token!);
      }

      // Save user data
      await _localDataSource.saveUser(user);

      return Success(user);
    } on ApiException catch (e) {
      return Error(e);
    }
  }

  @override
  bool get isAuthenticated {
    final user = getCurrentUser();
    return user != null && user.token != null;
  }

  @override
  AuthModel? getCurrentUser() {
    return _localDataSource.getUserSync();
  }
}
```

### Auto-Login After Registration

```dart
// Di AuthBloc
Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
  emit(AuthLoading());

  // Step 1: Register user
  final registerResult = await _authRepository.register(/*...*/);

  await registerResult.fold(
    onSuccess: (user) async {
      // Step 2: Check if token included in registration
      if (user.token == null || user.token!.isEmpty) {
        // Auto-login untuk mendapatkan token
        final loginResult = await _authRepository.login(
          event.email,
          event.password
        );

        loginResult.fold(
          onSuccess: (loggedInUser) {
            // Auto-login successful → Home
            emit(AuthAuthenticated(loggedInUser));
          },
          onError: (error) {
            // Auto-login failed → Login page dengan message
            emit(AuthRegisteredButNotLoggedIn(user.email));
          },
        );
      } else {
        // Token included in registration → Home
        emit(AuthAuthenticated(user));
      }
    },
    onError: (error) {
      // Registration failed → Stay on register page
      emit(AuthError(error.getLocalizedMessage()));
    },
  );
}
```

## Request/Response Examples

### Complete Login Flow

```dart
// 1. User input
final email = 'john.doe@example.com';
final password = 'securePassword123';

// 2. API Request
POST https://wallet-testing-murex.vercel.app/auth/login
Content-Type: application/json

{
  "email": "john.doe@example.com",
  "password": "securePassword123"
}

// 3. API Response
HTTP/1.1 200 OK
Content-Type: application/json

{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
}

// 4. Local Storage
SharedPreferences:
- auth_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
- user_data: "{\"id\": -1, \"email\": \"john.doe@example.com\", \"access_token\": \"...\"}"
```

### Wallet Data Retrieval

```dart
// 1. API Request with Auth
GET https://wallet-testing-murex.vercel.app/wallets
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

// 2. API Response
HTTP/1.1 200 OK
Content-Type: application/json

[
  {
    "id": 1,
    "balance": 1250.75,
    "currency": "USD",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T14:22:00Z"
  },
  {
    "id": 2,
    "balance": 850.50,
    "currency": "EUR",
    "createdAt": "2024-01-15T11:00:00Z",
    "updatedAt": "2024-01-15T11:00:00Z"
  }
]

// 3. Frontend Processing
final wallets = response.map((json) => WalletModel.fromJson(json)).toList();

// 4. UI Display
"USD Wallet": $1,250.75  // Auto-generated name
"EUR Wallet": €850.50    // Currency symbol based on type
```

## Performance Considerations

### Request Optimization

```dart
class OptimizedWalletRepository {
  // Cache dengan expiry time
  static const Duration _cacheExpiry = Duration(minutes: 5);
  DateTime? _lastFetchTime;

  @override
  Future<List<WalletModel>> getWallets({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final shouldRefresh = forceRefresh ||
        _lastFetchTime == null ||
        now.difference(_lastFetchTime!) > _cacheExpiry;

    if (!shouldRefresh) {
      final cachedWallets = await _localDataSource.getWallets();
      if (cachedWallets.isNotEmpty) {
        return cachedWallets;
      }
    }

    // Fetch from API
    final wallets = await _remoteDataSource.getWallets();

    // Update cache
    await _localDataSource.saveWallets(wallets);
    _lastFetchTime = now;

    return wallets;
  }
}
```

### Pagination Implementation

```dart
class TransactionPagination {
  static const int defaultLimit = 20;

  Future<List<TransactionModel>> loadMoreTransactions({
    required String walletId,
    required int currentPage,
  }) async {
    final response = await _client.apiRequest(
      url: baseUrl,
      method: RequestMethod.get,
      apiPath: '/wallets/$walletId/transactions?page=${currentPage + 1}&limit=$defaultLimit',
    );

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final hasMore = responseData['pagination']['currentPage'] <
                   responseData['pagination']['totalPages'];

    return {
      'transactions': (responseData['data'] as List<dynamic>)
          .map((json) => TransactionModel.fromJson(json))
          .toList(),
      'hasMore': hasMore,
    };
  }
}
```

Dokumentasi API ini memberikan panduan lengkap untuk integrasi dengan backend API, termasuk authentication, data management, error handling, dan optimisasi performa.