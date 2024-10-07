import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';
import '../controllers/history_controller.dart';
import '../controllers/qr_controller.dart';
import '../controllers/sender_controller.dart';
import '../themes/app_color.dart';

class SenderPage extends StatefulWidget {
  @override
  _SenderPageState createState() => _SenderPageState();
}

class _SenderPageState extends State<SenderPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final QRController qrController = Get.put(QRController());
  final SenderController senderController = Get.find<SenderController>();
  Logger logger = Logger();
  bool isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    Wakelock.enable(); // Garder l'écran allumé
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
    qrController.scannedDataStream.listen((scanData) async {

      if (!isProcessing) { // S'assurer que la fonction n'est appelée qu'une seule fois
        // Vibration du téléphone pour signaler que le scan est réussi
        if (await Vibration.hasVibrator() == true) {
          Vibration.vibrate();
        } else if(await Vibration.hasAmplitudeControl() == true) {
          Vibration.vibrate(amplitude: 128);
        } else {
          Get.snackbar('Erreur', 'Votre appareil ne supporte pas la vibration.');
        }
        isProcessing = true;  // Marquer comme en cours de traitement
        String scannedCode = scanData.code!;
        this.qrController.scannedData.value = scannedCode;
        // Vérification si le code QR contient deux numéros
        if (scannedCode.contains('/')) {
          List<String> scannedNumbers = scannedCode.split('/');
          String primaryScanned = scannedNumbers[0]; // primary phone
          String secondaryScanned = scannedNumbers[1]; // secondady phone
          String amount = scannedNumbers[2]; // amount
          _checkMatchingOperator(primaryScanned, secondaryScanned, amount);

      // Remettre le drapeau après traitement
      Future.delayed(Duration(seconds: 4), () {
      isProcessing = false;
      });

        } else {
          Get.snackbar('QR Code invalide', 'Le code QR ne contient pas les numéros attendus.',
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      }
    });
  }

  Future<void> _checkMatchingOperator(String primaryScanned, String secondaryScanned, String amountReceiver) async {
    String currentNumberSender = senderController.primaryNumber.value.isNotEmpty ? senderController.primaryNumber.value : senderController.secondaryNumber.value;
    String userOperatorSender = qrController.determineOperator(currentNumberSender);
    String operatorReceiver1 = qrController.determineOperator(primaryScanned);
    String operatorReceiver2 = qrController.determineOperator(secondaryScanned);

    if (userOperatorSender == operatorReceiver1 || userOperatorSender == operatorReceiver2) {
      String matchingNumber = (userOperatorSender == operatorReceiver1) ? primaryScanned : secondaryScanned;
      //_showAmountDialog(matchingNumber);
      if(amountReceiver != 0){
        // Lancer la requête USSD
        await _sendUSSDRequest(matchingNumber, amountReceiver, userOperatorSender);
      } else{
        Get.snackbar("Montant introuvable", "Veuillez vérifier le montant de la commande",
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } else {
      Get.snackbar("Opérateur non trouvé", "Aucun opérateur ne correspond.",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _sendUSSDRequest(String matchingNumberReceiver, String amountReceiver, String userOperatorSender) async {
    String ussdCode;

    // Générer le code USSD en fonction de l'opérateur
    if (userOperatorSender == "orange") {
      ussdCode = "#150*1*1*$matchingNumberReceiver*$amountReceiver#";
    } else {
      ussdCode = "*126*1*1*$matchingNumberReceiver*$amountReceiver#";
    }

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

        // Ajouter à l'historique
        //senderController.addToHistory("Envoyé $amountReceiver Fcfa à $matchingNumberReceiver via USSD ($ussdCode)");

        // Afficher une notification de succès
        Get.snackbar(
            'Succès',
            'Requête USSD envoyée : $ussdCode',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          duration: Duration(seconds: 10),
        );
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
  }

  @override
  void dispose() {
    controller?.dispose();
    Wakelock.disable(); // Autoriser l'écran à s'éteindre lorsque l'utilisateur quitte la page
    super.dispose();
  }
}

