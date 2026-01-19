import 'package:dio/dio.dart';
import '../../core/net/api_client.dart';
import '../../models/moment_model.dart';

class MomentService {
  final ApiClient _apiClient = ApiClient();

  /// 1. 上传瞬间
  Future<MomentModel?> uploadMoment({
    required String journeyId,
    required String type, // image/audio/text/location
    required String lat,
    required String lon,
    String? title,
    String? locationName,
    String? context,
    String? filePath,
  }) async {
    try {
      Map<String, dynamic> map = {
        'journeyId': journeyId,
        'type': type,
        'lat': lat,
        'lon': lon,
        'location': locationName,
        'context': context,
        'title': title,
      };

      if (filePath != null && filePath.isNotEmpty) {
        map['media'] = await MultipartFile.fromFile(filePath);
      }

      FormData formData = FormData.fromMap(map);
      final response = await _apiClient.post('/journey/moment', data: formData);
      return MomentModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  /// 2. 获取瞬间详情
  Future<MomentModel?> getMomentDetail(String momentId) async {
    try {
      final response = await _apiClient.get('/journey/moment/$momentId');
      return MomentModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  /// 3. 更新瞬间详情
  Future<MomentModel?> updateMoment(
    String momentId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/journey/moment/$momentId',
        data: updateData,
      );
      return MomentModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  /// 4. 删除瞬间
  Future<bool> deleteMoment(String momentId) async {
    try {
      final response = await _apiClient.delete('/journey/moment/$momentId');
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }
}
