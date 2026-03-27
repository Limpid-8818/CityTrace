import 'package:package_info_plus/package_info_plus.dart';

class MetadataUtil {
  MetadataUtil._internal();

  static late String appName;
  static late String packageName;
  static late String version;
  static late String buildNumber;

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  static String get fullVersion => 'v$version+$buildNumber';
}
