import 'package:get/get.dart';
import '../../services/ai_service.dart';

class NoteController extends GetxController {
  final AIService _aiService = AIService();

  // 接收参数
  late String journeyId;

  // --- 响应式变量 ---
  final RxString selectedStyle = "moments".obs; // 默认：朋友圈风格
  final RxString generatedTitle = "".obs;
  final RxString generatedBody = "".obs;
  final RxList<String> hashtags = <String>[].obs;
  final RxBool isGenerating = false.obs;

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
  }

  /// 执行生成逻辑
  Future<void> startGenerating() async {
    if (journeyId.isEmpty) return;

    isGenerating.value = true;

    final result = await _aiService.generateNote(
      journeyId: journeyId,
      style: selectedStyle.value,
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
}
