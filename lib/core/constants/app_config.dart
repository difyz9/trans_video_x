import 'dart:async'; // Add this import
import 'dart:ui' show Brightness;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:schedulers/schedulers.dart';


class AppConfig {
  AppConfig._();

  static final AppConfig _instance = AppConfig._();

  static AppConfig get instance => _instance;

  late SharedPreferences _prefs;

  bool mtime = false;
  String destino = '';
  bool h26x = false;
  bool temDeps = false;
  ValueNotifier<bool> modoEscuro = ValueNotifier(false);

  // Commenting out the old timer and related method as they are replaced by the new system
  // Timer? _periodicTimer;
  
  Future<void> downloadUrl(String url) async {
    print("Downloading URL: $url");
  }
  

  Future<void> setUpSchedulers() async {
    // Cancel the old timer if it exists (from previous implementation)
    // _periodicTimer?.cancel();

    final scheduler = RateScheduler(3, Duration(seconds: 1)); // 3 per second

    scheduler.run(()=> downloadUrl("https://example.com/file.mp4"));

  }



  Future<void> initialize() async {
    setUpSchedulers();
    _prefs = await SharedPreferences.getInstance();

    var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;

    mtime = _prefs.getBool("mtime") ?? false;
    destino = _prefs.getString("destino") ?? '';
    h26x = _prefs.getBool("h26x") ?? false;
    temDeps = _prefs.getBool("temDeps") ?? false;

    modoEscuro.value = _prefs.getBool("modoEscuro") ?? brightness == Brightness.dark;

    if (destino.isEmpty) {
      final directory = await getDownloadsDirectory();
      destino = directory?.path ?? './';
    }
  }

  Future<void> setMtime(bool value) async {
    mtime = value;
    _prefs.setBool("mtime", value);
  }

  Future<void> setDestino(String value) async {
    destino = value;
    _prefs.setString("destino", value);
  }

  Future<void> setH26x(bool value) async {
    h26x = value;
    _prefs.setBool("h26x", value);
  }

  Future<void> setTemDeps(bool value) async {
    temDeps = value;
    _prefs.setBool("temDeps", value);
  }

  Future<void> setModoEscuro(bool value) async {
    modoEscuro.value = value;
    _prefs.setBool("modoEscuro", value);
  }
}
