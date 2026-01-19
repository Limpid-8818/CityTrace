// lib/services/ai_service.dart
import '../core/net/api_client.dart';

class AIService {
  final ApiClient _apiClient = ApiClient();

  /// 生成 AI 游记
  Future<Map<String, dynamic>?> generateNote({
    required String journeyId,
    String style = "command",
    String? prompt,
  }) async {
    try {
      final response = await _apiClient.post(
        '/ai/generate/note',
        data: {'journeyId': journeyId, 'style': style, 'prompt': prompt},
      );
      // 返回包含 title, body, tags 的 Map
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  // 图像分析：返回描述和标签
  Future<Map<String, dynamic>?> analyzeImage(String momentId) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/ai/analyze/image',
        data: {'momentId': momentId},
      );
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  /// 音频分析：返回转写文本和情感
  Future<Map<String, dynamic>?> analyzeAudio(String momentId) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/ai/analyze/audio',
        data: {'momentId': momentId},
      );
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }
}
