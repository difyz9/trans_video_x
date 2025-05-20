

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/core/layout/provider/layout_provider.dart';
import 'package:trans_video_x/core/widget/window_title_bar.dart';
import 'package:auto_route/auto_route.dart';


@RoutePage()
class ContentScreen extends ConsumerWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final gradientColors = ref.watch(gradientColorProvider);


    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors, // 使用用户选择的颜色
            stops: const [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            const WindowTitleBar(title: "Main Screen"), // 使用新的窗口标题栏组件
            const Expanded(
              child: AutoRouter(),
            ),
          ],
        ),
      ),
    );
  }
}
