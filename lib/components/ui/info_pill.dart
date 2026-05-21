import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 统一的信息胶囊组件
/// 用于展示标签、环境信息等短文本+图标的组合
class InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const InfoPill({
    super.key,
    required this.icon,
    required this.text,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 控制胶囊内部的留白 (上下小，左右大)
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.pageBackground,
        borderRadius: BorderRadius.circular(20), // 满圆角，形成胶囊形状
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // 非常柔和的阴影，提升精致感
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // 关键：让 Row 的宽度紧贴内容，而不是撑满屏幕
        children: [
          Icon(
            icon,
            size: 14, // 图标尺寸要小，显得精致
            color: AppColors.primary,
          ),
          const SizedBox(width: 6), // 图标与文字的间距
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.w500,
              color: textColor ?? AppColors.textGrey,
              height: 1.2, // 调整行高让文字垂直居中更好看
            ),
          ),
        ],
      ),
    );
  }
}
