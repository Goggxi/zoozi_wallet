// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Zoozi Wallet';

  @override
  String get welcome => 'Selamat datang di Zoozi Wallet';

  @override
  String get welcomeBack => 'Selamat datang kembali\ndi Zoozi wallet';

  @override
  String get createAccount => 'Buat akun\ngratis dan mudah';

  @override
  String get login => 'Masuk';

  @override
  String get register => 'Daftar';

  @override
  String get signUp => 'Daftar';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get confirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String get fullName => 'Nama Lengkap';

  @override
  String get haveAccount => 'Sudah punya akun? ';

  @override
  String get dontHaveAccount => 'Belum punya akun? ';

  @override
  String get emailRequired => 'Email wajib diisi';

  @override
  String get invalidEmail => 'Masukkan email yang valid';

  @override
  String get passwordRequired => 'Kata sandi wajib diisi';

  @override
  String get passwordLength => 'Kata sandi minimal 8 karakter';

  @override
  String get nameRequired => 'Nama wajib diisi';

  @override
  String get nameLength => 'Nama minimal 3 karakter';

  @override
  String get confirmPasswordRequired => 'Konfirmasi kata sandi wajib diisi';

  @override
  String get passwordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get theme => 'Tema';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get security => 'Keamanan';

  @override
  String get about => 'Tentang';

  @override
  String get logout => 'Keluar';

  @override
  String get unauthorizedError => 'Akses tidak sah. Silakan login kembali.';

  @override
  String get invalidCredentialsError =>
      'Email atau kata sandi salah. Silakan coba lagi.';

  @override
  String get notFoundError => 'Data yang diminta tidak ditemukan.';

  @override
  String get internalServerError =>
      'Terjadi kesalahan. Silakan coba lagi nanti.';

  @override
  String get unknownError =>
      'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';

  @override
  String get passwordLengthError => 'Kata sandi harus minimal 8 karakter.';

  @override
  String get invalidCurrencyError =>
      'Mata uang tidak valid. Silakan pilih USD, EUR, atau GBP.';

  @override
  String get passwordTypeError => 'Kata sandi harus berupa teks.';

  @override
  String get amountValidationError =>
      'Jumlah harus berupa angka positif yang valid.';

  @override
  String get invalidJsonError =>
      'Format JSON tidak valid. Silakan periksa input Anda.';

  @override
  String get networkError =>
      'Terjadi kesalahan jaringan. Silakan periksa koneksi Anda.';

  @override
  String get requestTimeout => 'Permintaan waktu habis. Silakan coba lagi.';

  @override
  String get forbiddenError =>
      'Anda tidak memiliki izin untuk mengakses sumber daya ini.';

  @override
  String get badRequestError =>
      'Permintaan tidak valid. Silakan periksa input Anda.';

  @override
  String get validationError => 'Validasi gagal. Silakan periksa input Anda.';

  @override
  String cacheReadError(String key) {
    return 'Gagal membaca $key dari cache.';
  }

  @override
  String cacheWriteError(String key) {
    return 'Gagal menulis $key ke cache.';
  }

  @override
  String cacheDeleteError(String key) {
    return 'Gagal menghapus $key dari cache.';
  }

  @override
  String get cacheClearError => 'Gagal menghapus data penyimpanan.';
}
