import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../services/journey_management/journey_service.dart';
import '../../models/user_model.dart';
import '../../core/utils/storage_util.dart';

class ProfileController extends GetxController {
  final UserController _userController = Get.find<UserController>();
  final JourneyService _journeyService = JourneyService();

  // 对外提供用户信息
  UserModel? get currentUser => _userController.user;

  // 响应式数据
  final RxInt totalMileage = 0.obs; // 总里程（米）
  final RxInt totalPoints = 0.obs; // 足迹点个数
  final RxString totalDuration = "00:00:00".obs; // 总探索时长
  final RxBool isLoadingStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  /// 加载用户个人资料和统计数据
  Future<void> _loadUserProfile() async {
    if (!_userController.isLoggedIn) {
      return;
    }

    isLoadingStats.value = true;

    try {
      // 获取行程列表以计算统计数据
      final journeys = await _journeyService.getJourneyList(page: 1, size: 100);

      int mileage = 0;
      int points = 0;

      for (var journey in journeys) {
        // 这里需要根据实际的行程数据计算里程和点数
        // 暂时设置为示例值
        points += 10; // 假设每个行程有10个点
      }

      totalPoints.value = points;
      totalMileage.value = mileage;
      totalDuration.value = _formatDuration(points * 60); // 假设每个点1分钟
    } catch (e) {
      print("加载用户资料失败: $e");
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// 格式化时长
  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(secs)}";
  }

  /// 退出登录
  void logout() => _userController.logout();

  /// 更新用户名
  Future<void> updateUsername(String newUsername) async {
    if (currentUser == null) return;

    try {
      // 这里应该调用后端API更新用户名
      // 暂时模拟更新过程
      await Future.delayed(const Duration(milliseconds: 500));

      // 更新本地用户信息
      final updatedUser = UserModel(
        userId: currentUser!.userId,
        account: currentUser!.account,
        username: newUsername,
        avatar: currentUser!.avatar,
      );

      // 更新全局用户状态
      _userController.onLoginSuccess(updatedUser);

      // 更新本地存储
      StorageUtil.setUsername(newUsername);
    } catch (e) {
      print("更新用户名失败: $e");
      rethrow;
    }
  }
}
