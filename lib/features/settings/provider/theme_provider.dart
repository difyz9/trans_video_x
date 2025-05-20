import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Add the shared preferences provider if missing
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overridden in main.dart');
});

class ThemeSettings {
  final Color primaryColor;
  final ThemeMode themeMode;
  final double colorBrightness;
  final double colorSaturation;

  // Standard color options
  static final List<Color> colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  ThemeSettings({
    this.primaryColor = Colors.blue,
    this.themeMode = ThemeMode.system,
    this.colorBrightness = 0.0,
    this.colorSaturation = 1.0,
  });

  ThemeSettings copyWith({
    Color? primaryColor,
    ThemeMode? themeMode,
    double? colorBrightness,
    double? colorSaturation,
  }) {
    return ThemeSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      themeMode: themeMode ?? this.themeMode,
      colorBrightness: colorBrightness ?? this.colorBrightness,
      colorSaturation: colorSaturation ?? this.colorSaturation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColorValue': primaryColor.value,
      'themeModeIndex': themeMode.index,
      'colorBrightness': colorBrightness,
      'colorSaturation': colorSaturation,
    };
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      primaryColor: Color(json['primaryColorValue'] ?? Colors.blue.value),
      themeMode: ThemeMode.values[json['themeModeIndex'] ?? 0],
      colorBrightness: json['colorBrightness'] ?? 0.0,
      colorSaturation: json['colorSaturation'] ?? 1.0,
    );
  }

  // Generate modified color based on brightness and saturation
  Color get adjustedColor {
    final HSLColor hsl = HSLColor.fromColor(primaryColor);
    
    // Apply brightness adjustment
    double lightness = hsl.lightness;
    if (colorBrightness > 0) {
      lightness = lightness + ((1.0 - lightness) * colorBrightness);
    } else if (colorBrightness < 0) {
      lightness = lightness * (1.0 + colorBrightness);
    }
    
    // Apply saturation adjustment
    return HSLColor.fromAHSL(
      hsl.alpha,
      hsl.hue,
      hsl.saturation * colorSaturation,
      lightness,
    ).toColor();
  }
  
  // Get color name for accessibility
  String get colorName {
    final Map<int, String> colorNames = {
      Colors.blue.value: '蓝色',
      Colors.red.value: '红色',
      Colors.green.value: '绿色',
      Colors.purple.value: '紫色',
      Colors.orange.value: '橙色',
      Colors.teal.value: '青色',
      Colors.pink.value: '粉色',
      Colors.indigo.value: '靛青色',
    };
    
    return colorNames[primaryColor.value] ?? '自定义颜色';
  }

  // Get theme mode name
  String get themeModeName {
    switch (themeMode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  // Generate theme data
  ThemeData getThemeData(BuildContext? context, {bool isDark = false}) {
    final Color adjustedPrimaryColor = adjustedColor;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: adjustedPrimaryColor,
      primarySwatch: MaterialColor(adjustedPrimaryColor.value, {
        50: _adjustBrightness(adjustedPrimaryColor, 0.9),
        100: _adjustBrightness(adjustedPrimaryColor, 0.8),
        200: _adjustBrightness(adjustedPrimaryColor, 0.6),
        300: _adjustBrightness(adjustedPrimaryColor, 0.4),
        400: _adjustBrightness(adjustedPrimaryColor, 0.2),
        500: adjustedPrimaryColor,
        600: _adjustBrightness(adjustedPrimaryColor, -0.1),
        700: _adjustBrightness(adjustedPrimaryColor, -0.2),
        800: _adjustBrightness(adjustedPrimaryColor, -0.3),
        900: _adjustBrightness(adjustedPrimaryColor, -0.4),
      }),
      colorScheme: ColorScheme.fromSeed(
        seedColor: adjustedPrimaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  // Helper function to adjust color brightness
  Color _adjustBrightness(Color color, double factor) {
    assert(factor >= -1.0 && factor <= 1.0);
    
    int red = color.red;
    int green = color.green;
    int blue = color.blue;
    
    if (factor < 0) {
      // Darken color
      red = (red * (1 + factor)).round().clamp(0, 255);
      green = (green * (1 + factor)).round().clamp(0, 255);
      blue = (blue * (1 + factor)).round().clamp(0, 255);
    } else {
      // Lighten color
      red = (red + ((255 - red) * factor)).round().clamp(0, 255);
      green = (green + ((255 - green) * factor)).round().clamp(0, 255);
      blue = (blue + ((255 - blue) * factor)).round().clamp(0, 255);
    }
    
    return Color.fromRGBO(red, green, blue, 1);
  }
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'app_theme_settings';
  ThemeSettings? _lastSettings;

  ThemeNotifier(this._prefs) : super(ThemeSettings()) {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    try {
      final themeData = _prefs.getString(_themeKey);
      if (themeData != null) {
        final jsonData = jsonDecode(themeData) as Map<String, dynamic>;
        state = ThemeSettings.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint('Error loading theme settings: $e');
    }
  }

  Future<void> _saveThemeSettings() async {
    try {
      await _prefs.setString(_themeKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Error saving theme settings: $e');
    }
  }

  Future<void> setThemeColor(Color color) async {
    _lastSettings = state;
    state = state.copyWith(primaryColor: color);
    await _saveThemeSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _lastSettings = state;
    state = state.copyWith(themeMode: mode);
    await _saveThemeSettings();
  }

  Future<void> setColorBrightness(double brightness) async {
    assert(brightness >= -1.0 && brightness <= 1.0);
    _lastSettings = state;
    state = state.copyWith(colorBrightness: brightness);
    await _saveThemeSettings();
  }

  Future<void> setColorSaturation(double saturation) async {
    assert(saturation >= 0.0 && saturation <= 2.0);
    _lastSettings = state;
    state = state.copyWith(colorSaturation: saturation);
    await _saveThemeSettings();
  }

  // Undo last change
  Future<void> undoChange() async {
    if (_lastSettings != null) {
      state = _lastSettings!;
      _lastSettings = null;
      await _saveThemeSettings();
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeNotifier(prefs);
});

// Helper provider for current theme 
final currentThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeProvider);
  final mediaQuery = WidgetsBinding.instance.window;
  final platformBrightness = mediaQuery.platformBrightness;
  
  bool isDark = settings.themeMode == ThemeMode.dark || 
                (settings.themeMode == ThemeMode.system && 
                 platformBrightness == Brightness.dark);
                 
  return settings.getThemeData(null, isDark: isDark);
});