import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/history_controller.dart';
import '../themes/app_color.dart';

class HistoryPage extends StatelessWidget {
  final HistoryController controller = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor, // Couleur de la barre d'état
      statusBarIconBrightness: Brightness.light, // Couleur des icônes de la barre d'état
    ));
    return Scaffold(
      appBar: AppBar(title: Padding(
        padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
        child: Text('Historique',
          style: TextStyle(color: AppColor.primary),),
      ),
        backgroundColor: AppColor.secondaryColor,
        iconTheme: IconThemeData(color: AppColor.primary), // Change la couleur des icônes
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Afficher le Shimmer effect pendant le chargement
          return _buildShimmerEffect();
        } else if (controller.scannedHistory.isEmpty && controller.ussdRequests.isEmpty) {
          // Afficher un message lorsque l'historique est vide
          return Center(child: Text('No history found.'));
        } else {
          // Afficher l'historique une fois que les données sont chargées
          return _buildHistoryList();
        }
      }),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6,  // Simule 6 lignes de chargement
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            title: Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      children: [
        ...controller.scannedHistory.map((code) => ListTile(
          title: Text('Scanned QR: $code'),
        )),
        ...controller.ussdRequests.map((ussd) => ListTile(
          title: Text('USSD Request: $ussd'),
        )),
      ],
    );
  }
}
