import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/core/layout/view/layout_screen.dart';
import 'package:trans_video_x/routes/app_route.gr.dart';

// 定义 routerProvider
final routerProvider = Provider<AppRouter>((ref) {
  return AppRouter(ref);
});

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  final Ref ref;

  AppRouter(this.ref);

  List<AutoRoute> get routes => [
    AutoRoute(page: LayoutRoute.page, path: "/", children: [
          CustomFadeRoute(
      page: HomeRoute.page,
      path: HomeRoute.name,
      initial: true,
      guards: [],
    ),
    CustomFadeRoute(page: SettingRoute.page, path: SettingRoute.name),
    CustomFadeRoute(page: VideoRoute.page, path: VideoRoute.name),
    CustomFadeRoute(page: UploadRoute.page, path: UploadRoute.name),
    ]),


  ];
}

class CustomFadeRoute<T> extends CustomRoute<T> {
  CustomFadeRoute({
    required super.page,
    required super.path,
    super.initial,
    super.guards,
  }) : super(
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(opacity: animation, child: child);
         },
       );
}
