import 'package:telephony/telephony.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'history_controller.dart';

class SMSController extends GetxController {
  final Telephony telephony = Telephony.instance;
  final HistoryController historyController = Get.find<HistoryController>();

  @override
  void onInit() {
    super.onInit();
    _listenForSMS();
  }

  void _listenForSMS() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    if (result != null && result) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          String content = message.body ?? "";
          if (content.isNotEmpty) {
            if(content.toLowerCase().contains("depot") || content.toLowerCase().contains("transfert")){

              // Si le message contient le mot "réussi", on considère que l'opération est un succès
              bool isSuccess = content.toLowerCase().contains("reussi") || content.toLowerCase().contains("effectue");

              // Ajouter le message à l'historique dans SQLite
              historyController.addToHistory("Paiement QR Code", content, DateTime.now().toIso8601String(), isSuccess);

              // Vibration pour confirmer la réception du SMS
              if (Vibration.hasVibrator() != null) {
                Vibration.vibrate();
              }
            }
          }
        },
        listenInBackground: false,
      );
    }
  }
}
