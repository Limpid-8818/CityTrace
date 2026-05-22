import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 统一骨架屏组件
/// 用于图片加载、内容加载时的占位效果
class AppSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: _ShimmerEffect(
        baseColor: baseColor,
        highlightColor: highlightColor,
      ),
    );
  }
}

/// 骨架屏图片占位（带图标）
class AppSkeletonImage extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final double? iconSize;

  const AppSkeletonImage({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.icon,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: Stack(
        children: [
          const _ShimmerEffect(),
          Center(
            child: Icon(
              icon ?? Icons.image_outlined,
              size: iconSize ?? (width > 100 ? 40 : 24),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

/// 骨架屏卡片占位（模拟完整卡片布局）
class AppSkeletonCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const AppSkeletonCard({
    super.key,
    this.height = 200,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域占位
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const _ShimmerEffect(),
              ),
            ),
            SizedBox(height: 12.h),
            // 标题占位
            Container(
              width: double.infinity,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: const _ShimmerEffect(),
            ),
            SizedBox(height: 8.h),
            // 副标题占位
            Container(
              width: 100.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: const _ShimmerEffect(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 骨架屏列表占位（用于列表加载）
class AppSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double borderRadius;

  const AppSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 200,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: AppSkeletonCard(
          height: itemHeight.h,
          borderRadius: borderRadius.r,
        ),
      ),
    );
  }
}

/// 骨架屏水平滚动列表占位（用于最近行程等横向滚动场景）
class AppSkeletonHorizontalList extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;

  const AppSkeletonHorizontalList({
    super.key,
    this.itemCount = 4,
    this.itemWidth = 140,
    this.itemHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        padding: EdgeInsets.only(left: 20.w),
        itemBuilder: (context, index) => Container(
          width: itemWidth.w,
          margin: EdgeInsets.only(right: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 图片占位
              Container(
                width: itemWidth.w,
                height: itemWidth.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    const _ShimmerEffect(),
                    Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 36.r,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // 标题占位 - 居中
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: itemWidth.w * 0.7,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: const _ShimmerEffect(),
                ),
              ),
              SizedBox(height: 6.h),
              // 日期占位 - 居中
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: itemWidth.w * 0.8,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: const _ShimmerEffect(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 闪烁动画效果
class _ShimmerEffect extends StatefulWidget {
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerEffect({
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? Colors.grey.shade200;
    final highlight = widget.highlightColor ?? Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                base,
                highlight,
                base,
              ],
              stops: [
                _animation.value.clamp(0.0, 1.0) - 0.3,
                _animation.value.clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0) + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}
