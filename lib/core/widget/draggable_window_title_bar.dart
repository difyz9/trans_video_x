import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'window_title_bar_v2.dart';

class DraggableWindowTitleBar extends WindowTitleBarV2 implements PreferredSizeWidget {
  final Widget? titleContent;
  final Widget? leading;

  const DraggableWindowTitleBar({
    super.key,
    this.titleContent,
    this.leading,
    super.backgroundColor,
    super.showMinimizeButton = true,
    super.showMaximizeButton = true,
    super.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
    // Use preferredSize.height which is now guaranteed by PreferredSizeWidget implementation
    final barHeight = preferredSize.height;

    return Container(
      height: barHeight,
      color: currentBackgroundColor,
      child: WindowTitleBarBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 28.0,left: 18.0),
          child: Row(
            children: [
              if (leading != null) leading!,
              Expanded(
                child: MoveWindow(
                  child: titleContent != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: DefaultTextStyle(
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ) ??
                                  TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 16,
                                  ),
                              child: titleContent!,
                            ),
                          ),
                        )
                      : Container(), // Empty container if no title
                ),
              ),
              if (showMinimizeButton || showMaximizeButton || showCloseButton)
                WindowButtons(
                  showMinimize: showMinimizeButton,
                  showMaximize: showMaximizeButton,
                  showClose: showCloseButton,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appWindow.titleBarHeight > 0 ? appWindow.titleBarHeight : kToolbarHeight);
}
