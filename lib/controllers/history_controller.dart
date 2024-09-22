import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryController extends GetxController {
  var primaryNumber = ''.obs;
  var secondaryNumber = ''.obs;
  var scannedHistory = <String>[].obs;
  var ussdRequests = <String>[].obs;
  var isLoading = true.obs;  // Ajout d'un état de chargement

  @override
  Future<void> onInit() async {
    super.onInit();
    // Demander la permission d'appel
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    _loadData();
  }

  // Ajouter une opération à l'historique
  Future<void> addToHistory(String operation) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add(operation);
    await prefs.setStringList('history', history);
    this.scannedHistory.assignAll(history);
  }

  Future<void> _loadData() async {
    await _loadNumbers();
    await _loadHistory();
    isLoading.value = false;  // Fin du chargement
  }

  Future<void> _loadNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    primaryNumber.value = prefs.getString('primaryNumber') ?? '';
    secondaryNumber.value = prefs.getString('secondaryNumber') ?? '';
  }

  Future<void> saveNumbers(String primary, String secondary) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    primaryNumber.value = primary;
    secondaryNumber.value = secondary;
    await prefs.setString('primaryNumber', primary);
    await prefs.setString('secondaryNumber', secondary);
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    scannedHistory.value = prefs.getStringList('scannedHistory') ?? [];
    ussdRequests.value = prefs.getStringList('ussdRequests') ?? [];
  }

  Future<void> addScannedCode(String code) async {
    scannedHistory.add(code);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('scannedHistory', scannedHistory);
  }

  Future<void> addUSSDRequest(String request) async {
    ussdRequests.add(request);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ussdRequests', ussdRequests);
  }
}
