import 'package:get/get.dart';

class MarchandController extends GetxController {
  var amount = ''.obs;

  void addDigit(String digit) {
    amount.value += digit;
  }

  void clearAmount() {
    amount.value = '';
  }

  void deleteLastDigit() {
    if (amount.value.isNotEmpty) {
      amount.value = amount.value.substring(0, amount.value.length - 1);
    }
  }

  void validateAmount() {
    if (amount.value.isNotEmpty) {
      Get.toNamed('/operator', arguments: amount.value);
    }
  }
}