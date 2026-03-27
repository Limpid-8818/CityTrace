import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../controllers/user_controller.dart';
import '../../core/utils/crypto_util.dart';

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

  String? validateUsername() {
    if (usernameController.text.trim().isEmpty) {
      return "请输入用户名";
    }
    if (usernameController.text.length < 2) {
      return "用户名至少2个字符";
    }
    return null;
  }

  String? validateAccount() {
    if (accountController.text.trim().isEmpty) {
      return "请输入账号";
    }
    return null;
  }

  String? validatePassword() {
    if (passwordController.text.trim().isEmpty) {
      return "请输入密码";
    }
    if (!isLogin.value &&
        (passwordController.text.length < 6 ||
            passwordController.text.length > 18)) {
      return "密码为6~18位字母、数字或下划线";
    }
    return null;
  }

  /// 提交表单
  Future<void> submit() async {
    final account = accountController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    // 提交前校验
    if (!isLogin.value) {
      final usernameHint = validateUsername();
      if (usernameHint != null) {
        Get.snackbar("提示", usernameHint, snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    final accountHint = validateAccount();
    if (accountHint != null) {
      Get.snackbar("提示", accountHint, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final passwordHint = validatePassword();
    if (passwordHint != null) {
      Get.snackbar("提示", passwordHint, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    // 对密码进行加盐
    final saltedPassword = CryptoUtil.hashPassword(password, account);

    bool success = false;
    if (isLogin.value) {
      // 执行登录
      success = await _authService.login(account, saltedPassword);
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
        password: saltedPassword,
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
