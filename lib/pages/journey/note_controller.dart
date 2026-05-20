import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/ai_service.dart';
import '../../services/journey_management/journey_service.dart';
import '../../models/journey_model.dart';

class NoteController extends GetxController {
  final AIService _aiService = AIService();
  final JourneyService _journeyService = JourneyService();

  // 接收参数
  late String journeyId;

  // --- 响应式变量 ---
  final RxString selectedStyle = "moments".obs; // 默认：朋友圈风格
  final RxString customPrompt = "".obs;
  final RxString generatedTitle = "".obs;
  final RxString generatedBody = "".obs;
  final RxList<String> hashtags = <String>[].obs;
  final RxBool isGenerating = false.obs;
  final RxBool isEditing = false.obs; // 是否处于编辑模式
  final RxInt currentTabIndex = 0.obs; // 0=游记内容, 1=游记卡片

  // 行程信息
  final Rx<JourneyModel?> journey = Rx<JourneyModel?>(null);

  // 描述文本（从生成结果提取前1-2句作为描述，或用户手动编辑）
  final RxString description = "".obs;

  // 用于流式打字机效果 -- 界面上实际绑定的内容
  final RxString displayedTitle = "".obs;
  final RxString displayedBody = "".obs;

  // 用于编辑的 TextEditingController
  late TextEditingController titleEditController;
  late TextEditingController bodyEditController;
  late TextEditingController descriptionEditController;

  // 内部流式控制
  Timer? _typeTimer;

  // 游记分享卡片导出 Key（用于导出游记本身为图片）
  final GlobalKey noteShareCardKey = GlobalKey();

  // 预设风格选项 (对应 API 文档)
  final List<Map<String, String>> styleOptions = [
    {"id": "moments", "name": "文艺朋友圈", "desc": "优美、抒情，充满意境"},
    {"id": "command", "name": "小📕种草", "desc": "活泼、推荐，自带emoji"},
    {"id": "diary", "name": "个人随笔", "desc": "简洁、客观，记录真实"},
    {"id": "custom", "name": "自定义风格", "desc": "输入你想要的语调"},
  ];

  @override
  void onInit() {
    super.onInit();
    journeyId = Get.arguments ?? "";
    titleEditController = TextEditingController();
    bodyEditController = TextEditingController();
    descriptionEditController = TextEditingController();
    _loadJourney();
  }

  @override
  void onClose() {
    _typeTimer?.cancel();
    titleEditController.dispose();
    bodyEditController.dispose();
    descriptionEditController.dispose();
    super.onClose();
  }

  Future<void> _loadJourney() async {
    final journeyData = await _journeyService.getJourneyDetail(journeyId);
    if (journeyData != null) {
      journey.value = journeyData;
      if (journeyData.description != null && journeyData.description!.isNotEmpty) {
        description.value = journeyData.description!;
      }
    }
  }

  /// 执行生成逻辑
  Future<void> startGenerating() async {
    if (journeyId.isEmpty) return;

    if (selectedStyle.value == "custom" && customPrompt.value.trim().isEmpty) {
      Get.snackbar("提示", "请输入您想要的风格描述");
      return;
    }

    isGenerating.value = true;
    // 重置显示内容
    displayedTitle.value = "";
    displayedBody.value = "";
    hashtags.clear();

    final result = await _aiService.generateNote(
      journeyId: journeyId,
      style: selectedStyle.value,
      prompt: selectedStyle.value == "custom" ? customPrompt.value : null,
    );

    if (result != null) {
      generatedTitle.value = result['title'] ?? "未命名旅程";
      generatedBody.value = result['body'] ?? "";
      if (result['tags'] != null) {
        hashtags.value = List<String>.from(result['tags']);
      }
      // 自动提取前1-2句作为描述
      _autoExtractDescription();
      // 开始打字机效果
      _startTypingEffect();
    } else {
      // API 失败，恢复非生成状态
      isGenerating.value = false;
    }
  }

  /// 从生成正文中提取前1-2句作为描述
  void _autoExtractDescription() {
    final body = generatedBody.value;
    if (body.isEmpty) return;

    // 按句号、问号、感叹号、换行分割
    final sentences = body.split(RegExp(r'[。！？\n]')).where((s) => s.trim().isNotEmpty).toList();
    if (sentences.isEmpty) return;

    // 取前两句，不足则取全部
    final excerpt = sentences.take(2).join('。').trim();
    description.value = excerpt.endsWith('。') ? excerpt : '$excerpt。';
    descriptionEditController.text = description.value;
  }

  /// 流式打字机效果：逐字将 generatedBody 展示到 displayedBody
  void _startTypingEffect() {
    _typeTimer?.cancel();

    // 先瞬间显示标题（标题短，无需逐字）
    displayedTitle.value = generatedTitle.value;

    final String fullBody = generatedBody.value;
    if (fullBody.isEmpty) {
      isGenerating.value = false;
      return;
    }

    int charIndex = 0;
    const int charsPerTick = 3; // 每次添加 3 个字符，模拟流式速度
    const Duration tickDuration = Duration(milliseconds: 30);

    _typeTimer = Timer.periodic(tickDuration, (timer) {
      if (charIndex >= fullBody.length) {
        timer.cancel();
        _typeTimer = null;
        isGenerating.value = false;
        return;
      }

      int endIndex = charIndex + charsPerTick;
      if (endIndex > fullBody.length) {
        endIndex = fullBody.length;
      }
      displayedBody.value = fullBody.substring(0, endIndex);
      charIndex = endIndex;
    });
  }

  /// 进入编辑模式
  void enterEditMode() {
    titleEditController.text = displayedTitle.value;
    bodyEditController.text = displayedBody.value;
    descriptionEditController.text = description.value;
    isEditing.value = true;
    // 停止正在进行的打字机效果
    _typeTimer?.cancel();
    _typeTimer = null;
    // 将完整内容直接显示
    displayedTitle.value = generatedTitle.value;
    displayedBody.value = generatedBody.value;
  }

  void saveEdits() {
    generatedTitle.value = titleEditController.text;
    generatedBody.value = bodyEditController.text;
    description.value = descriptionEditController.text;
    displayedTitle.value = titleEditController.text;
    displayedBody.value = bodyEditController.text;
    isEditing.value = false;
    // 保存描述到行程
    _saveDescriptionToJourney();
  }

  /// 分享游记卡片：导出为图片并分享
  Future<void> shareNoteCardAsImage() async {
    // 实际导出由 NotePage 的 RepaintBoundary 完成
    // 此处仅作为逻辑入口标记
  }

  /// 保存游记卡片到相册
  Future<void> saveNoteCardToGallery() async {
    // 实际导出由 NotePage 的 RepaintBoundary 完成
    // 此处仅作为逻辑入口标记
  }

  /// 保存描述到行程（mock）
  Future<void> _saveDescriptionToJourney() async {
    if (journeyId.isEmpty) return;
    final updatedJourney = await _journeyService.updateJourney(
      journeyId,
      description: description.value,
    );
    if (updatedJourney != null) {
      journey.value = updatedJourney;
    }
  }

  /// 分享逻辑：复制到剪贴板
  void shareToClipboard() {
    String shareText =
        "${generatedTitle.value}\n\n"
        "${generatedBody.value}\n\n"
        "${hashtags.map((e) => "#$e").join(" ")}";

    Clipboard.setData(ClipboardData(text: shareText)).then((_) {
      Get.snackbar(
        "已复制",
        "文案已复制到剪贴板，去社交平台分享吧！",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    });
  }
}