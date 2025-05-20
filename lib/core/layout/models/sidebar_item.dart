import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';


class SidebarItem {
  final String key; // 改为存储翻译键，而不是翻译后的值
  final IconData icon;
  final PageRouteInfo route;

  const SidebarItem({
    required this.key,
    required this.icon,
    required this.route,
  });
}