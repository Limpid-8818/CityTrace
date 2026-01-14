import 'package:citytrace/pages/home/home_page.dart';
import 'package:get/get.dart';

import '../../pages/auth/login_page.dart';

class AppPages {
  static const INITIAL = '/';

  static final routes = [
    GetPage(name: '/', page: () => const HomePage()),
    GetPage(name: '/home', page: () => const HomePage()),
    GetPage(name: '/login', page: () => const LoginPage()),
  ];
}
