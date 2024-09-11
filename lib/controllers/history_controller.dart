import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryController extends GetxController {
  var history = <String>[].obs;
  TextEditingController phoneController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void savePhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    String phoneNumber = phoneController.text;
    history.add(phoneNumber);
    await prefs.setStringList('history', history);
    phoneController.clear();
  }

  void loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    history.value = prefs.getStringList('history') ?? [];
  }
}
