// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:zoozi_wallet/core/router/app_router.dart' as _i548;
import 'package:zoozi_wallet/core/storage/local_storage.dart' as _i937;
import 'package:zoozi_wallet/core/utils/logger/app_logger.dart' as _i755;
import 'package:zoozi_wallet/core/utils/network/http_client.dart' as _i74;
import 'package:zoozi_wallet/di/modue.dart' as _i516;
import 'package:zoozi_wallet/features/auth/data/datasources/auth_local_data_source.dart'
    as _i54;
import 'package:zoozi_wallet/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i103;
import 'package:zoozi_wallet/features/auth/domain/repositories/auth_repository.dart'
    as _i173;
import 'package:zoozi_wallet/features/auth/presentation/bloc/auth_bloc.dart'
    as _i138;
import 'package:zoozi_wallet/features/settings/domain/repositories/theme_repository.dart'
    as _i897;
import 'package:zoozi_wallet/features/settings/presentation/bloc/theme_bloc.dart'
    as _i786;
import 'package:zoozi_wallet/features/wallet/data/datasources/wallet_remote_data_source.dart'
    as _i411;
import 'package:zoozi_wallet/features/wallet/domain/repositories/wallet_repository.dart'
    as _i126;
import 'package:zoozi_wallet/features/wallet/presentation/bloc/wallet_bloc.dart'
    as _i424;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i548.AppRouter>(() => _i548.AppRouter());
    gh.singleton<_i937.ILocalStorage>(
        () => _i937.LocalStorage(gh<_i460.SharedPreferences>()));
    gh.singleton<_i755.IAppLogger>(() => _i755.AppLogger());
    gh.factory<_i897.IThemeRepository>(
        () => _i897.ThemeRepository(gh<_i937.ILocalStorage>()));
    gh.singleton<_i786.ThemeBloc>(
        () => _i786.ThemeBloc(gh<_i897.IThemeRepository>()));
    gh.factory<_i74.HttpClient>(() => _i74.HttpClient(
          gh<_i519.Client>(),
          gh<_i755.IAppLogger>(),
        ));
    gh.factory<_i103.IAuthRemoteDataSource>(() => _i103.AuthRemoteDataSource(
          gh<_i74.HttpClient>(),
          gh<_i755.IAppLogger>(),
        ));
    gh.factory<_i54.IAuthLocalDataSource>(() => _i54.AuthLocalDataSource(
          gh<_i937.ILocalStorage>(),
          gh<_i755.IAppLogger>(),
        ));
    gh.factory<_i173.IAuthRepository>(() => _i173.AuthRepository(
          gh<_i103.IAuthRemoteDataSource>(),
          gh<_i54.IAuthLocalDataSource>(),
        ));
    gh.factory<_i411.IWalletRemoteDataSource>(
        () => _i411.WalletRemoteDataSource(gh<_i74.HttpClient>()));
    gh.factory<_i126.IWalletRepository>(
        () => _i126.WalletRepository(gh<_i411.IWalletRemoteDataSource>()));
    gh.factory<_i138.AuthBloc>(
        () => _i138.AuthBloc(gh<_i173.IAuthRepository>()));
    gh.factory<_i424.WalletBloc>(
        () => _i424.WalletBloc(gh<_i126.IWalletRepository>()));
    return this;
  }
}

class _$RegisterModule extends _i516.RegisterModule {}
