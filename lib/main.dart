import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/config/app_theme.dart';
import 'core/init/app_initializer.dart';
import 'features/auth/screens/splash_screen.dart';

void main() async {
  await AppInitializer.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
