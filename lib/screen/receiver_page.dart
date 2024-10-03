import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:teke_kitchen_payments/themes/app_color.dart';
import '../controllers/history_controller.dart';
import '../controllers/qr_controller.dart';

class ReceiverPage extends StatefulWidget {
  const ReceiverPage({super.key});

  @override
  State<ReceiverPage> createState() => _ReceiverPageState();
}

class _ReceiverPageState extends State<ReceiverPage> {
  final HistoryController controller = Get.find<HistoryController>();
  double _initialBrightness = 0.5; // Luminosité par défaut (peut être changée)

  @override
  void initState() {
    super.initState();
    _setMaxBrightness(); // Augmente la luminosité au maximum quand la page est ouverte
  }

  @override
  void dispose() {
    _restoreBrightness(); // Restaure la luminosité normale quand la page est fermée
    super.dispose();
  }

  // Fonction pour augmenter la luminosité au maximum
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

  @override
  Widget build(BuildContext context) {
    // Changez la couleur de la barre d'état
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor, // Couleur de la barre d'état
      statusBarIconBrightness: Brightness.light, // Couleur des icônes de la barre d'état
    ));

    return Scaffold(
      //backgroundColor: AppColor.primary,
      appBar: AppBar(title: Padding(
        padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
        child: Text('Recevoir Paiements',
          style: TextStyle(color: AppColor.primary),),
      ),
        backgroundColor: AppColor.secondaryColor,
        iconTheme: IconThemeData(color: AppColor.primary), // Change la couleur des icônes
      ),
      body: Center(
        child: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(controller.primaryNumber.value.isEmpty && controller.secondaryNumber.value.isEmpty && controller.amountFcfa.value.isEmpty)...{
              Center(
                child: Text("Veuillez renseigner vos numéros de téléphone\n et le montant à recevoir pour générer votre QR code"),
              )
            } else...{
              QrImageView(
                data: '${controller.primaryNumber.value}/${controller.secondaryNumber.value}/${controller.amountFcfa.value}',
                size: 250,
                version: QrVersions.auto,
                embeddedImage: AssetImage('assets/images/icon.jpg'), // Assurez-vous que le logo est bien là
              ),
              SizedBox(height: 20),
              Text(
                'SIM 1: ${controller.primaryNumber.value}\nSIM 2: ${controller.secondaryNumber.value}\nMontant à recevoir: ${controller.amountFcfa.value} Fcfa',
                textAlign: TextAlign.center,
              ),
            },
          ],
        )),
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
    String amount = controller.amountFcfa.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Entrer vos informations')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                primaryNumber = value;
              },
              decoration: InputDecoration(hintText: 'Principal'),
              controller: TextEditingController(text: primaryNumber),
            ),
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                secondaryNumber = value;
              },
              decoration: InputDecoration(hintText: 'Secondaire'),
              controller: TextEditingController(text: secondaryNumber),
            ),
            TextField(
              controller: TextEditingController(text: amount),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                amount = value;
              },
              decoration: InputDecoration(hintText: 'Entrez le montant'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              controller.saveNumbers(primaryNumber, secondaryNumber, amount);
              Get.back();
            },
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }
}