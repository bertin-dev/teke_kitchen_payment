import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/timeago.dart' as timeago_fr; // Ajoute cet import pour les locales


import '../services/database_helper.dart';


class HistoryController extends GetxController {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  var historyList = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Demander la permission d'appel
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }
    timeago_fr.setLocaleMessages('fr', timeago_fr.FrMessages()); // Enregistre les messages en français
    loadHistory();  // Charger l'historique au démarrage
  }

  // Méthode pour charger l'historique depuis la base de données
  Future<void> loadHistory() async {
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 5)); // Simulate loading time
    isLoading.value = false;
    historyList.value = await dbHelper.getHistory();
  }

  // Méthode pour ajouter une transaction dans l'historique
  Future<void> addToHistory(String operator, String description, String timeTransaction,  bool isSuccess) async {
    await dbHelper.insertHistory(operator, description, timeTransaction, isSuccess);
    await loadHistory();  // Recharger l'historique après ajout
  }

  // Méthode pour supprimer un élément de l'historique
  Future<void> deleteFromHistory(int id) async {
    await dbHelper.deleteHistory(id);
    await loadHistory();  // Recharger l'historique après suppression
  }

  String formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return timeago.format(dateTime, locale: 'fr'); // 'fr' pour le formatage en français
  }
}
