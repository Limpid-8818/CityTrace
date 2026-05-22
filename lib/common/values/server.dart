import 'environment.dart';

/// 向后兼容层 —— 适配旧代码中 `ServerConfig.BASE_URL` 的调用方式
///
/// 原本是硬编码常量，现在统一委托给 [AppEnvConfig] 动态获取。
/// 新代码建议直接使用 `AppEnvConfig.baseUrl`。
class ServerConfig {
  /// 后端 API Base URL（委托给 AppEnvConfig）
  static String get BASE_URL => AppEnvConfig.baseUrl;

  /// 连接超时（毫秒，委托给 AppEnvConfig）
  static int get CONNECT_TIMEOUT => AppEnvConfig.connectTimeout;

  /// 接收超时（毫秒，委托给 AppEnvConfig）
  static int get RECEIVE_TIMEOUT => AppEnvConfig.receiveTimeout;
}