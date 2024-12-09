import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

import '../controllers/client_controller.dart';
import '../controllers/history_controller.dart';
import '../themes/app_color.dart';


class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final arguments = Get.arguments;
  Logger logger = Logger();
  bool isProcessing = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  double _initialBrightness = 0.5; // Luminosité par défaut (peut être changée)
  final ClientController clientController = Get.find<ClientController>();
  final HistoryController historyController = Get.put(HistoryController());


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
    _setMaxBrightness(); // Augmente la luminosité au maximum quand la page est ouverte
    Wakelock.enable(); // Garder l'écran allumé
  }

  @override
  Widget build(BuildContext context) {
    // Changez la couleur de la barre d'état
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor, // Couleur de la barre d'état
      statusBarIconBrightness: Brightness.light, // Couleur des icônes de la barre d'état
    ));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
            child: Text('Paiements',
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
          bottom: const TabBar(
            indicatorColor: AppColor.primary,
            labelColor: AppColor.white,
            tabs: [
              Tab(text: "Générer"),
              Tab(text: "Scanner"),
              Tab(text: "Historique"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data:  "Amount: ${arguments['amount']}, Operator: ${arguments['operator']}, Phone: ${arguments['phone']}",
                  size: 250,
                  version: QrVersions.auto,
                  embeddedImage: AssetImage('assets/images/icon.jpg'), // Assurez-vous que le logo est bien là
                ),
                SizedBox(height: 20),
                Text(
                  'Code Marchand : ${arguments['phone']}\nMontant : ${arguments['amount']} Fcfa\nType Opération: ${arguments['operator']}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
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
                      child: Text('Teke Kitchen',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Obx(() {
              if (historyController.isLoading.value) {
                return _buildShimmer();  // Afficher le Shimmer pendant le chargement
              }
              if (historyController.historyList.isEmpty) {
                return Center(
                  child: Text('Aucune transaction trouvée.'),
                );
              }

              return ListView.builder(
                itemCount: historyController.historyList.length,
                itemBuilder: (context, index) {
                  final item = historyController.historyList[index];
                  return Dismissible(
                    key: ValueKey(item['id']),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      //historyController.removeTransaction(transaction);
                      historyController.deleteFromHistory(item['id']);
                      Get.snackbar('Supprimé', 'La transaction a été supprimée',
                          backgroundColor: Colors.green, colorText: Colors.white);
                    },
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: _buildIcon(item['isSuccess'] == 1),
                        title: Text(
                          item['operator'].toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['description']),
                            Text(historyController.formatTimestamp(item['timestamp']), // Affichage du temps relatif
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Text(
                          item['isSuccess'] == 1 ? 'Réussi' : 'Échoué',
                          style: TextStyle(
                            color: item['isSuccess'] == 1 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            })
          ],
        ),
        /*floatingActionButton: FloatingActionButton(
          backgroundColor: AppColor.secondaryColor,
          //onPressed: () => _showNumberDialog(context),
          onPressed: () {  },
          child: Icon(Icons.add, color: AppColor.primary,),
        ),*/
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _restoreBrightness(); // Restaure la luminosité normale quand la page est fermée
    Wakelock.disable();
    super.dispose();
  }

  Future<void> _setMaxBrightness() async {
    // Sauvegarder la luminosité actuelle
    _initialBrightness = await ScreenBrightness().current;
    // Augmenter la luminosité au maximum
    await ScreenBrightness().setScreenBrightness(1.0);
  }

  // Fonction pour restaurer la luminosité d'origine
  Future<void> _restoreBrightness() async {
    // Restaurer la luminosité à celle d'avant
    await ScreenBrightness().setScreenBrightness(_initialBrightness);
  }


  void _onQRViewCreated(QRViewController qrController) {
    this.controller = qrController;
    qrController.scannedDataStream.listen((scanData) async {
      Get.snackbar("QR Scanned", scanData.code!);

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
        //this.controller.scannedData.value = scannedCode;
        qrController.pauseCamera();
        clientController.processQRCode(scannedCode ?? '');

        Future.delayed(Duration(seconds: 4), () {
          isProcessing = false;
        });

      }
    });
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            title: Container(
              width: double.infinity,
              height: 20.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 14.0,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(bool success) {
    return Icon(
      success ? Icons.check_circle : Icons.error,
      color: success ? Colors.green : Colors.red,
      size: 40,
    );
  }

}
