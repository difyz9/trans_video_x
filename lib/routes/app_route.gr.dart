// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:trans_video_x/core/layout/view/content_screen.dart' as _i1;
import 'package:trans_video_x/core/layout/view/layout_screen.dart' as _i3;
import 'package:trans_video_x/features/home/home_screen.dart' as _i2;
import 'package:trans_video_x/features/settings/setting_screen.dart' as _i4;
import 'package:trans_video_x/features/video/video_screen.dart' as _i5;

/// generated route for
/// [_i1.ContentScreen]
class ContentRoute extends _i6.PageRouteInfo<void> {
  const ContentRoute({List<_i6.PageRouteInfo>? children})
    : super(ContentRoute.name, initialChildren: children);

  static const String name = 'ContentRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.ContentScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.LayoutScreen]
class LayoutRoute extends _i6.PageRouteInfo<void> {
  const LayoutRoute({List<_i6.PageRouteInfo>? children})
    : super(LayoutRoute.name, initialChildren: children);

  static const String name = 'LayoutRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.LayoutScreen();
    },
  );
}

/// generated route for
/// [_i4.SettingScreen]
class SettingRoute extends _i6.PageRouteInfo<void> {
  const SettingRoute({List<_i6.PageRouteInfo>? children})
    : super(SettingRoute.name, initialChildren: children);

  static const String name = 'SettingRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.SettingScreen();
    },
  );
}

/// generated route for
/// [_i5.VideoScreen]
class VideoRoute extends _i6.PageRouteInfo<void> {
  const VideoRoute({List<_i6.PageRouteInfo>? children})
    : super(VideoRoute.name, initialChildren: children);

  static const String name = 'VideoRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.VideoScreen();
    },
  );
}
