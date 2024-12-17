import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ClientController extends GetxController {
  RxString marchandNumber = ''.obs;
  RxString amount = ''.obs;
  RxString operatorName = ''.obs;

  void processQRCode(String qrData) {
    // QR Code format attendu : "amount:<value>,operator:<value>,phone:<value>"
    final Map<String, String> data = Map.fromEntries(
      qrData.split(',').map((e) {
        final split = e.split(':');
        return MapEntry(split[0].trim(), split[1].trim());
      }),
    );

    marchandNumber.value = data['Phone'] ?? '';
    amount.value = data['Amount'] ?? '';
    operatorName.value = data['Operator'] ?? '';

    triggerUSSD();
  }

  Future<void> triggerUSSD() async {
    if (marchandNumber.value.isNotEmpty && amount.value.isNotEmpty) {
      String ussdCode = '';

      if (operatorName.value.toLowerCase() == 'orange money') {
        ussdCode = "#150*46*${marchandNumber.value}*${amount.value}#";
      } else if (operatorName.value.toLowerCase() == 'mtn mobile money') {
        ussdCode = "*126*4*${marchandNumber.value}*${amount.value}#";
      }

      try {
        String ussdCodeEncoded = Uri.encodeComponent(ussdCode);

        // Demander la permission d'appel
        var status = await Permission.phone.status;
        if (!status.isGranted) {
          status = await Permission.phone.request();
        }

        if (status.isGranted) {
          try {
            final intent = AndroidIntent(
              action: 'android.intent.action.CALL',
              data: 'tel:$ussdCodeEncoded',
              flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
            );
            await intent.launch();

            // Afficher une notification de succès
            print('Requête USSD envoyée : $ussdCode');
            /*Get.snackbar(
              'Succès',
              'Requête USSD envoyée : $ussdCode',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 10),
            );*/
          } catch (e) {
            // Gérer les erreurs liées à l'envoi de la requête USSD
            Get.snackbar(
                'Erreur',
                'Échec lors de l\'envoi de la requête USSD.',
                backgroundColor: Colors.red,
                colorText: Colors.white
            );
          }
        } else {
          Get.snackbar(
              'Permission refusée',
              'L\'application n\'a pas la permission de passer des appels.',
              backgroundColor: Colors.red,
              colorText: Colors.white
          );
        }

        //Get.snackbar("USSD Déclenché", "Requête envoyée : $ussdCode");
      } catch (e) {
        Get.snackbar("Erreur", "Impossible d'envoyer la requête USSD",
          backgroundColor: Colors.red,);
      }
    }
  }
}
