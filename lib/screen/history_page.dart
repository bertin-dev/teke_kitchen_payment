import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/history_controller.dart';
import '../themes/app_color.dart';

class HistoryPage extends StatelessWidget {
  final HistoryController historyController = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.secondaryColor, // Couleur de la barre d'état
      statusBarIconBrightness: Brightness.light, // Couleur des icônes de la barre d'état
    ));
    return Scaffold(
      appBar: AppBar(title: Padding(
        padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
        child: Text('Historique des Transactions',
          style: TextStyle(color: AppColor.primary),),
      ),
        backgroundColor: AppColor.secondaryColor,
        iconTheme: IconThemeData(color: AppColor.primary), // Change la couleur des icônes
      ),
      body: Obx(() {
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
      }),
    );
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

