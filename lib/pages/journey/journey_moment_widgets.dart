part of 'journey_detail_page.dart';

class MomentBottomSheet {
  /// 统一的弹出方法入口
  static void _show({
    required String title,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统一的标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 业务具体的内容
            child,
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: isScrollControlled,
    );
  }

  /// 动作按钮
  static Widget _buildActionButton(
    String text,
    VoidCallback? onPressed, {
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? const Color(0xFF009688)
              : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static void showTextEditor(JourneyDetailController controller) {
    final textController = TextEditingController();
    _show(
      title: "记录此刻感悟",
      child: Column(
        children: [
          TextField(
            controller: textController,
            maxLines: 5,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "写点什么吧...",
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton("保存瞬间", () {
            controller.onUploadText(textController.text);
            Get.back();
          }),
        ],
      ),
    );
  }

  static void showImagePicker(JourneyDetailController controller) {
    // 记录当前选中的图片来源
    final Rx<ImageSource?> selectedSource = Rx<ImageSource?>(null);

    _show(
      title: "记录这一刻的光影",
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                // 现场拍照
                Expanded(
                  child: _buildSelectableCard(
                    icon: Icons.camera_alt_rounded,
                    label: "现场拍照",
                    isSelected: selectedSource.value == ImageSource.camera,
                    onTap: () => selectedSource.value = ImageSource.camera,
                  ),
                ),
                const SizedBox(width: 16),
                // 相册导入
                Expanded(
                  child: _buildSelectableCard(
                    icon: Icons.photo_library_rounded,
                    label: "从相册选",
                    isSelected: selectedSource.value == ImageSource.gallery,
                    onTap: () => selectedSource.value = ImageSource.gallery,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 动态亮起的动作按钮
          Obx(
            () => _buildActionButton(
              "进入记录",
              selectedSource.value == null
                  ? null // 为 null 时按钮会自动禁用样式
                  : () {
                      Get.back(); // 先关选择框
                      controller.onUploadImage(selectedSource.value!); // 执行上传逻辑
                    },
              isEnabled: selectedSource.value != null,
            ),
          ),
        ],
      ),
    );
  }

  /// 带选中效果的可点击卡片
  static Widget _buildSelectableCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF009688).withOpacity(0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF009688) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? const Color(0xFF009688) : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF009688) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showAudioRecorder(JourneyDetailController controller) {
    final mediaUtil = controller.mediaUtil;

    // 内部响应式变量
    final RxBool isRecording = false.obs;
    final RxBool isFinished = false.obs;

    String? audioPath;

    Get.bottomSheet(
      // 使用 PopScope 拦截返回
      Obx(
        () => PopScope(
          canPop: !isRecording.value, // 录制中禁止手势返回
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRecording.value ? "正在记录您的感悟" : "记录现在的声音",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (!isRecording.value) {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isRecording.value
                      ? "AI 正在倾听..."
                      : (isFinished.value ? "录制完成，点击识别" : "准备好了吗？"),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 48),

                // 合并控制与动态视效的按钮
                GestureDetector(
                  onTap: () async {
                    if (!isRecording.value) {
                      bool hasPermission =
                          await PermissionUtil.requestMicrophone();
                      if (!hasPermission) return;

                      await mediaUtil.startRecording();
                      isRecording.value = true;
                      isFinished.value = false;
                    } else {
                      audioPath = await mediaUtil.stopRecording();
                      isRecording.value = false;
                      isFinished.value = true;
                    }
                  },
                  child: _buildMicAnimation(mediaUtil, isRecording.value),
                ),

                const SizedBox(height: 48),

                // 提交按钮
                _buildActionButton(
                  isFinished.value ? "开始 AI 识别" : "等待录音",
                  isFinished.value
                      ? () {
                          Get.back();
                          if (audioPath != null) {
                            controller.onUploadAudio(audioPath!);
                          }
                        }
                      : null,
                  isEnabled: isFinished.value,
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: false, // 确保不会在录音中意外退出
    );
  }

  /// 辅助组件：构建麦克风波纹动画
  static Widget _buildMicAnimation(MediaUtil mediaUtil, bool active) {
    return StreamBuilder(
      // 只有在 active 时才监听流
      stream: active ? mediaUtil.getAmplitudeStream() : null,
      builder: (context, snapshot) {
        // 获取当前分贝值
        double amp = (snapshot.data?.current ?? -60.0).clamp(-60.0, 0.0);

        // 将 -60~0 映射到 1.0~1.6 的缩放比例
        double pulseScale = 1.0 + (active ? (amp + 60) / 100 : 0.0);

        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 外层动态波纹
              AnimatedScale(
                scale: pulseScale,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutCubic, // 使用流畅的缓动曲线
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: (active ? Colors.red : const Color(0xFF009688))
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 中间核心按钮
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: active ? Colors.red.shade400 : const Color(0xFF009688),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (active ? Colors.red : const Color(0xFF009688))
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  active ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showLocationMarker(JourneyDetailController controller) {
    // 弹出前先触发数据准备
    controller.prepareLocationMark();

    _show(
      title: "位置打卡",
      child: Column(
        children: [
          // 静态地图预览区
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Obx(() {
                if (!controller.isMapReadyInSheet.value ||
                    controller.currentPos == null) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                // 使用 IgnorePointer 禁用所有地图交互
                return IgnorePointer(
                  child: MapView(
                    center: controller.currentPos,
                    points: const [],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // 语义化地址显示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF009688),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.currentAddress.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 确认按钮
          _buildActionButton("确认打卡", () {
            Get.back();
            controller.onUploadLocationMark();
          }),
        ],
      ),
    );
  }
}
