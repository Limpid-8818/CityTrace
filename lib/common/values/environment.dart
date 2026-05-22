// Flutter 官方推荐的环境管理方案
//
// 使用方式（编译时通过 --dart-define 注入环境变量）：
//
// 开发环境:
//   flutter run --dart-define=APP_ENV=dev
//
// 测试环境:
//   flutter run --dart-define=APP_ENV=staging
//
// 生产环境:
//   flutter run --dart-define=APP_ENV=prod
//
// 批量注入（推荐 —— 通过 JSON 配置文件管理）:
//   1. 复制 config/env_template.json 为 config/development.json 并填入真实值
//   2. 运行:
//      flutter run --dart-define-from-file=config/development.json
//      flutter run --dart-define-from-file=config/staging.json
//      flutter run --dart-define-from-file=config/production.json
//
// 构建:
//   flutter build apk  --dart-define-from-file=config/production.json
//   flutter build ios   --dart-define-from-file=config/production.json

/// 环境类型枚举
enum AppEnvironment {
  dev('dev', '开发环境'),
  staging('staging', '测试环境'),
  prod('prod', '生产环境');

  final String value;
  final String label;
  const AppEnvironment(this.value, this.label);

  /// 从字符串解析环境，默认返回 dev
  static AppEnvironment fromString(String? env) {
    return AppEnvironment.values.firstWhere(
      (e) => e.value == env,
      orElse: () => AppEnvironment.dev,
    );
  }
}

/// 环境配置类 —— 管理所有与环境相关的配置项
class AppEnvConfig {
  // ──────────────────────────────────────────────
  // 1. 当前环境
  // ──────────────────────────────────────────────
  /// 当前运行环境（通过 --dart-define=APP_ENV=xxx 注入）
  static final AppEnvironment current = AppEnvironment.fromString(
    const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
  );

  /// 是否为开发环境
  static bool get isDev => current == AppEnvironment.dev;
  /// 是否为测试环境
  static bool get isStaging => current == AppEnvironment.staging;
  /// 是否为生产环境
  static bool get isProd => current == AppEnvironment.prod;

  // ──────────────────────────────────────────────
  // 2. API 后端地址
  // ──────────────────────────────────────────────
  /// 后端 API Base URL（通过 --dart-define=BASE_URL=xxx 注入）
  static String get baseUrl {
    // 优先使用编译时注入的 BASE_URL
    const injectedUrl = String.fromEnvironment('BASE_URL');
    if (injectedUrl.isNotEmpty) return injectedUrl;

    // 兜底：根据环境选择默认地址
    switch (current) {
      case AppEnvironment.dev:
        return 'http://10.0.2.2:4523/m1/7557631-7295075-default/api/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.citytrace.com/api/v1';
      case AppEnvironment.prod:
        return 'https://api.citytrace.com/api/v1';
    }
  }

  // ──────────────────────────────────────────────
  // 3. 超时配置
  // ──────────────────────────────────────────────
  /// 连接超时（毫秒）
  static int get connectTimeout {
    const timeout = int.fromEnvironment('CONNECT_TIMEOUT', defaultValue: 0);
    if (timeout > 0) return timeout;
    return current == AppEnvironment.dev ? 60000 : 30000;
  }

  /// 接收超时（毫秒）
  static int get receiveTimeout {
    const timeout = int.fromEnvironment('RECEIVE_TIMEOUT', defaultValue: 0);
    if (timeout > 0) return timeout;
    return 60000;
  }

  // ──────────────────────────────────────────────
  // 4. 应用名称
  // ──────────────────────────────────────────────
  /// 带环境后缀的应用名称，用于 UI 上区分环境
  static String get appName {
    const name = String.fromEnvironment('APP_NAME', defaultValue: 'CityTrace');
    if (current == AppEnvironment.prod) return name;
    return '$name (${current.label})';
  }

  // ──────────────────────────────────────────────
  // 5. 日志与调试
  // ──────────────────────────────────────────────
  /// 是否启用调试日志
  static bool get enableDebugLog => current != AppEnvironment.prod;

  /// 是否启用 Mock 模式（仅在 dev 环境默认启用）
  static bool get enableMock {
    const mock = String.fromEnvironment('ENABLE_MOCK');
    if (mock == 'true') return true;
    if (mock == 'false') return false;
    return current == AppEnvironment.dev;
  }

  /// Dio 的 LogInterceptor 是否打印请求/响应日志
  static bool get enableHttpLog => current != AppEnvironment.prod;

  /// 是否显示 Flutter 调试 banner
  static bool get showDebugBanner => current != AppEnvironment.prod;

  // ──────────────────────────────────────────────
  // 6. 其他可选配置
  // ──────────────────────────────────────────────
  /// 应用版本名称（可选覆盖）
  static String get versionName =>
      const String.fromEnvironment('VERSION_NAME', defaultValue: '1.0.0');

  /// 自定义扩展字段：可用于传递任意 JSON 格式的配置
  static String get extra =>
      const String.fromEnvironment('EXTRA_CONFIG', defaultValue: '{}');
}