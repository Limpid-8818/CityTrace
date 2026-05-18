import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../components/share_card.dart';
import '../../core/theme/app_colors.dart';
import '../../models/journey_model.dart';
import '../../models/moment_model.dart';

/// 分享卡片查看页面
/// 用户可以看到完整的分享卡片预览，并可选择分享或保存
class ShareViewPage extends StatefulWidget {
  final JourneyModel journey;
  final List<MomentModel> moments;
  final String displayDuration;

  const ShareViewPage({
    super.key,
    required this.journey,
    required this.moments,
    required this.displayDuration,
  });

  @override
  State<ShareViewPage> createState() => _ShareViewPageState();
}

class _ShareViewPageState extends State<ShareViewPage> {
  final GlobalKey<ShareCardState> _shareCardKey = GlobalKey<ShareCardState>();

  void _triggerShare() {
    _shareCardKey.currentState?.shareAsImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarker,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "分享旅程",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            tooltip: "保存到相册",
            onPressed: () {
              Get.snackbar("提示", "保存到相册功能开发中");
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 卡片预览区域
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ShareCard(
                    key: _shareCardKey,
                    journey: widget.journey,
                    moments: widget.moments,
                    displayDuration: widget.displayDuration,
                  ),
                ),
              ),
            ),

            // 底部操作按钮
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.primaryOpacity005,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 分享提示
          Text(
            "生成一张精美的旅程卡片，分享给好友",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 16.h),

          // 分享按钮
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: _triggerShare,
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              label: Text(
                "分享给好友",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}