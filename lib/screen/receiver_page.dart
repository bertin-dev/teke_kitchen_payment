import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/qr_controller.dart';

class ReceiverPage extends StatelessWidget {
  final QRController qrController = Get.put(QRController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Code Generator')),
      body: Center(
        child: Obx(() {
          // Retourne toujours un Widget, même si la condition n'est pas remplie
          if (qrController.phoneNumber.value.isEmpty) {
            return Text('No phone number set');
          } else {
            return QrImageView(
              data: qrController.phoneNumber.value,
              size: 200,
              version: QrVersions.auto,
              embeddedImage: AssetImage('assets/images/icon.jpg'), // Assurez-vous que le logo est bien là
            );
          }
        }),
      ),
    );
  }
}
