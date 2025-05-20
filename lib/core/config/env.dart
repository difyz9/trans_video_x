import 'env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static late EnvConfig _config;

  static EnvConfig get config => _config;

  static Future<void> init() async {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    await dotenv.load(fileName: '.env.$env');
    _config = EnvConfig.fromEnv();
  }
}