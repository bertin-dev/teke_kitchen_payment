import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:teke_kitchen_payments/screen/marchand_home_page.dart';
import 'package:teke_kitchen_payments/screen/client_page.dart';
import 'package:teke_kitchen_payments/screen/operator_page.dart';
import 'package:teke_kitchen_payments/screen/qrCode_page.dart';
import 'package:teke_kitchen_payments/screen/splash_screen.dart';

import 'controllers/client_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/sms_controller.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  Get.put(HistoryController());
  Get.put(SMSController());
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
      //theme: ThemeData(primarySwatch: AppColor.secondaryColor),
      home: SplashScreen(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => MarchandHomePage()),
        GetPage(name: '/operator', page: () => OperatorPage()),
        GetPage(name: '/qr', page: () => QRCodePage()),
        GetPage(name: '/client', page: () => ClientPage()),
      ],
    );
  }
}

