import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_connect/features/auth/screens/login.dart';
import 'package:solar_connect/features/installer/dashboard.dart';
import 'package:solar_connect/features/brand/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(
          name: '/installer-dashboard',
          page: () => const InstallerDashboard(),
        ),
        GetPage(name: '/brand-dashboard', page: () => const BrandDashboard()),
      ],
    );
  }
}
