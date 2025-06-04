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

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get chooseTheme => 'Pilih Tema';

  @override
  String get chooseLanguage => 'Pilih Bahasa';

  @override
  String get english => 'Bahasa Inggris';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get myWallets => 'Dompet Saya';

  @override
  String get noWalletsFound => 'Tidak ada dompet';

  @override
  String get addWalletToStart => 'Tambahkan satu untuk memulai!';

  @override
  String get addWallet => 'Tambah Dompet';

  @override
  String get walletDetails => 'Detail Dompet';

  @override
  String get deposit => 'Setor';

  @override
  String get withdraw => 'Tarik';

  @override
  String get transfer => 'Transfer';

  @override
  String get recentTransactions => 'Transaksi Terbaru';

  @override
  String get addNewWallet => 'Tambah Dompet Baru';

  @override
  String get walletInformation => 'Informasi Dompet';

  @override
  String get walletName => 'Nama Dompet';

  @override
  String get pleaseEnterWalletName => 'Silakan masukkan nama dompet';

  @override
  String get initialBalance => 'Saldo Awal';

  @override
  String get pleaseEnterInitialBalance => 'Silakan masukkan saldo awal';

  @override
  String get pleaseEnterValidNumber => 'Silakan masukkan angka yang valid';

  @override
  String get createWallet => 'Buat Dompet';

  @override
  String get walletCreatedSuccessfully => 'Dompet berhasil dibuat!';

  @override
  String get somethingWentWrong => 'Terjadi kesalahan';

  @override
  String get transactions => 'Transaksi';

  @override
  String get failedToLoadWallets => 'Gagal memuat dompet';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get myWallet => 'Dompet Saya';

  @override
  String get currentBalance => 'Saldo Saat Ini';

  @override
  String walletId(String id) {
    return 'ID Dompet: $id';
  }

  @override
  String updated(String time) {
    return 'Diperbarui $time';
  }

  @override
  String daysAgo(int days) {
    return '${days}h lalu';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}j lalu';
  }

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m lalu';
  }

  @override
  String get justNow => 'Baru saja';

  @override
  String get totalIncome => 'Total Pemasukan';

  @override
  String get totalExpense => 'Total Pengeluaran';

  @override
  String get viewAll => 'Lihat Semua';

  @override
  String get noTransactionsYet => 'Belum ada transaksi';

  @override
  String get transactionsWillAppearHere => 'Transaksi Anda akan muncul di sini';

  @override
  String get allTransactionsLoaded => 'Semua transaksi telah dimuat';

  @override
  String transactionInTotal(int count, String suffix) {
    return '$count transaksi$suffix total';
  }

  @override
  String get oopsSomethingWentWrong => 'Ups! Terjadi kesalahan';

  @override
  String get editWallet => 'Edit Dompet';

  @override
  String get transactionHistory => 'Riwayat Transaksi';

  @override
  String get walletSettings => 'Pengaturan Dompet';

  @override
  String get loadingTransactions => 'Memuat transaksi...';

  @override
  String get loadingMoreTransactions => 'Memuat lebih banyak transaksi...';

  @override
  String get pullToRefresh => 'Tarik untuk menyegarkan';

  @override
  String get refreshing => 'Sedang memperbarui...';

  @override
  String get allTransactions => 'Semua Transaksi';

  @override
  String get filterTransactions => 'Filter Transaksi';

  @override
  String get newTransaction => 'Transaksi Baru';

  @override
  String get depositMoney => 'Setor Uang';

  @override
  String get withdrawMoney => 'Tarik Uang';

  @override
  String get amount => 'Jumlah';

  @override
  String get enterAmount => 'Masukkan jumlah';

  @override
  String get description => 'Deskripsi';

  @override
  String get enterDescription => 'Masukkan deskripsi (opsional)';

  @override
  String get referenceId => 'ID Referensi';

  @override
  String get enterReferenceId => 'Masukkan ID referensi (opsional)';

  @override
  String get proceed => 'Lanjutkan';

  @override
  String get processing => 'Memproses...';

  @override
  String get transactionSuccessful => 'Transaksi Berhasil!';

  @override
  String get transactionFailed => 'Transaksi Gagal';

  @override
  String get pleaseEnterAmount => 'Harap masukkan jumlah';

  @override
  String get invalidAmount => 'Harap masukkan jumlah yang valid';

  @override
  String minimumAmount(String amount) {
    return 'Jumlah minimum adalah $amount';
  }

  @override
  String maximumAmount(String amount) {
    return 'Jumlah maksimum adalah $amount';
  }

  @override
  String get insufficientBalance => 'Saldo tidak mencukupi';

  @override
  String availableBalance(String balance) {
    return 'Saldo Tersedia: $balance';
  }

  @override
  String get confirmTransaction => 'Konfirmasi Transaksi';

  @override
  String confirmDepositMessage(String amount) {
    return 'Apakah Anda yakin ingin menyetor $amount?';
  }

  @override
  String confirmWithdrawMessage(String amount) {
    return 'Apakah Anda yakin ingin menarik $amount?';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get transactionDetails => 'Detail Transaksi';

  @override
  String get transactionType => 'Jenis';

  @override
  String get transactionDate => 'Tanggal';

  @override
  String get transactionReference => 'Referensi';

  @override
  String get noReference => 'Tidak Ada Referensi';

  @override
  String get income => 'Pemasukan';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get filterByType => 'Filter berdasarkan Jenis';

  @override
  String get filterByDate => 'Filter berdasarkan Tanggal';

  @override
  String get allTypes => 'Semua Jenis';

  @override
  String get last7Days => '7 Hari Terakhir';

  @override
  String get last30Days => '30 Hari Terakhir';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String get customRange => 'Rentang Kustom';

  @override
  String get applyFilter => 'Terapkan Filter';

  @override
  String get clearFilter => 'Hapus Filter';
}
