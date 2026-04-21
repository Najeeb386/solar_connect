import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_partner/features/auth/screens/login.dart';
import 'package:solar_partner/features/auth/screens/signup.dart';
import 'package:solar_partner/features/auth/controllers/auth_controller.dart';
import 'package:solar_partner/features/brand/dashboard.dart';
import 'package:solar_partner/features/brand/controllers/brand_controller.dart';
import 'package:solar_partner/features/installer/dashboard.dart';
import 'package:solar_partner/features/installer/controllers/installer_controller.dart';
import 'package:solar_partner/features/shopkeeper/dashboard.dart';
import 'package:solar_partner/features/shopkeeper/controllers/shopkeeper_controller.dart';

void main() async {
  await GetStorage.init();

  final storage = GetStorage();
  String initialRoute = '/login';

  if (storage.read('token') != null) {
    final user = storage.read('user');
    if (user != null && user['role'] != null) {
      switch (user['role']) {
        case 'installer':
          initialRoute = '/installer-dashboard';
          break;
        case 'brand':
          initialRoute = '/brand-dashboard';
          break;
        case 'shopkeeper':
          initialRoute = '/shopkeeper-dashboard';
          break;
      }
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Solar Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController(), fenix: true);
      }),
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignUpPage()),
        GetPage(
          name: '/installer-dashboard',
          page: () => const InstallerDashboard(),
          binding: BindingsBuilder(() {
            Get.put(InstallerController());
          }),
        ),
        GetPage(
          name: '/brand-dashboard',
          page: () => const BrandDashboard(),
          binding: BindingsBuilder(() {
            Get.put(BrandController());
          }),
        ),
        GetPage(
          name: '/shopkeeper-dashboard',
          page: () => const ShopkeeperDashboard(),
          binding: BindingsBuilder(() {
            Get.put(ShopkeeperController());
          }),
        ),
      ],
    );
  }
}
