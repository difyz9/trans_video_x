import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class WindowTitleBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  
  const WindowTitleBar({
    Key? key,
    required this.title,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On web or non-desktop platforms, return standard AppBar
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return AppBar(
        title: Text(title),
        actions: actions,
      );
    }

    // Custom title bar for desktop platforms
    return Container(
      height: appWindow.titleBarHeight,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Draggable area
          Expanded(
            child: WindowTitleBarBox(
              child: MoveWindow(
                
              ),
            ),
          ),
          // Action buttons
          ...actions,
          // Window control buttons
          WindowButtons(),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    // Colors for buttons
    final buttonColors = WindowButtonColors(
      iconNormal: isDarkTheme ? Colors.white : Colors.black,
      mouseOver: isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!,
      mouseDown: isDarkTheme ? Colors.grey[800]! : Colors.grey[400]!,
      iconMouseOver: isDarkTheme ? Colors.white : Colors.black,
      iconMouseDown: isDarkTheme ? Colors.white : Colors.black,
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: isDarkTheme ? Colors.white : Colors.black,
      mouseOver: Colors.red,
      mouseDown: Colors.red[800]!,
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
    );

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
