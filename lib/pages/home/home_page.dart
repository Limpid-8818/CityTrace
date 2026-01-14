import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final userController = Get.find<UserController>();

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildLeftDrawer(controller, userController),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 顶部 Header
              _buildTopBar(controller, userController),
              const SizedBox(height: 32),

              // 2. 欢迎语
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, ${userController.user?.username ?? '探索者'}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "今天准备去哪里留下印记？",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. 地点与天气 (模拟数据)
              const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  Text(" 北京市  ", style: TextStyle(color: Colors.grey)),
                  Icon(Icons.wb_cloudy_outlined, size: 18, color: Colors.grey),
                  Text(" 晴朗 · 22°C", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),

              // 4. 核心状态卡片 (Hero Card)
              _buildHeroCard(),

              const SizedBox(height: 32),

              // 5. 最近的旅程标题
              const Text(
                "最近的旅程",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 6. 横向列表
              SizedBox(
                height: 220,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.recentTrips.length,
                    itemBuilder: (context, index) {
                      return _buildTripCard(controller.recentTrips[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 7. 悬浮启动按钮 (FAB)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => controller.startJourney(),
        backgroundColor: const Color(0xFF009688),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  // 内部组件拆解

  Widget _buildTopBar(
    HomeController controller,
    UserController userController,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => controller.handleAvatarClick(),
          child: Obx(
            () => CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                userController.user?.avatar ??
                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Colors.black54),
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (value) => Fluttertoast.showToast(msg: "点击了 $value"),
          itemBuilder: (context) => [
            _buildPopupItem("设置", Icons.settings_outlined, "settings"),
            _buildPopupItem("帮助与反馈", Icons.help_outline, "help"),
            _buildPopupItem("关于我们", Icons.info_outline, "about"),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String title,
    IconData icon,
    String value,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildLeftDrawer(
    HomeController controller,
    UserController userController,
  ) {
    return Drawer(
      width: Get.width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // 侧边栏头部：用户信息
          _buildDrawerHeader(userController),
          // 菜单列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDrawerItem(
                  Icons.person_outline,
                  "个人主页",
                  () => controller.handleMenuClick('/profile'),
                ),
                _buildDrawerItem(
                  Icons.location_on_outlined,
                  "全部行程",
                  () => controller.handleMenuClick('/journeys'),
                ),
                _buildDrawerItem(
                  Icons.calendar_today_outlined,
                  "行程计划",
                  () => controller.handleMenuClick('/plans'),
                ),
                _buildDrawerItem(
                  Icons.favorite_outline,
                  "我的收藏",
                  () => controller.handleMenuClick('/favorites'),
                ),
                _buildDrawerItem(
                  Icons.share_outlined,
                  "分享动态",
                  () => controller.handleMenuClick('/share'),
                ),
              ],
            ),
          ),
          // 底部退出按钮
          const Divider(),
          _buildDrawerItem(
            Icons.logout,
            "退出登录",
            () => userController.logout(),
            color: Colors.red,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(UserController userController) {
    return Obx(() {
      // 预设默认头像地址
      const String defaultAvatar =
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";

      // 获取当前的头像地址，如果是 null 或空字符串则使用默认图
      String? avatarUrl = userController.user?.avatar;
      bool hasValidAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

      return Container(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
        color: const Color(0xFF009688),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  backgroundImage: NetworkImage(
                    hasValidAvatar ? avatarUrl : defaultAvatar,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userController.user?.username ?? "探索者",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: CityTrace_2024",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.black87, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.tealAccent.shade100.withOpacity(0.5), Colors.white],
        ),
        border: Border.all(color: Colors.tealAccent.shade100.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF009688),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "尚未开始行程",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text("点击下方按钮并开始探索你的足迹", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, String> trip) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              trip['img']!,
              height: 140,
              width: 140,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            trip['title']!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            trip['date']!,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
