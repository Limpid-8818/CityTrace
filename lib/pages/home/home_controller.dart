import 'package:flutter/material.dart';

import '../../controllers/user_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final UserController userController = Get.find<UserController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final RxList<Map<String, String>> recentTrips = <Map<String, String>>[
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
  ].obs;

  final RxBool isMapReadyInSheet = false.obs;

  /// 当弹窗打开时，由 View 调用此方法开启倒计时
  void startMapLoadingTimer() {
    isMapReadyInSheet.value = false; // 重置
    Future.delayed(const Duration(milliseconds: 450), () {
      print("ready to show map");
      isMapReadyInSheet.value = true;
    });
  }

  /// 开始行程按钮的逻辑
  bool canStartJourney() {
    if (!userController.isLoggedIn) {
      // 未登录，拦截并跳转
      Get.toNamed('/login');
      return false;
    } else {
      // 已登录，执行开始行程逻辑
      return true;
    }
  }

  /// 点击头像
  void handleAvatarClick() {
    if (userController.isLoggedIn) {
      scaffoldKey.currentState?.openDrawer();
    } else {
      Get.toNamed('/login');
    }
  }

  /// 点击侧边栏菜单
  void handleMenuClick(String route) {
    if (userController.isLoggedIn) {
      Get.toNamed(route);
    } else {
      Get.toNamed('/login');
    }
  }
}
