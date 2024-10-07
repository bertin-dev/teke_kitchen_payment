import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:teke_kitchen_payments/screen/splash_screen.dart';
import 'package:teke_kitchen_payments/themes/app_color.dart';

import 'controllers/history_controller.dart';
import 'controllers/sender_controller.dart';
import 'controllers/sms_controller.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  Get.put(HistoryController());
  Get.put(SenderController());
  Get.put(SMSController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Teke Kitchen',
      //theme: ThemeData(primarySwatch: AppColor.primary),
      home: SplashScreen(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}

