import 'dart:async';

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../core/utils/location_util.dart';

class MapTraceController extends GetxController {
  // 响应式数据
  final RxList<LatLng> tracePoints = <LatLng>[].obs;
  final Rx<LatLng?> currentPos = Rx<LatLng?>(null);
  final RxBool isRecording = false.obs;

  StreamSubscription<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    _startLocationListening();
  }

  /// 开启持续定位监听
  void _startLocationListening() async {
    if (_positionStream != null) return;

    bool hasPermission = await LocationUtil.checkPermission();
    if (!hasPermission) return;

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: LocationUtil.getLocationSettings(),
        ).listen((Position position) {
          LatLng point = LatLng(position.latitude, position.longitude);

          // 更新当前全局坐标
          currentPos.value = point;

          // 如果正在录制，则追加点到轨迹
          if (isRecording.value) {
            tracePoints.add(point);
          }
        });
  }

  /// 开始行程录制
  void startJourney() {
    tracePoints.clear();
    isRecording.value = true;
  }

  /// 结束行程录制
  void stopJourney() {
    isRecording.value = false;
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    super.onClose();
  }
}
