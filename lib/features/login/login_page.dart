import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/auth_provide.dart';
import 'package:trans_video_x/core/widget/draggable_window_title_bar.dart'; // Corrected import path

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  final Function(bool)? onLoginResult;
  const LoginScreen({this.onLoginResult, super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isEmailLogin = true; // Set email login as default
  bool isRegisterMode = false; // Toggle between login and register
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSuccessfulLogin() {
    print('登录成功');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('登录成功')),
    );
    context.router.pushPath("/app/home");
    widget.onLoginResult?.call(true);
  }

  void _handleLoginError(String message) {
    print('登录失败: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _loginWithEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await ref.read(authProvider.notifier).signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        
        final authState = ref.read(authProvider);
        
        if (authState.error == null && authState.isLoggedIn) {
          _handleSuccessfulLogin();
        } else if (authState.error != null) {
          _handleLoginError(authState.error!);
        }
      } catch (e) {
        _handleLoginError('登录失败: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _registerWithEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await ref.read(authProvider.notifier).registerWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        
        final authState = ref.read(authProvider);
        
        if (authState.error == null && authState.isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('注册成功并已登录')),
          );
          _handleSuccessfulLogin();
        } else if (authState.error != null) {
          _handleLoginError(authState.error!);
        }
      } catch (e) {
        _handleLoginError('注册失败: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    _isLoading = authState.isLoading;

    return Scaffold(
      // Replace AppBar with DraggableWindowTitleBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // Or appWindow.titleBarHeight if bitsdojo_window is initialized
        child: DraggableWindowTitleBar(
          titleContent: Text(""),
          // titleContent: Text(isRegisterMode ? "注册" : "登录"),
          // You can customize other properties of DraggableWindowTitleBar here if needed
          // e.g., backgroundColor, showMinimizeButton, etc.
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0), // Add padding around the SingleChildScrollView
          child: Card( // Wrap content in a Card
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Add a logo or icon
                  FlutterLogo(size: 80, style: FlutterLogoStyle.markOnly),
                  const SizedBox(height: 24),
                  Text(
                    isRegisterMode ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  if (isEmailLogin)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration( // Improved decoration
                              labelText: '用户名',
                              hintText: '请输入您的邮箱地址',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入用户名';
                              }
                              // if (!value.contains('@')) { // Basic email validation
                              //   return '请输入有效的邮箱地址';
                              // }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration( // Improved decoration
                              labelText: '密码',
                              hintText: '请输入您的密码',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入密码';
                              }
                              if (value.length < 6) {
                                return '密码长度至少为6位';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : (isRegisterMode ? _registerWithEmail : _loginWithEmail),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(isRegisterMode ? '注册' : '登录'),
                            ),
                          ),
                          const SizedBox(height: 16), // Add some space before the toggle button
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      isRegisterMode = !isRegisterMode;
                                      _formKey.currentState?.reset(); // Reset form on mode toggle
                                    });
                                  },
                            child: Text(
                              isRegisterMode ? '已有账号？点击登录' : '没有账号？点击注册',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
