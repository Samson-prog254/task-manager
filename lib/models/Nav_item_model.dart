// Navigation item model
import 'package:flutter/cupertino.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}