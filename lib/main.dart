import 'package:citytrace/common/values/environment.dart';
import 'package:citytrace/core/theme/app_colors.dart';
import 'package:citytrace/controllers/map_trace_controller.dart';
import 'package:citytrace/core/utils/metadata_util.dart';
import 'package:citytrace/core/utils/storage_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'common/routes/app_routes.dart';
import 'controllers/user_controller.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtil.init();
  await MetadataUtil.init();

  print(
    '═══════════════════════════════════════════\n'
    '  CityTrace 启动\n'
    '  环境: ${AppEnvConfig.current.label} (${AppEnvConfig.current.value})\n'
    '  API: ${AppEnvConfig.baseUrl}\n'
    '  Mock: ${AppEnvConfig.enableMock}\n'
    '═══════════════════════════════════════════',
  );

  // 全局注入 UserController 和 MapTraceController
  Get.put(UserController(), permanent: true);
  Get.put(MapTraceController(), permanent: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(411.4, 914.3), // Google Pixel 7 标准
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppEnvConfig.appName,
          debugShowCheckedModeBanner: AppEnvConfig.showDebugBanner,
          // 默认主题配置
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            primaryColor: AppColors.primary,
            useMaterial3: true,
          ),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
