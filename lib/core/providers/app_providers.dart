import 'package:firstlook/core/network/services/dio_client.dart';
import 'package:firstlook/core/storage/hive_service.dart';
import 'package:firstlook/core/storage/local_storage_keys.dart';
import 'package:firstlook/core/storage/secure_token_storage.dart';
import 'package:firstlook/features/apps/data/firstlook_remote_data_source.dart';
import 'package:firstlook/features/apps/data/firstlook_repository.dart';
import 'package:firstlook/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:firstlook/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firstlook/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:firstlook/features/auth/domain/repositories/auth_repository.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/services/environment_service.dart';
import 'package:firstlook/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loggerServiceProvider = Provider<LoggerService>(
  (Ref ref) => LoggerService(),
);

final environmentServiceProvider = Provider<EnvironmentService>(
  (Ref ref) => EnvironmentService.instance,
);

final secureTokenStorageProvider = Provider<SecureTokenStorage>(
  (Ref ref) => const SecureTokenStorage(),
);

final dioClientProvider = Provider<DioClient>(
  (Ref ref) => DioClient(
    ref: ref,
    environmentService: ref.watch(environmentServiceProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    loggerService: ref.watch(loggerServiceProvider),
  ),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (Ref ref) => AuthRemoteDataSource(
    dio: ref.watch(dioClientProvider).instance,
  ),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (Ref ref) => AuthLocalDataSource(
    tokenStorage: ref.watch(secureTokenStorageProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  ),
);

final firstLookRemoteDataSourceProvider = Provider<FirstLookRemoteDataSource>(
  (Ref ref) => FirstLookRemoteDataSource(
    dio: ref.watch(dioClientProvider).instance,
  ),
);

final firstLookRepositoryProvider = Provider<FirstLookRepository>(
  (Ref ref) => FirstLookRepository(
    remoteDataSource: ref.watch(firstLookRemoteDataSourceProvider),
  ),
);

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final themeModeProvider = StateProvider<ThemeMode>(
  (Ref ref) => ThemeMode.system,
);

class AppLocaleController extends StateNotifier<Locale> {
  AppLocaleController()
      : super(
          Locale(
            HiveService.preferencesBox.get(
              LocalStorageKeys.languageCode,
              defaultValue: 'tr',
            ) as String,
          ),
        );

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'tr' && locale.languageCode != 'en') {
      return;
    }

    state = locale;
    await HiveService.preferencesBox.put(
      LocalStorageKeys.languageCode,
      locale.languageCode,
    );
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleController, Locale>(
  (Ref ref) => AppLocaleController(),
);

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (!EnvironmentService.instance.isDebugLoggingEnabled) {
      return;
    }

    final LoggerService logger = container.read(loggerServiceProvider);
    logger.debug(
      'Provider updated: ${provider.name ?? provider.runtimeType}',
    );
  }
}
