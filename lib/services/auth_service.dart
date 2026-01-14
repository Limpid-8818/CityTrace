import 'dart:io';
import 'package:dio/dio.dart';
import '../core/net/api_client.dart';
import '../core/utils/storage_util.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// 用户注册
  Future<bool> register({
    required String username,
    required String account,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/user/register',
        data: {'username': username, 'account': account, 'password': password},
      );

      // 注册成功直接返回 token，直接自动登录
      if (response.data['code'] == 0) {
        await _saveToken(response.data['data']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 用户登录
  Future<bool> login(String account, String password) async {
    try {
      final response = await _apiClient.post(
        '/user/login',
        data: {'account': account, 'password': password},
      );

      if (response.data['code'] == 0) {
        await _saveToken(response.data['data']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取个人资料
  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiClient.get('/user/profile');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  /// 更新个人资料
  Future<bool> updateProfile(UserModel user) async {
    try {
      final response = await _apiClient.put(
        '/user/profile',
        data: user.toJson(),
      );
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }

  /// 上传头像
  Future<String?> uploadAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "avatar": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        '/user/avatar/upload',
        data: formData,
      );
      return response.data['data']['avatarUrl'];
    } catch (e) {
      return null;
    }
  }

  /// 检查登录状态
  Future<bool> checkToken() async {
    try {
      final response = await _apiClient.get('/user/check-token');
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await _apiClient.post('/user/logout');
    } catch (e) {
      return;
    }
  }

  /// 保存登录成功后的 Token
  Future<void> _saveToken(Map<String, dynamic> data) async {
    await StorageUtil.setToken(data['token']);
  }
}
