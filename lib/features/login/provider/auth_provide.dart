import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'secure_storage_service.dart';

// Auth state class
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;
  bool get hasSubscription => user?.isVip != 0 ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(secureStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _baseUrl = 'http://127.0.0.1:8080/media/auth';

  final SecureStorageService _secureStorage;

  AuthNotifier(this._secureStorage) : super(const AuthState()) {
    // Check if user is already logged in
    _checkCurrentUser();
  }

  // Check if there's a saved user session
  Future<void> _checkCurrentUser() async {
    try {
      state = state.copyWith(isLoading: true);

      // Try to load user data from secure storage
      final userData = await _secureStorage.read(_userKey);

      if (userData != null) {
        // Parse the stored user data
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);

        print('【启动】从安全存储中恢复用户会话: ${user.email}');
        state = state.copyWith(user: user, isLoading: false);
      } else {
        print('【启动】未找到已保存的用户会话');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('【启动】读取用户会话时出错: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Save user data to secure storage
  Future<void> _saveUserData(UserModel user) async {
    try {
      final userData = jsonEncode(user.toJson());
      await _secureStorage.write(_userKey, userData);
      print('【用户数据】已安全保存用户数据');
    } catch (e) {
      print('【用户数据】保存用户数据时出错: $e');
    }
  }

  // Save auth token to secure storage
  Future<void> _saveAuthToken(String token) async {
    try {
      await _secureStorage.write(_tokenKey, token);
      print('【认证】已安全保存认证令牌');
    } catch (e) {
      print('【认证】保存认证令牌时出错: $e');
    }
  }

  // Get auth token from secure storage
  Future<String?> _getAuthToken() async {
    try {
      return await _secureStorage.read(_tokenKey);
    } catch (e) {
      print('【认证】获取认证令牌时出错: $e');
      return null;
    }
  }

  Future<void> signInWithEmail(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['code'] == 200) {
        // Login successful
        final token = responseData['data']['token'] as String;

        // Save token
        await _saveAuthToken(token);

        // Fetch user info with token
        await _fetchUserInfo(token);
      } else {
        // Login failed
        final errorMessage = responseData['msg'] ?? '登录失败';
        state = state.copyWith(isLoading: false, error: errorMessage);
      }
    } catch (e) {
      final errorMsg = _handleAuthError(e);
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<void> registerWithEmail(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Generate a random UUID (in a real app you might want to use a proper UUID generator)
      final uuid = DateTime.now().microsecondsSinceEpoch.toString();

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'code': '40', // Using the example code from documentation
          'uuid': uuid,
          'platform': 'macos', // You might want to detect platform dynamically
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['code'] == 200) {
        // Registration successful
        state = state.copyWith(isLoading: false);

        // Login after successful registration
        await signInWithEmail(username, password);
      } else {
        // Registration failed
        final errorMessage = responseData['msg'] ?? '注册失败';
        state = state.copyWith(isLoading: false, error: errorMessage);
      }
    } catch (e) {
      final errorMsg = _handleAuthError(e);
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<void> _fetchUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getInfo'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['code'] == 200) {
        final userData = responseData['data'] as Map<String, dynamic>;

        // Create user model from response data
        final user = UserModel(
          userId: userData['userId'].toString(),
          userName: userData['userName'],
          email: userData['email'] ?? '',
          isVip: userData['isVip'] ?? 0,
          vipExpire: userData['vipExpire'] ?? '',
          avatar: userData['avatar'] ?? '',
        );

        // Save user data
        await _saveUserData(user);

        // Update state
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: '获取用户信息失败');
      }
    } catch (e) {
      final errorMsg = _handleAuthError(e);
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<void> refreshUserInfo() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final token = await _getAuthToken();
      if (token == null) {
        state = state.copyWith(isLoading: false, error: '未登录');
        return;
      }

      await _fetchUserInfo(token);
    } catch (e) {
      final errorMsg = _handleAuthError(e);
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      // Clear stored user data
      await _secureStorage.delete(_userKey);
      await _secureStorage.delete(_tokenKey);

      // Update state
      state = const AuthState();
    } catch (e) {
      print('【退出登录】退出登录时出错: $e');
      state = const AuthState();
    }
  }

  String _handleAuthError(dynamic error) {
    print('【认证错误】$error');

    if (error is http.ClientException) {
      return '网络连接错误，请检查您的网络连接';
    } else if (error is FormatException) {
      return '数据格式错误，请稍后重试';
    } else if (error is Exception) {
      return '请求过程中发生错误: ${error.toString()}';
    }

    return '发生未知错误，请稍后重试';
  }
}
