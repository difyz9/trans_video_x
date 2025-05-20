
import 'env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProdEnv implements EnvConfig {
  @override
  String get apiBaseUrl => dotenv.get('API_BASE_URL');

  @override
  String get sentryDsn => dotenv.get('SENTRY_DSN');

  @override
  bool get debugEnabled => false; // 生产环境强制关闭debug
}