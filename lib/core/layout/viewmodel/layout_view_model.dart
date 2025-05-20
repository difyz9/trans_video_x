
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trans_video_x/core/layout/models/sidebar_item.dart';

part 'layout_view_model.g.dart';


@riverpod
class LayoutViewModel extends _$LayoutViewModel{
 @override
  int build() {
    return 0; // 初始化 _selectedIndex
  }


  late final List<SidebarItem> _sidebarItems =  [

  ];

  int get selectedIndex => state;
  List<SidebarItem> get sidebarItems => _sidebarItems;

  void setSelectedIndex(int index) {
    if (index >= 0 && index < _sidebarItems.length && state != index) {
      state = index;
    }
  }
}
