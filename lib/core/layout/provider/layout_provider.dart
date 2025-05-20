import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'layout_provider.g.dart';

/// 渐变颜色状态提供者
@riverpod
class GradientColor extends _$GradientColor {
  @override
  List<Color> build() {
    // 初始化渐变颜色列表
    return [Colors.blue, Colors.purple];
  }

  /// 设置新的渐变颜色列表
  void setColors(List<Color> newColors) {
    state = newColors;
  }
}

@riverpod
class Language extends _$Language {
  @override
  String build() {
    return 'en';
  }

  void setLanguage(String newLanguage) {
      state = newLanguage;
  }
}



// 定义主题状态
class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;

  ThemeState({required this.themeMode, required this.primaryColor});
}

// 创建一个简单的StateNotifier来管理主题状态
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState(themeMode: ThemeMode.light, primaryColor: Colors.blue));

  void setThemeMode(ThemeMode mode) {
    state = ThemeState(themeMode: mode, primaryColor: state.primaryColor);
  }

  void setPrimaryColor(Color color) {
    state = ThemeState(themeMode: state.themeMode, primaryColor: color);
  }
}

// 创建一个Provider来提供ThemeNotifier
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// 创建一个简单的Provider来直接访问当前的ThemeMode
final themeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeNotifierProvider).themeMode;
});
