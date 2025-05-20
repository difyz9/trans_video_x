import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String? nickname;
  final String? email;
  final String? avatarUrl;
  final bool isLoggedIn;

  UserProfile({
    this.nickname,
    this.email,
    this.avatarUrl,
    this.isLoggedIn = false,
  });

  UserProfile copyWith({
    String? nickname,
    String? email,
    String? avatarUrl,
    bool? isLoggedIn,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'email': email,
      'avatarUrl': avatarUrl,
      'isLoggedIn': isLoggedIn,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nickname: json['nickname'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      isLoggedIn: json['isLoggedIn'] ?? false,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final SharedPreferences _prefs;
  static const String _userKey = 'user_profile';

  UserProfileNotifier(this._prefs) : super(UserProfile()) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = _prefs.getString(_userKey);
      if (userData != null) {
        final jsonData = Map<String, dynamic>.from(
          Map<String, dynamic>.from(_prefs.get(_userKey) as Map)
        );
        state = UserProfile.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _saveUserProfile() async {
    try {
      await _prefs.setString(_userKey, state.toJson().toString());
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  Future<void> login({
    required String nickname,
    required String email,
    String? avatarUrl,
  }) async {
    state = UserProfile(
      nickname: nickname,
      email: email,
      avatarUrl: avatarUrl ?? 'https://via.placeholder.com/48',
      isLoggedIn: true,
    );
    await _saveUserProfile();
  }

  Future<void> updateProfile({
    String? nickname,
    String? email,
    String? avatarUrl,
  }) async {
    state = state.copyWith(
      nickname: nickname,
      email: email,
      avatarUrl: avatarUrl,
    );
    await _saveUserProfile();
  }

  Future<void> logout() async {
    state = UserProfile();
    await _saveUserProfile();
  }
}

// Providers
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Should be overridden in main.dart');
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return UserProfileNotifier(prefs);
});