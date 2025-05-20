

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class WindowTitleBarV2 extends StatelessWidget {

      final Color? backgroundColor;
  final bool showMinimizeButton;
  final bool showMaximizeButton;
  final bool showCloseButton;

  const WindowTitleBarV2({
    Key? key,
    this.backgroundColor,
    this.showMinimizeButton = true,
    this.showMaximizeButton = true,
    this.showCloseButton = true,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: WindowTitleBarBox(
        child: Row(
          children: [
            Expanded(child: MoveWindow()),
            if (showMinimizeButton || showMaximizeButton || showCloseButton)
              WindowButtons(
                showMinimize: showMinimizeButton,
                showMaximize: showMaximizeButton,
                showClose: showCloseButton,
              ),
          ],
        ),
      ),
    );
  }
}

// 窗口按钮颜色配置
final buttonColors = WindowButtonColors(
  iconNormal: const Color(0xFF805306),
  mouseOver: const Color(0xFFF6A00C),
  mouseDown: const Color(0xFF805306),
  iconMouseOver: const Color(0xFF805306),
  iconMouseDown: const Color(0xFFFFD500),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: const Color(0xFF805306),
  iconMouseOver: Colors.white,
);

class WindowButtons extends StatelessWidget {
  final bool showMinimize;
  final bool showMaximize;
  final bool showClose;
  
  const WindowButtons({
    Key? key,
    this.showMinimize = true,
    this.showMaximize = true,
    this.showClose = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showMinimize) MinimizeWindowButton(colors: buttonColors),
        if (showMaximize) MaximizeWindowButton(colors: buttonColors),
        if (showClose) CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
