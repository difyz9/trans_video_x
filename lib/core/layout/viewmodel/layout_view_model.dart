
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trans_video_x/core/layout/models/sidebar_item.dart';
import 'package:flutter/material.dart';
import 'package:trans_video_x/routes/app_route.gr.dart';

part 'layout_view_model.g.dart';


@riverpod
class LayoutViewModel extends _$LayoutViewModel{
 @override
  int build() {
    return 0; // 初始化 _selectedIndex
  }


  late final List<SidebarItem> _sidebarItems =  [
    SidebarItem(key: 'home', icon: Icons.home, route: HomeRoute()),
    SidebarItem(key: "video", icon: Icons.video_call, route: VideoRoute()),

    SidebarItem(key: "upload", icon: Icons.upload, route: UploadRoute()),
    SidebarItem(key: "task", icon: Icons.task, route: TaskRoute()),
    SidebarItem(key: "setting", icon: Icons.settings, route: SettingRoute()),
    SidebarItem(key: "upload02", icon: Icons.upload, route: Upload02Route()),

    
  ];

  int get selectedIndex => state;
  List<SidebarItem> get sidebarItems => _sidebarItems;

  void setSelectedIndex(int index) {
    if (index >= 0 && index < _sidebarItems.length && state != index) {
      state = index;
    }
  }
}
