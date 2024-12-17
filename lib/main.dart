import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:teke_kitchen_payments/screen/client_page.dart';
import 'package:teke_kitchen_payments/screen/splash_screen.dart';

import 'controllers/client_controller.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  Get.put(ClientController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Teke Kitchen',
      home: SplashScreen(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/client', page: () => ClientPage()),
      ],
    );
  }
}

