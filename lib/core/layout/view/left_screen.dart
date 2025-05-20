import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trans_video_x/core/layout/provider/layout_provider.dart';
import 'package:trans_video_x/core/layout/viewmodel/layout_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';


const sidebarColor = Color(0xFFF6A00C);

final sidebarExpandedProvider = StateProvider<bool>((ref) => false);

class LeftScreen extends ConsumerWidget {
  const LeftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听主题状态
    final themeState = ref.watch(themeNotifierProvider);
    final primaryColor = themeState.primaryColor;
    // 监听侧边栏展开状态
    final isExpanded = ref.watch(sidebarExpandedProvider);
    // 监听渐变色状态
    final gradientColors = ref.watch(gradientColorProvider);
    // 监听当前语言状态，确保语言切换时重建组件
    final locale = context.locale;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isExpanded ? 160 : 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors.isNotEmpty
              ? gradientColors
              : [primaryColor, primaryColor],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.menu_open : Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(sidebarExpandedProvider.notifier).state =
                          !isExpanded;
                    },
                    tooltip: isExpanded
                        ? 'collapse_sidebar'.tr()
                        : 'expand_sidebar'.tr(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  ),
                  const SizedBox(width: 8),
   
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final viewModel = ref.watch(layoutViewModelProvider.notifier);
                final selectedIndex = ref.watch(layoutViewModelProvider);
                final sidebarItems = viewModel.sidebarItems;


                return ListView.builder(
                  itemCount: sidebarItems.length,
                  itemBuilder: (context, index) {
                    final item = sidebarItems[index];
                    final isSelected = selectedIndex == index;
                    return Container(
                      color: isSelected
                          ? Colors.black.withOpacity(0.2)
                          : Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          item.icon,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        title: isExpanded
                            ? Text(
                                item.key.tr(), // 在这里动态翻译
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        dense: true,
                        onTap: () {
                          viewModel.setSelectedIndex(index);
                          context.router.replace(item.route);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
        ],
      ),
    );
  }
}

