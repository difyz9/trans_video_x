
import 'dev_env.dart';
import 'prod_env.dart';

abstract class EnvConfig {
  String get apiBaseUrl;
  String get sentryDsn;
  bool get debugEnabled;
  
  factory EnvConfig.fromEnv() {
    final env = const String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' ? ProdEnv() : DevEnv();
  }
}