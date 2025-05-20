import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trans_video_x/core/cos/services/cos_service.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:trans_video_x/core/layout/provider/layout_provider.dart';
import 'package:trans_video_x/routes/app_route.dart';
import 'package:trans_video_x/core/hive/hive_init.dart';
import 'package:trans_video_x/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');



  // 初始化Hive和注册适配器
  await initHive();

  // 初始化腾讯云 COS 服务
  try {
    final appId = dotenv.env['COS_APP_ID'] ?? "";
    final secretId = dotenv.env['COS_SECRET_ID'] ?? "";
    final secretKey = dotenv.env['COS_SECRET_KEY'] ?? "";
    final bucketName = dotenv.env['COS_BUCKET'] ?? "";
    final region = dotenv.env['COS_REGION'] ?? "";

    print(appId);
    print(secretId);
    print(secretKey);
    print(bucketName);
    print(region);

    ApiService().startServer();
    await CosService.initialize(
      appId: appId,
      secretId: secretId,
      secretKey: secretKey,
      bucketName: bucketName,
      region: region,
    );
    debugPrint(
      'COS service initialized with bucket: $bucketName, region: $region',
    );
  } catch (e) {
    debugPrint('COS service initialization failed: $e');
    // We'll continue and allow reconfiguration in the settings
  }

  // 初始化 easy_localization
  await EasyLocalization.ensureInitialized();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', ''), Locale('zh', '')],
        path: 'assets/translations', // 翻译文件路径
        fallbackLocale: const Locale('en', ''), // 默认语言
        child: const BaseApp(),
      ),
    ),
  );
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(900, 600);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "video_translator";
    win.show();
  });
}

class BaseApp extends ConsumerWidget {
  const BaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeState = ref.watch(themeNotifierProvider);
    final appRouter = ref.watch(routerProvider);

    final primaryColor = themeState.primaryColor;

    return MaterialApp.router(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      routerDelegate: appRouter.delegate(
        navigatorObservers: () => [FlutterSmartDialog.observer],
      ),
      theme: ThemeData.light().copyWith(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeState.themeMode,
      // 使用 easy_localization 的 locale 和 localizationsDelegates
      locale: context.locale, // 从 EasyLocalization 获取当前语言
      supportedLocales: context.supportedLocales, // 从 EasyLocalization 获取支持的语言
      localizationsDelegates: context.localizationDelegates, // 添加本地化代理
      builder: FlutterSmartDialog.init(),
      routeInformationParser: appRouter.defaultRouteParser(),
    );
  }
}
