import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Color themeColor;
  final String language;
  final bool enableNotifications;
  final bool enableAnimations;
  final bool enableSearchHistory;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.themeColor = Colors.blue,
    this.language = '简体中文',
    this.enableNotifications = true,
    this.enableAnimations = true,
    this.enableSearchHistory = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? themeColor,
    String? language,
    bool? enableNotifications,
    bool? enableAnimations,
    bool? enableSearchHistory,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      themeColor: themeColor ?? this.themeColor,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableSearchHistory: enableSearchHistory ?? this.enableSearchHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'themeColor': themeColor.value,
      'language': language,
      'enableNotifications': enableNotifications,
      'enableAnimations': enableAnimations,
      'enableSearchHistory': enableSearchHistory,
    };
  }

  static SettingsState fromMap(Map<String, dynamic> map) {
    return SettingsState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      themeColor: Color(map['themeColor'] ?? Colors.blue.value),
      language: map['language'] ?? '简体中文',
      enableNotifications: map['enableNotifications'] ?? true,
      enableAnimations: map['enableAnimations'] ?? true,
      enableSearchHistory: map['enableSearchHistory'] ?? true,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;
  
  static const String _settingsKey = 'app_settings';
  static const List<Color> colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  SettingsNotifier(this._prefs) : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final settingsMap = Map<String, dynamic>.from(
          Map<String, dynamic>.from(_prefs.get(_settingsKey) as Map)
        );
        state = SettingsState.fromMap(settingsMap);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _prefs.setString(_settingsKey, state.toMap().toString());
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  Future<void> setThemeColor(Color color) async {
    state = state.copyWith(themeColor: color);
    await _saveSettings();
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }

  Future<void> setEnableNotifications(bool enabled) async {
    state = state.copyWith(enableNotifications: enabled);
    await _saveSettings();
  }

  Future<void> setEnableAnimations(bool enabled) async {
    state = state.copyWith(enableAnimations: enabled);
    await _saveSettings();
  }

  Future<void> setEnableSearchHistory(bool enabled) async {
    state = state.copyWith(enableSearchHistory: enabled);
    await _saveSettings();
  }

  Future<void> resetSettings() async {
    state = SettingsState();
    await _saveSettings();
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    state = SettingsState.fromMap(settings);
    await _saveSettings();
  }

  Map<String, dynamic> exportSettings() {
    return state.toMap();
  }
}

// Providers
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overridden in main.dart');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsNotifier(prefs);
});