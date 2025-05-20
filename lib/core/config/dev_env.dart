import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'env_config.dart';


class DevEnv implements EnvConfig {
  @override
  String get apiBaseUrl => dotenv.get('API_BASE_URL');

  @override
  String get sentryDsn => dotenv.get('SENTRY_DSN');

  @override
  bool get debugEnabled => dotenv.get('DEBUG') == 'true';
}
