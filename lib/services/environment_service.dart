import 'package:firstlook/core/enums/app_environment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentService {
  EnvironmentService._();

  static final EnvironmentService instance = EnvironmentService._();

  static const String _environmentFlag =
      String.fromEnvironment('ENV', defaultValue: 'staging');

  static Future<void> initialize() async {
    final String fileName = switch (_environmentFlag) {
      'production' => '.env.production',
      'staging' => '.env.staging',
      _ => '.env.dev',
    };

    await dotenv.load(fileName: fileName);
  }

  String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  int get connectTimeoutMs => _readInt('CONNECT_TIMEOUT_MS', 30000);

  int get receiveTimeoutMs => _readInt('RECEIVE_TIMEOUT_MS', 30000);

  int get sendTimeoutMs => _readInt('SEND_TIMEOUT_MS', 30000);

  AppEnvironment get environment {
    final String rawValue = dotenv.env['APP_ENV'] ?? 'development';
    return AppEnvironment.values.firstWhere(
      (AppEnvironment value) => value.name == rawValue,
      orElse: () => AppEnvironment.development,
    );
  }

  bool get isProduction => environment == AppEnvironment.production;

  bool get isDebugLoggingEnabled => !isProduction;

  int _readInt(String key, int fallback) {
    return int.tryParse(dotenv.env[key] ?? '') ?? fallback;
  }
}
