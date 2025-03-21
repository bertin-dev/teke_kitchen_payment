import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:vibration/vibration.dart';
import '../controllers/client_controller.dart';
import '../themes/app_color.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final ClientController clientController = Get.find<ClientController>();
  QRViewController? controller;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
          child: Text('Client - Scanner QR Code',
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
      body: Stack(
        children: [
          QRView(
            key: GlobalKey(debugLabel: "QR Scanner"),
            overlay: QrScannerOverlayShape(
              borderColor: AppColor.primary, // Couleur personnalisée des bordures
              borderRadius: 10, // Radius de la bordure
              borderLength: 30, // Longueur des bordures
              borderWidth: 10, // Largeur des bordures
              cutOutSize: 250, // Taille de la zone de scan
            ),
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  "Informations Scannées",
                  "Numéro : ${clientController.marchandNumber.value}\n"
                      "Montant : ${clientController.amount.value}\n"
                      "Opérateur : ${clientController.operatorName.value}",
                  backgroundColor: Colors.green,
                  colorText: AppColor.white
                );
              },
              child: const Text("Voir les informations"),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController qrController) {
    this.controller = qrController;
    qrController.scannedDataStream.listen((scanData) async {
      //Get.snackbar("QR Scanned", scanData.code!);

      if (!isProcessing) { // S'assurer que la fonction n'est appelée qu'une seule fois
        // Vibration du téléphone pour signaler que le scan est réussi
        if (await Vibration.hasVibrator() == true) {
          Vibration.vibrate();
        } else if(await Vibration.hasAmplitudeControl() == true) {
          Vibration.vibrate(amplitude: 128);
        } else {
          Get.snackbar('Erreur', 'Votre appareil ne supporte pas la vibration.', backgroundColor: Colors.red,);
        }
        isProcessing = true;  // Marquer comme en cours de traitement
        String scannedCode = scanData.code!;
        //this.controller.scannedData.value = scannedCode;
        //qrController.pauseCamera();
        clientController.processQRCode(scannedCode ?? '');

        Future.delayed(Duration(seconds: 4), () {
          isProcessing = false;
        });
      }
    });
  }
}