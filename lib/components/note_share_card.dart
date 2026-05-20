import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/app_colors.dart';

/// 游记分享卡片
/// 将 AI 生成的游记（标题、正文、标签）渲染为精美的卡片图片，支持导出和分享
class NoteShareCard extends StatelessWidget {
  final String title;
  final String body;
  final List<String> hashtags;

  /// 可选的行程标题（显示在底部品牌区）
  final String? journeyTitle;

  const NoteShareCard({
    super.key,
    required this.title,
    required this.body,
    this.hashtags = const [],
    this.journeyTitle,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = 420.w;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === 顶部装饰 ===
            _buildHeaderDecoration(),

            // === 标题 ===
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // === 分隔线 ===
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                height: 3.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // === 正文 ===
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                body,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  height: 1.8,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            if (hashtags.isNotEmpty) ...[
              SizedBox(height: 24.h),
              // === 标签（复用 InfoPill 风格） ===
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: hashtags
                      .map(
                        (t) => _buildTagPill(t),
                      )
                      .toList(),
                ),
              ),
            ],

            SizedBox(height: 20.h),

            // === 底部品牌区 ===
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// 标签胶囊（与行程分享卡片的 InfoPill 样式一致）
  Widget _buildTagPill(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tag,
            size: 14.r,
            color: AppColors.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            "#$tag",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部渐变装饰条
  Widget _buildHeaderDecoration() {
    return Container(
      height: 8.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  /// 底部品牌水印
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h),
      child: Row(
        children: [
          // 左侧：仅保留文字 "AI 寻迹成书"
          Text(
            "AI 寻迹成书",
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade400,
            ),
          ),
          const Spacer(),
          // 右侧：CityTrace 品牌 Logo（图片）
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              'assets/images/citytrace_app_icon.jpg',
              width: 32.w,
              height: 32.w,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Icon(
                Icons.explore,
                size: 28.r,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
