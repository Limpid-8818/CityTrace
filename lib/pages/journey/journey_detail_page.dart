import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/map_view.dart';
import '../../core/utils/media_util.dart';
import '../../core/utils/permission_util.dart';
import '../../models/moment_model.dart';
import 'journey_detail_controller.dart';

part 'journey_moment_widgets.dart';

class JourneyDetailPage extends StatelessWidget {
  const JourneyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JourneyDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(), // Header
            SliverToBoxAdapter(child: _buildSummaryCard()), // 概览卡片
            _buildTimelineList(), // 时间轴
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      }),
      floatingActionButton: _buildSpeedDialFab(context), // 快速操作菜单悬浮按钮
    );
  }

  Widget _buildAppBar() {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFF009688),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(controller.journey.value?.title ?? "行程详情"),
        background: Image.network(
          controller.journey.value?.cover ?? "",
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: const Color(0xFF80CBC4)),
        ),
      ),
      actions: [
        if (controller.isEnded) // 当行程结束则显示生成入口
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => controller.goToNotePage(),
          ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // 浅灰色背景，区分开来
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // 路径缩略图
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map_outlined, color: Color(0xFF009688)),
          ),
          const SizedBox(width: 16),
          // 统计数据
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("2.5h", "时长"),
                _buildStatItem("4.2km", "里程"),
                _buildStatItem("12", "瞬间"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTimelineList() {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildTimelineItem(
          controller.moments[index],
          index == controller.moments.length - 1,
        ),
        childCount: controller.moments.length,
      ),
    );
  }

  Widget _buildTimelineItem(MomentModel moment, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        // 让 Row 的高度由内容最高的子组件决定
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 让轴线拉满整个高度，保证无缝连接
          children: [
            // 左侧：轴线和节点
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF009688),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconByType(moment.type),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: Colors.grey.shade200),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 右侧：内容卡片
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32), // 瞬间之间的间距
                child: _buildMomentContentCard(moment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconByType(String type) {
    IconData icon = Icons.notes;
    switch (type) {
      case "image":
        icon = Icons.camera_alt;
        break;
      case "audio":
        icon = Icons.mic;
        break;
      case "text":
        icon = Icons.edit;
        break;
      case "location":
        icon = Icons.location_on;
        break;
    }
    return icon;
  }

  Widget _buildMomentContentCard(MomentModel moment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 高度由内容撑开
        children: [
          if (moment.media != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(moment.media!, fit: BoxFit.fitWidth),
              ),
            ),
          Text(
            moment.title ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (moment.context != null)
            Text(
              moment.context!,
              style: const TextStyle(color: Colors.black87, height: 1.5),
            ),
          const SizedBox(height: 12),
          // AI 描述
          if (moment.mediaDescription != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "✨ AI: ${moment.mediaDescription}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.teal.shade800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            moment.time,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialFab(BuildContext context) {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    return SpeedDial(
      heroTag: "journey_fab",
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: const Color(0xFF009688),
      foregroundColor: Colors.white,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.stop),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          label: '结束行程',
          onTap: () => _showEndJourneyConfirm(),
        ),
        SpeedDialChild(
          child: const Icon(Icons.mic),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          label: '录音感悟',
          onTap: () => MomentBottomSheet.showAudioRecorder(controller),
        ),
        SpeedDialChild(
          child: const Icon(Icons.camera_alt),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          label: '拍照记录',
          onTap: () => MomentBottomSheet.showImagePicker(controller),
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          label: '手写日志',
          onTap: () => MomentBottomSheet.showTextEditor(controller),
        ),
        SpeedDialChild(
          child: const Icon(Icons.location_on),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          label: '添加标记',
          onTap: () => MomentBottomSheet.showLocationMarker(controller),
        ),
      ],
    );
  }

  void _showEndJourneyConfirm() {
    Get.defaultDialog(
      title: "提示",
      middleText: "确定要结束本次城市寻迹吗？",
      textConfirm: "确定",
      textCancel: "取消",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF009688),
      onConfirm: () {
        Get.back(); // 关弹窗
      },
    );
  }
}
