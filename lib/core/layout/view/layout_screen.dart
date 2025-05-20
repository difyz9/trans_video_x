import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/core/layout/view/left_screen.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:trans_video_x/core/layout/view/content_screen.dart';

const borderColor = Color(0xFF805306);


@RoutePage()
class LayoutScreen extends ConsumerWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: WindowBorder(
        color: borderColor,
        width: 0,
        child: const Row(
          children: [
            
            // 左侧导航栏 (现在包含了展开/收起按钮)
           LeftScreen(),
            
            // 主内容区域
            ContentScreen(),
          ],
        ),
      ),
    );
  }
}
