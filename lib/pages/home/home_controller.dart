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

  /// 开始行程按钮的逻辑
  void startJourney() {
    if (!userController.isLoggedIn) {
      // 未登录，拦截并跳转
      Get.toNamed('/login');
    } else {
      // 已登录，执行开始行程逻辑
      print("🚀 开始新的行程...");
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
