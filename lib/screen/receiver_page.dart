import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:teke_kitchen_payments/themes/app_color.dart';
import '../controllers/history_controller.dart';
import '../controllers/qr_controller.dart';

/*class ReceiverPage extends StatelessWidget {
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
              size: 250,
              version: QrVersions.auto,
              embeddedImage: AssetImage('assets/images/icon.jpg'), // Assurez-vous que le logo est bien là
            );
          }
        }),

      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.defaultDialog(
            title: 'Enter Phone Number',
            content: TextField(
              keyboardType: TextInputType.phone,
              controller: qrController.phoneController,
              decoration: InputDecoration(hintText: 'Enter phone number'),
            ),
            textConfirm: 'Generate',
            onConfirm: () {
              // Déterminer l'opérateur et sauvegarder
              String operator = qrController.determineOperator(qrController.phoneController.text);
              qrController.savePhoneNumber(qrController.phoneController.text);
              Get.back();
              Get.snackbar('Operator', 'Le numéro appartient à $operator');
            },
          );
        },
      ),
    );
  }
}*/



class ReceiverPage extends StatelessWidget {
  final HistoryController controller = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    // Changez la couleur de la barre d'état
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor, // Couleur de la barre d'état
      statusBarIconBrightness: Brightness.light, // Couleur des icônes de la barre d'état
    ));

    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(title: Padding(
        padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
        child: Text('Recevoir Paiements',
          style: TextStyle(color: AppColor.primary),),
      ),
        backgroundColor: AppColor.secondaryColor,
        iconTheme: IconThemeData(color: AppColor.primary), // Change la couleur des icônes
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: '${controller.primaryNumber.value}/${controller.secondaryNumber.value}',
              size: 250,
              version: QrVersions.auto,
              embeddedImage: AssetImage('assets/images/icon.jpg'), // Assurez-vous que le logo est bien là
            ),
            SizedBox(height: 20),
            Obx(() => Text(
              'Principal: ${controller.primaryNumber.value}\nSecondaire: ${controller.secondaryNumber.value}',
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.secondaryColor,
        onPressed: () => _showNumberDialog(context),
        child: Icon(Icons.add, color: AppColor.primary,),
      ),
    );
  }

  void _showNumberDialog(BuildContext context) {
    String primaryNumber = controller.primaryNumber.value;
    String secondaryNumber = controller.secondaryNumber.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Phone Numbers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                primaryNumber = value;
              },
              decoration: InputDecoration(hintText: 'Primary Number'),
              controller: TextEditingController(text: primaryNumber),
            ),
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                secondaryNumber = value;
              },
              decoration: InputDecoration(hintText: 'Secondary Number'),
              controller: TextEditingController(text: secondaryNumber),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.saveNumbers(primaryNumber, secondaryNumber);
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

