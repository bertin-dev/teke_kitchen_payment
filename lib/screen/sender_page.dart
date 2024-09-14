import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../controllers/history_controller.dart';
import '../controllers/qr_controller.dart';
import '../themes/app_color.dart';

class SenderPage extends StatefulWidget {
  @override
  _SenderPageState createState() => _SenderPageState();
}

class _SenderPageState extends State<SenderPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final QRController qrController = Get.put(QRController());
  final HistoryController historyController = Get.find<HistoryController>();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    // Changez la couleur de la barre d'état
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor, // Couleur de la barre d'état
      statusBarIconBrightness: Brightness.light, // Couleur des icônes de la barre d'état
    ));
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
          child: Text('Effectuer paiements',
            style: TextStyle(color: AppColor.primary),),
        ),
        backgroundColor: AppColor.secondaryColor,
        iconTheme: IconThemeData(color: AppColor.primary), //
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleFlash();
            },
          ),
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: () async {
              await controller?.flipCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: AppColor.primary, // Couleur personnalisée des bordures
                borderRadius: 10, // Radius de la bordure
                borderLength: 30, // Longueur des bordures
                borderWidth: 10, // Largeur des bordures
                cutOutSize: 250, // Taille de la zone de scan
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: AppColor.primary,
              child: Center(
                child: Obx(() {
                  return Text(
                    qrController.scannedData.value.isEmpty
                        ? 'Scanner QR Code Teke Kitchen'
                        : 'Scanné: ${qrController.scannedData.value}',
                    style: TextStyle(fontSize: 18),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }


  void _onQRViewCreated(QRViewController qrController) {
    this.controller = qrController;
    qrController.scannedDataStream.listen((scanData) {
      String scannedCode = scanData.code!;
      this.qrController.scannedData.value = scannedCode;

      // Diviser le code scanné pour obtenir les numéros de téléphone
      if (scannedCode.contains('/')) {
        List<String> scannedNumbers = scannedCode.split('/');
        String primaryScanned = scannedNumbers[0];
        String secondaryScanned = scannedNumbers[1];

        _checkMatchingOperator(primaryScanned, secondaryScanned);
      }
    });
  }

  void _checkMatchingOperator(String primaryScanned, String secondaryScanned) {
    String currentUserPrimaryNumber = historyController.primaryNumber.value;

    String operator1 = qrController.determineOperator(primaryScanned);
    String operator2 = qrController.determineOperator(secondaryScanned);
    String userOperator = qrController.determineOperator(currentUserPrimaryNumber);

    if (userOperator == operator1 || userOperator == operator2) {
      String matchingNumber = (userOperator == operator1) ? primaryScanned : secondaryScanned;
      _showAmountDialog(matchingNumber);
    } else {
      Get.snackbar("Opérateur non trouvé", "Aucun opérateur ne correspond.");
    }
  }


  void _showAmountDialog(String matchingNumber) {
    TextEditingController amountController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Insérez le montant'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Entrez le montant'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              String amount = amountController.text.trim();
              if (amount.isNotEmpty) {
                _sendUSSDRequest(matchingNumber, amount);
                Get.back(); // Fermer la boîte de dialogue
              }
            },
            child: Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendUSSDRequest(String matchingNumber, String amount) async {
    String currentUserPrimaryNumber = historyController.primaryNumber.value;
    String userOperator = qrController.determineOperator(currentUserPrimaryNumber);
    String ussdCode;

    if (userOperator == "orange") {
      ussdCode = "#150*1*1*$matchingNumber*$amount#";
    } else {
      ussdCode = "*126*1*1*$matchingNumber*$amount#";
    }
    String ussdCode2 = Uri.encodeComponent(ussdCode);

    // Demander la permission d'appel
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      // Lancer la requête USSD en arrière-plan
      final intent = AndroidIntent(
        action: 'android.intent.action.CALL',
        data: 'tel:$ussdCode',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();

      // Ajouter l'opération à l'historique
      historyController.addToHistory("Envoyé $amount à $matchingNumber via USSD ($ussdCode2) - Réponse: succès");
      Get.snackbar("USSD Request", "Envoi de $ussdCode2");
    } else {
      // Gérer le cas où la permission est refusée
      Get.snackbar('Permission refusée', 'L\'application n\'a pas la permission de passer des appels.');
    }


  }



  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
