// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/material.dart' as _i14;
import 'package:trans_video_x/core/layout/view/content_screen.dart' as _i1;
import 'package:trans_video_x/core/layout/view/layout_screen.dart' as _i4;
import 'package:trans_video_x/features/home/home_screen.dart' as _i3;
import 'package:trans_video_x/features/home/upload02_screen.dart' as _i9;
import 'package:trans_video_x/features/home/upload_screen.dart' as _i10;
import 'package:trans_video_x/features/login/login_page.dart' as _i5;
import 'package:trans_video_x/features/login/register_page.dart' as _i6;
import 'package:trans_video_x/features/settings/setting_screen.dart' as _i7;
import 'package:trans_video_x/features/task/view/task_screen.dart' as _i8;
import 'package:trans_video_x/features/video/video_screen.dart' as _i11;
import 'package:trans_video_x/features/video/view/download_screen.dart' as _i2;
import 'package:trans_video_x/features/video/view/youtube_page.dart' as _i12;

/// generated route for
/// [_i1.ContentScreen]
class ContentRoute extends _i13.PageRouteInfo<void> {
  const ContentRoute({List<_i13.PageRouteInfo>? children})
    : super(ContentRoute.name, initialChildren: children);

  static const String name = 'ContentRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i1.ContentScreen();
    },
  );
}

/// generated route for
/// [_i2.DownloadScreen]
class DownloadRoute extends _i13.PageRouteInfo<void> {
  const DownloadRoute({List<_i13.PageRouteInfo>? children})
    : super(DownloadRoute.name, initialChildren: children);

  static const String name = 'DownloadRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i2.DownloadScreen();
    },
  );
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i13.PageRouteInfo<void> {
  const HomeRoute({List<_i13.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomeScreen();
    },
  );
}

/// generated route for
/// [_i4.LayoutScreen]
class LayoutRoute extends _i13.PageRouteInfo<void> {
  const LayoutRoute({List<_i13.PageRouteInfo>? children})
    : super(LayoutRoute.name, initialChildren: children);

  static const String name = 'LayoutRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i4.LayoutScreen();
    },
  );
}

/// generated route for
/// [_i5.LoginScreen]
class LoginRoute extends _i13.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    dynamic Function(bool)? onLoginResult,
    _i14.Key? key,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(onLoginResult: onLoginResult, key: key),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i5.LoginScreen(onLoginResult: args.onLoginResult, key: args.key);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.onLoginResult, this.key});

  final dynamic Function(bool)? onLoginResult;

  final _i14.Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{onLoginResult: $onLoginResult, key: $key}';
  }
}

/// generated route for
/// [_i6.RegisterScreen]
class RegisterRoute extends _i13.PageRouteInfo<void> {
  const RegisterRoute({List<_i13.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i6.RegisterScreen();
    },
  );
}

/// generated route for
/// [_i7.SettingScreen]
class SettingRoute extends _i13.PageRouteInfo<void> {
  const SettingRoute({List<_i13.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i7.SettingScreen();
    },
  );
}

/// generated route for
/// [_i8.TaskScreen]
class TaskRoute extends _i13.PageRouteInfo<void> {
  const TaskRoute({List<_i13.PageRouteInfo>? children})
    : super(TaskRoute.name, initialChildren: children);

  static const String name = 'TaskRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i8.TaskScreen();
    },
  );
}

/// generated route for
/// [_i9.Upload02Screen]
class Upload02Route extends _i13.PageRouteInfo<void> {
  const Upload02Route({List<_i13.PageRouteInfo>? children})
    : super(Upload02Route.name, initialChildren: children);

  static const String name = 'Upload02Route';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i9.Upload02Screen();
    },
  );
}

/// generated route for
/// [_i10.UploadScreen]
class UploadRoute extends _i13.PageRouteInfo<void> {
  const UploadRoute({List<_i13.PageRouteInfo>? children})
    : super(UploadRoute.name, initialChildren: children);

  static const String name = 'UploadRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i10.UploadScreen();
    },
  );
}

/// generated route for
/// [_i11.VideoScreen]
class VideoRoute extends _i13.PageRouteInfo<void> {
  const VideoRoute({List<_i13.PageRouteInfo>? children})
    : super(VideoRoute.name, initialChildren: children);

  static const String name = 'VideoRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i11.VideoScreen();
    },
  );
}

/// generated route for
/// [_i12.YoutubePage]
class YoutubeRoute extends _i13.PageRouteInfo<YoutubeRouteArgs> {
  YoutubeRoute({
    _i14.Key? key,
    required _i14.TabController tabController,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         YoutubeRoute.name,
         args: YoutubeRouteArgs(key: key, tabController: tabController),
         initialChildren: children,
       );

  static const String name = 'YoutubeRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<YoutubeRouteArgs>();
      return _i12.YoutubePage(key: args.key, tabController: args.tabController);
    },
  );
}

class YoutubeRouteArgs {
  const YoutubeRouteArgs({this.key, required this.tabController});

  final _i14.Key? key;

  final _i14.TabController tabController;

  @override
  String toString() {
    return 'YoutubeRouteArgs{key: $key, tabController: $tabController}';
  }
}
