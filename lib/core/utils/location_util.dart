import 'package:geolocator/geolocator.dart';

class LocationUtil {
  /// 权限检查与申请
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.deniedForever;
  }

  /// 获取通用的定位配置
  static LocationSettings getLocationSettings() {
    // return AndroidSettings(
    //   accuracy: LocationAccuracy.high,
    //   distanceFilter: 5, // 每移动5米回调一次，减少数据冗余
    //   intervalDuration: Duration(seconds: 2), // 每2秒上报一次
    //   foregroundNotificationConfig: ForegroundNotificationConfig(
    //     notificationText: "CityTrace正在后台记录您的足迹",
    //     notificationTitle: "行程记录中",
    //     enableWakeLock: true,
    //   ),
    // );
    return AndroidSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
  }
}
