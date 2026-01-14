import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../controllers/user_controller.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final UserController _userController = Get.find<UserController>();

  // 控制器
  final accountController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  // 响应式变量
  final isLogin = true.obs; // 是否为登录模式
  final isLoading = false.obs; // 是否正在提交
  final obscureText = true.obs; // 密码是否隐藏

  /// 切换登录/注册模式
  void toggleMode() {
    isLogin.value = !isLogin.value;
  }

  /// 提交表单
  Future<void> submit() async {
    final account = accountController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (account.isEmpty || password.isEmpty) {
      Get.snackbar("提示", "请输入账号和密码", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    bool success = false;
    if (isLogin.value) {
      // 执行登录
      success = await _authService.login(account, password);
    } else {
      // 执行注册
      if (username.isEmpty) {
        Get.snackbar("提示", "请输入用户名", snackPosition: SnackPosition.BOTTOM);
        isLoading.value = false;
        return;
      }
      success = await _authService.register(
        username: username,
        account: account,
        password: password,
      );
    }

    if (success) {
      // 获取用户信息并更新全局状态
      final profile = await _authService.getProfile();
      if (profile != null) {
        _userController.onLoginSuccess(profile);
      }
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    accountController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
