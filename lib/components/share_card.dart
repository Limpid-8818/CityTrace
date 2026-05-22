import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import 'package:latlong2/latlong.dart';

import '../core/theme/app_colors.dart';
import '../models/journey_model.dart';
import '../models/moment_model.dart';
import '../mock/mock_data.dart';
import 'app_skeleton.dart';
import 'static_route_thumbnail.dart';
import 'ui/info_pill.dart';

/// 分享卡片组件
/// 可将行程详情渲染为一张精美的图片，支持导出和分享
class ShareCard extends StatefulWidget {
  final JourneyModel journey;
  final List<MomentModel> moments;
  final String displayDuration;

  const ShareCard({
    super.key,
    required this.journey,
    required this.moments,
    required this.displayDuration,
  });

  @override
  ShareCardState createState() => ShareCardState();
}

class ShareCardState extends State<ShareCard> {
  final GlobalKey _cardKey = GlobalKey();

  /// 将卡片导出为图片并分享
  Future<void> shareAsImage() async {
    try {
      // 等待一帧确保渲染完成
      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      // 保存到临时目录
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/share_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // 使用 share_plus 分享
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: '我在 CityTrace 的旅程：${widget.journey.title}',
        ),
      );
    } catch (e) {
      debugPrint('分享卡片导出失败: $e');
      Get.snackbar("导出失败", "图片生成异常，请稍后重试");
    }
  }

  /// 将卡片导出为 Uint8List（供外部使用）
  Future<Uint8List?> exportAsPng() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('导出图片失败: $e');
      return null;
    }
  }

  /// 将卡片保存到手机相册
  Future<void> saveToGallery() async {
    try {
      // 先请求权限
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          Get.snackbar("保存失败", "请在设置中授予相册访问权限");
          return;
        }
      }

      final bytes = await exportAsPng();
      if (bytes == null) {
        Get.snackbar("保存失败", "图片生成异常，请稍后重试");
        return;
      }

      await Gal.putImageBytes(
        bytes,
        album: 'CityTrace',
        name: 'citytrace_share_${DateTime.now().millisecondsSinceEpoch}',
      );

      Get.snackbar("保存成功", "已保存到手机相册");
    } on GalException catch (e) {
      debugPrint('保存到相册失败(GalException): $e');
      Get.snackbar("保存失败", "请检查相册权限后重试");
    } catch (e) {
      debugPrint('保存到相册失败: $e');
      Get.snackbar("保存失败", "请检查相册权限后重试");
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _cardKey,
      child: _CardContent(
        journey: widget.journey,
        moments: widget.moments,
        displayDuration: widget.displayDuration,
      ),
    );
  }
}

/// 卡片内部内容
class _CardContent extends StatelessWidget {
  final JourneyModel journey;
  final List<MomentModel> moments;
  final String displayDuration;

  const _CardContent({
    required this.journey,
    required this.moments,
    required this.displayDuration,
  });

  @override
  Widget build(BuildContext context) {
    // 卡片宽度固定，高度自适应内容
    final cardWidth = 420.w;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        // 不设置 color，确保导出图片时圆角外为透明
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
          children: [
            // === 顶部：封面区域 ===
            _buildCoverSection(),

            // === 中部：内容信息 ===
            _buildInfoSection(),

            // === 底部：品牌水印 ===
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// 封面区域
  Widget _buildCoverSection() {
    return SizedBox(
      height: 200.w,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            journey.cover,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => AppSkeletonImage(
              width: double.infinity,
              height: 200.w,
              borderRadius: 24,
              icon: Icons.image_not_supported_outlined,
              iconSize: 40,
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return AppSkeletonImage(
                width: double.infinity,
                height: 200.w,
                borderRadius: 24,
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 16.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white70, size: 12.r),
                    SizedBox(width: 6.w),
                    Text(
                      journey.startTime.split('T')[0],
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 信息区域（统计 + 瞬间列表）
  Widget _buildInfoSection() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 统计行
          Row(
            children: [
              _buildStatChip(Icons.timer_outlined, displayDuration, "时长"),
              SizedBox(width: 24.w),
              _buildStatChip(
                Icons.camera_alt_outlined,
                "${moments.length}",
                "瞬间",
              ),
              const Spacer(),
              if (moments.isNotEmpty && moments.first.location.name != null)
                InfoPill(
                  icon: Icons.location_on,
                  text: moments.first.location.name!.split("·").last.trim(),
                  backgroundColor: AppColors.primaryOpacity010,
                  iconColor: AppColors.primary,
                  textColor: AppColors.primary,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // 描述文字
          if (journey.description != null && journey.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                journey.description!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // 轨迹缩略图（静态底图 + CustomPainter 绘制路径）
          SizedBox(height: 8.h),
          _buildMockRouteThumbnail(),
          SizedBox(height: 8.h),

          // 瞬间列表（自适应高度，每个瞬间包含媒体+文字说明）
          if (moments.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              "精彩瞬间",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            _buildMomentsList(),
          ],
        ],
      ),
    );
  }

  /// 构建Mock轨迹缩略图
  Widget _buildMockRouteThumbnail() {
    // 使用 mock_data.dart 中的统一模拟轨迹点数据
    final mockPoints = MockData.mockRoutePoints
        .map((p) => LatLng(p['lat']!, p['lng']!))
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: StaticRouteThumbnail(
        points: mockPoints,
        height: 140.w,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.r, color: AppColors.primary),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
      ],
    );
  }

  /// 瞬间列表（每个瞬间一行，包含图标/缩略图+文字说明，自适应不截断）
  Widget _buildMomentsList() {
    final previewMoments = moments.take(4).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: previewMoments.map((moment) => _buildMomentRow(moment)).toList(),
    );
  }

  Widget _buildMomentRow(MomentModel moment) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：类型图标或缩略图
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity005,
              borderRadius: BorderRadius.circular(10.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildMomentThumbnail(moment),
          ),
          SizedBox(width: 12.w),

          // 右侧：标题 + 描述/内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                if (moment.title != null && moment.title!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Text(
                      moment.title!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                // 内容/描述
                _buildMomentText(moment),
                // 时间
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    moment.time.split('T').last.substring(0, 5),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 瞬间缩略图（根据类型显示不同图标或图片缩略图）
  Widget _buildMomentThumbnail(MomentModel moment) {
    switch (moment.type) {
      case "image":
        if (moment.media != null && moment.media!.isNotEmpty) {
          return Image.network(
            moment.media!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (c, e, s) => Icon(Icons.image_outlined, size: 20.r, color: AppColors.primary),
          );
        }
        return Icon(Icons.image_outlined, size: 20.r, color: AppColors.primary);
      case "audio":
        return Icon(Icons.mic, size: 20.r, color: Colors.orange);
      case "text":
        return Icon(Icons.format_quote, size: 20.r, color: AppColors.primary);
      case "location":
        return Icon(Icons.location_on, size: 20.r, color: Colors.blue);
      default:
        return Icon(Icons.notes, size: 20.r, color: Colors.grey);
    }
  }

  /// 瞬间文字描述（不同类型展示不同内容）
  Widget _buildMomentText(MomentModel moment) {
    String text;
    switch (moment.type) {
      case "image":
        text = moment.mediaDescription ?? moment.context ?? "拍摄的照片";
        break;
      case "audio":
        text = moment.mediaDescription ?? moment.context ?? "录音感悟";
        break;
      case "text":
        text = moment.context ?? "心情随笔";
        break;
      case "location":
        text = moment.location.name ?? "打卡记录";
        break;
      default:
        text = "瞬间记录";
    }
    return Text(
      text,
      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.3),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 底部 Logo
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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