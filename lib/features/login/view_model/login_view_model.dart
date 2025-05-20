import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'login_view_model.g.dart';

class LoginRequest {
  final String username;
  final String password;
  LoginRequest({required this.username, required this.password});
}
// 定义登录响应的数据模型
class LoginResponse {
  final bool success;
  final String message;
  LoginResponse({required this.success, required this.message});
}

@riverpod

class LoginViewModel extends _$LoginViewModel{

@override
  Future<LoginResponse> build() {
    // 这里可以进行初始化操作，比如初始化网络请求客户端等
    return Future.value(LoginResponse(success: false, message: '未执行登录操作'));
  }
  // 定义登录方法
  Future<LoginResponse> login(LoginRequest request) async {
    // 模拟登录逻辑，这里可以替换为实际的网络请求
    await Future.delayed(const Duration(seconds: 1));
    if (request.username == 'admin' && request.password == '123456') {
      return LoginResponse(success: true, message: '登录成功');
    } else {
      return LoginResponse(success: false, message: '用户名或密码错误');
    }
}
}