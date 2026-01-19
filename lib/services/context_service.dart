import '../core/net/api_client.dart';
import '../models/context_model.dart';

class ContextService {
  final ApiClient _apiClient = ApiClient();

  /// 获取逆地理编码信息 (经纬度转地址)
  Future<GeoLocationInfo?> getGeoInfo(double lat, double lon) async {
    try {
      final response = await _apiClient.get(
        '/context/geo',
        queryParameters: {'lat': lat.toString(), 'lon': lon.toString()},
      );
      return GeoLocationInfo.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  /// 获取天气
  Future<WeatherInfo?> getWeather(String locationName) async {
    try {
      final response = await _apiClient.get(
        '/context/weather',
        queryParameters: {'location': locationName},
      );
      return WeatherInfo.fromJson(response.data['data']['weather']);
    } catch (e) {
      return null;
    }
  }
}
