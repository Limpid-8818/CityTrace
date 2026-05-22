import '../common/values/environment.dart';

/// Mock 配置
/// 当 [enableMock] 为 true 时，API 请求将被 MockInterceptor 拦截并返回模拟数据
class MockConfig {
  /// 是否启用 Mock 模式（开发调试用）
  /// true  = 不请求后端，使用本地模拟数据
  /// false = 正常请求后端 API
  ///
  /// 默认值由 AppEnvConfig.enableMock 控制（dev 环境为 true，其他环境为 false）
  /// 也可通过 --dart-define=ENABLE_MOCK=true/false 强制覆盖
  static bool get enableMock => AppEnvConfig.enableMock;

  /// 模拟登录延迟（毫秒），模拟网络请求耗时
  static int mockDelayMs = 800;

  /// 模拟普通请求延迟（毫秒）
  static int mockNormalDelayMs = 300;
}