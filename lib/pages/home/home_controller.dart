import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/user_controller.dart';
import '../../controllers/map_trace_controller.dart';
import '../../services/journey_management/journey_service.dart';
import '../../services/context_service.dart';
import '../../models/user_model.dart';

class HomeController extends GetxController {
  // 依赖注入
  final UserController _userController = Get.find<UserController>();
  final MapTraceController _mapController = Get.find<MapTraceController>();
  final JourneyService _journeyService = JourneyService();
  final ContextService _contextService = ContextService();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // 响应式变量
  final RxList<Map<String, String>> recentTrips = <Map<String, String>>[].obs;
  final RxBool isMapReadyInSheet = false.obs;
  final RxString locationDisplay = "定位中...".obs; // 显示格式：上海市·黄浦区
  final RxString weatherDisplay = "--°C".obs; // 显示格式：多云 · 22°C

  // 记录变量控制请求频率
  LatLng? _lastFetchPos;
  DateTime? _lastFetchTime;

  // 对外提供 Getter 方法
  UserModel? get currentUser => _userController.user;
  bool get isLoggedIn => _userController.isLoggedIn;
  LatLng? get currentPos => _mapController.currentPos.value;

  // 页面初始化
  /// 加载最近行程并开启位置监听
  @override
  void onInit() {
    super.onInit();
    _loadRecentTrips();
    // 监听位置变化
    ever(_mapController.currentPos, (LatLng? pos) {
      if (pos != null) _handlePositionChange(pos);
    });
  }

  // 逻辑处理

  void _loadRecentTrips() {
    // 这里的 Mock 数据未来可以替换为 _journeyService.getJourneyList()
    recentTrips.assignAll([
      {
        "title": "北京",
        "date": "2021年1月2日",
        "img": "https://picsum.photos/200/300?random=1",
      },
      {
        "title": "重庆旅行",
        "date": "2022年1月1日",
        "img": "https://picsum.photos/200/300?random=2",
      },
      {
        "title": "大连",
        "date": "2023年",
        "img": "https://picsum.photos/200/300?random=3",
      },
    ]);
  }

  /// 开始行程
  Future<void> onStartJourneyConfirmed() async {
    // 调用后端创建行程
    final newJourney = await _journeyService.startJourney(
      title: "新行程 ${DateTime.now().hour}:${DateTime.now().minute}",
      description: "开启一段奇妙的城市寻迹",
    );

    if (newJourney != null) {
      // 启动轨迹录制
      _mapController.startJourney();
      // UI 反馈
      Get.back(); // 关闭底栏
      Get.toNamed('/journey', arguments: newJourney.journeyId);
    }
  }

  /// 头像点击
  void handleAvatarClick() {
    isLoggedIn ? scaffoldKey.currentState?.openDrawer() : Get.toNamed('/login');
  }

  /// 侧边栏菜单点击
  void handleMenuClick(String route) {
    isLoggedIn ? Get.toNamed(route) : Get.toNamed('/login'); // 一般碰不到跳回登录页的情况
  }

  /// 未登录状态下悬浮按钮点击
  void handleUnlogFabClick() {
    Get.toNamed('/login');
  }

  /// Bottom Sheet 地图渲染计时器
  void startMapLoadingTimer() {
    isMapReadyInSheet.value = false;
    Future.delayed(
      const Duration(milliseconds: 400),
      () => isMapReadyInSheet.value = true,
    );
  }

  void logout() => _userController.logout();

  /// 处理位置变化，更新环境信息
  void _handlePositionChange(LatLng pos) async {
    // 频率控制：如果距离上次更新不到 500 米且时间不到 10 分钟，就不重复请求
    if (_lastFetchPos != null && _lastFetchTime != null) {
      double distance = const Distance().as(
        LengthUnit.Meter,
        _lastFetchPos!,
        pos,
      );
      if (distance < 500 &&
          DateTime.now().difference(_lastFetchTime!).inMinutes < 10) {
        return;
      }
    }

    // 获取地理位置详情
    final geoInfo = await _contextService.getGeoInfo(
      pos.latitude,
      pos.longitude,
    );
    if (geoInfo != null) {
      locationDisplay.value = "${geoInfo.city} · ${geoInfo.district}";

      // 根据城市/区获取天气
      final weather = await _contextService.getWeather(geoInfo.district);
      if (weather != null) {
        weatherDisplay.value =
            "${weather.condition} · ${weather.temp.toInt()}°C";
      }

      // 更新缓存标记
      _lastFetchPos = pos;
      _lastFetchTime = DateTime.now();
    }
  }
}
