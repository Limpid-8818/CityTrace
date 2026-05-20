import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 统一的弹出菜单项数据模型
class PopupMenuItemData<T> {
  final T value;
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? titleColor;
  final bool isDestructive;

  const PopupMenuItemData({
    required this.value,
    required this.title,
    required this.icon,
    this.iconColor,
    this.titleColor,
    this.isDestructive = false,
  });
}

/// 统一的弹出菜单组件
/// 封装 PopupMenuButton，统一管理菜单项的样式和行为
class AppPopupMenu<T> extends StatelessWidget {
  /// 菜单项列表
  final List<PopupMenuItemData<T>> items;

  /// 菜单选中回调
  final void Function(T value) onSelected;

  /// 菜单图标（默认为更多水平图标）
  final Widget? icon;

  /// 菜单图标颜色
  final Color? iconColor;

  /// 菜单偏移量
  final Offset? offset;

  /// 菜单圆角
  final double borderRadius;

  /// 菜单项高度
  final double itemHeight;

  /// 是否启用菜单
  final bool enabled;

  const AppPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.icon,
    this.iconColor,
    this.offset,
    this.borderRadius = 16,
    this.itemHeight = 48,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    return PopupMenuButton<T>(
      icon: icon ??
          Icon(
            Icons.more_horiz,
            color: iconColor ?? Colors.black54,
          ),
      offset: offset ?? Offset(0, 50.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<T>(
          value: item.value,
          height: itemHeight.h,
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20.r,
                color: item.iconColor ??
                    (item.isDestructive ? Colors.red : AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: item.titleColor ??
                      (item.isDestructive ? Colors.red : Colors.black87),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 带分隔线的弹出菜单组件
/// 适用于需要将菜单项分组的场景
class AppPopupMenuGroup<T> extends StatelessWidget {
  /// 菜单分组列表
  final List<PopupMenuGroupData<T>> groups;

  /// 菜单选中回调
  final void Function(T value) onSelected;

  /// 菜单图标
  final Widget? icon;

  /// 菜单图标颜色
  final Color? iconColor;

  /// 菜单偏移量
  final Offset? offset;

  /// 菜单圆角
  final double borderRadius;

  /// 是否启用菜单
  final bool enabled;

  const AppPopupMenuGroup({
    super.key,
    required this.groups,
    required this.onSelected,
    this.icon,
    this.iconColor,
    this.offset,
    this.borderRadius = 16,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    return PopupMenuButton<T>(
      icon: icon ??
          Icon(
            Icons.more_horiz,
            color: iconColor ?? Colors.black54,
          ),
      offset: offset ?? Offset(0, 50.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      onSelected: onSelected,
      itemBuilder: (context) {
        final List<PopupMenuEntry<T>> entries = [];
        for (int i = 0; i < groups.length; i++) {
          final group = groups[i];
          for (final item in group.items) {
            entries.add(
              PopupMenuItem<T>(
                value: item.value,
                height: group.itemHeight.h,
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20.r,
                      color: item.iconColor ??
                          (item.isDestructive ? Colors.red : AppColors.primary),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: item.titleColor ??
                            (item.isDestructive ? Colors.red : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // 在组之间添加分隔线（最后一个组之后不加）
          if (i < groups.length - 1) {
            entries.add(const PopupMenuDivider());
          }
        }
        return entries;
      },
    );
  }
}

/// 菜单分组数据模型
class PopupMenuGroupData<T> {
  final List<PopupMenuItemData<T>> items;
  final double itemHeight;

  const PopupMenuGroupData({
    required this.items,
    this.itemHeight = 48,
  });
}
