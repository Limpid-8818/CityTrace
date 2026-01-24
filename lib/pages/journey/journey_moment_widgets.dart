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

class MomentCard {
  static Widget buildTypedContent(MomentModel moment) {
    switch (moment.type) {
      case "image":
        return _buildImageContent(moment);
      case "audio":
        return _buildAudioContent(moment);
      case "text":
        return _buildTextContent(moment);
      case "location":
        return _buildLocationContent(moment);
      default:
        return const SizedBox();
    }
  }

  static Widget _buildImageContent(MomentModel moment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            moment.media!,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (c, e, s) => Container(
              height: 150,
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        if (moment.mediaDescription != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF009688).withOpacity(0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("✨", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    moment.mediaDescription!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.teal.shade800,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildAudioContent(MomentModel moment) {
    if (moment.media == null || moment.media!.isEmpty) {
      return const Text("音频加载失败", style: TextStyle(color: Colors.grey));
    }

    // 使用播放器组件
    return AudioMomentPlayer(url: moment.media!);
  }

  static Widget _buildTextContent(MomentModel moment) {
    return Text(
      moment.context ?? "",
      style: const TextStyle(
        fontSize: 15,
        height: 1.6,
        color: Colors.black87,
        letterSpacing: 0.2,
      ),
    );
  }

  static Widget _buildLocationContent(MomentModel moment) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on, color: Colors.blue, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moment.location.name ?? "未知地点",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${moment.location.lat}, ${moment.location.lon}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AudioMomentPlayer extends StatefulWidget {
  final String url;
  const AudioMomentPlayer({super.key, required this.url});

  @override
  State<AudioMomentPlayer> createState() => _AudioMomentPlayerState();
}

class _AudioMomentPlayerState extends State<AudioMomentPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // 监听播放状态
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    // 监听总时长
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
          print("Now Duration:$_duration");
        });
      }
    });

    // 监听当前进度
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });

    // 监听错误事件
    _audioPlayer.onLog.listen((msg) {
      if (msg.contains("error")) {
        _handleError();
      }
    });
  }

  void _handleError() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _isPlaying = false;
      });
      Get.snackbar(
        "播放失败",
        "无法加载音频资源",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 释放资源
    super.dispose();
  }

  void _togglePlay() async {
    if (_hasError) {
      // 如果之前报错了，点击时重置状态尝试重新加载
      setState(() => _hasError = false);
      setState(() => _isPlaying = false);
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true); // 开始加载
        // play 方法可能会抛出异常
        await _audioPlayer
            .play(UrlSource(widget.url))
            .timeout(
              const Duration(seconds: 10), // 10秒超时
              onTimeout: () => throw TimeoutException("连接超时"),
            );
        setState(() => _isLoading = false); // 加载完成
      }
    } catch (e) {
      _handleError();
      debugPrint("音频播放出错: $e");
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    // 根据状态决定图标
    Widget playIcon;
    if (_hasError) {
      playIcon = const Icon(Icons.error_outline, color: Colors.red, size: 32);
    } else if (_isLoading) {
      playIcon = const SizedBox(
        width: 32,
        height: 32,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.orange,
          ),
        ),
      );
    } else {
      playIcon = Icon(
        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
        color: Colors.orange,
        size: 32,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _hasError ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(onTap: _togglePlay, child: playIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hasError ? "资源加载失败" : "录音",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _hasError ? Colors.red : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // 动态波形图
                Row(
                  children: List.generate(15, (index) {
                    // 如果正在播放，让波形随机跳动，否则保持静止
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 2),
                      width: 3,
                      height: _isPlaying
                          ? (index % 3 + 2) * (index.isEven ? 2.0 : 4.0)
                          : (index % 3 + 2) * 3.0,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(
                          _isPlaying ? 0.8 : 0.4,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Text(
            _hasError
                ? "--:--"
                : _isPlaying
                ? _formatDuration(_position)
                : (_duration == Duration.zero
                      ? "00:00"
                      : _formatDuration(_duration)),
            style: TextStyle(
              fontSize: 12,
              color: _hasError ? Colors.grey : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
