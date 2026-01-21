import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/ai_service.dart';

class NoteController extends GetxController {
  final AIService _aiService = AIService();

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

  // 用于编辑的 TextEditingController
  late TextEditingController titleEditController;
  late TextEditingController bodyEditController;

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
  }

  @override
  void onClose() {
    titleEditController.dispose();
    bodyEditController.dispose();
    super.onClose();
  }

  /// 执行生成逻辑
  Future<void> startGenerating() async {
    if (journeyId.isEmpty) return;

    if (selectedStyle.value == "custom" && customPrompt.value.trim().isEmpty) {
      Get.snackbar("提示", "请输入您想要的风格描述");
      return;
    }

    isGenerating.value = true;

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
    }

    isGenerating.value = false;
  }

  /// 进入编辑模式
  void enterEditMode() {
    titleEditController.text = generatedTitle.value;
    bodyEditController.text = generatedBody.value;
    isEditing.value = true;
  }

  void saveEdits() {
    generatedTitle.value = titleEditController.text;
    generatedBody.value = bodyEditController.text;
    isEditing.value = false;
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
