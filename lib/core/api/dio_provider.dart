import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/logger_provider.dart';
import 'error/api_error_handle_provider.dart';
import 'package:trans_video_x/core/constants/app_constants.dart';

part 'dio_provider.g.dart';

// https://github.com/alibaba/flutter-go 
// 参考阿里的 项目 lib/utils/net_urils.dart 设置超时时间为 30000 
@riverpod
Dio dio(Ref ref) {
  String token = ''; // 从环境变量获取 token
  String baseUrl = '${AppConstants.baseUrl}'; // 从环境变量获取基础 URL

  final logger = ref.watch(loggerProvider); // 获取日志记录器
  final apiErrorHandle = ref.watch(apiErrorHandleNotifierProvider.notifier); // 获取错误处理器

Map<String, dynamic> optHeader = {
  'accept-language': 'zh-cn',
  'content-type': 'application/json'
};


// 30000
  final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30000), // 连接超时时间
    receiveTimeout: const Duration(seconds: 30000), // 接收数据超时时间
    sendTimeout: const Duration(seconds: 30000),    // 发送数据超时时间
    headers: optHeader
  ))
      ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['Content-Type'] = 'application/json'; // 添加 Content-Type 头
          options.baseUrl = baseUrl;

          // logger.d('---interceptor--- onRequest: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // logger.d('---interceptor--- onResponse: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // logger.d('---interceptor--- onError: ${e.message}');
          apiErrorHandle.reportError();
          return handler.next(e);
        },
      ),
    );

   

  return dio;
}

// 自定义 MyRequestOptions 类保持不变
class MyRequestOptions extends RequestOptions {
  @override
  Uri get uri {
    String url = path;
    if (!url.startsWith(RegExp(r'https?:'))) {
      url = baseUrl + url;
      final s = url.split(':/');
      if (s.length == 2) {
        url = '${s[0]}:/${s[1].replaceAll('//', '/')}';
      }
    }

    final queryParameters = this.queryParameters;

    if (queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries.map((e) {
        return '${e.key}=${e.value}';
      }).join('&');

      url += (url.contains('?') ? '&' : '?') + queryString;
    }
    return Uri.parse(url).normalizePath();
  }
}
