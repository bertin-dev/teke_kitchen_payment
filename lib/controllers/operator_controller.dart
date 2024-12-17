import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OperatorController extends GetxController {
  var selectedOperator = ''.obs;
  var marchandNumber = ''.obs;

  void setOperator(String operator) {
    selectedOperator.value = operator;
  }

  void setPhoneNumber(String number) {
    marchandNumber.value = number;
  }

  bool validateMarchandNumber(String number) {
    // Validation basée sur l'opérateur
    if (selectedOperator.value.toLowerCase() == 'orange money' && number.length != 7) {
      return false;
    } else if (selectedOperator.value.toLowerCase() == 'mtn mobile money' && number.length != 6) {
      return false;
    }
    return true;
  }


  void showMarchandNumberDialog(BuildContext context, String label) {
    TextEditingController marchandController = TextEditingController(text: label.toLowerCase() == "orange money" ? "0746656" : "781064");

    Get.defaultDialog(
      title: "Saisir le numéro marchand",
      content: Column(
        children: [
          TextField(
            controller: marchandController,
            readOnly: true,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Numéro Marchand",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          String enteredPhone = marchandController.text;
          if (validateMarchandNumber(enteredPhone)) {
            marchandNumber.value = enteredPhone;
            Get.back();
            Get.snackbar(
              "Succès",
              "Numéro Marchand",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "Erreur",
              "Numéro marchand non conforme à ${selectedOperator.value}",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        child: const Text("Valider"),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text("Annuler"),
      ),
    );
  }

  void proceed() {
    //print("-----------${Get.arguments}-----${selectedOperator.value}----${phoneNumber.value}");
    if (selectedOperator.value.isNotEmpty && marchandNumber.value.isNotEmpty) {
      Get.toNamed('/qr', arguments: {
        "amount": Get.arguments,
        "operator": selectedOperator.value,
        "phone": marchandNumber.value,
      });
    } else {
      Get.snackbar(
        "Erreur",
        "Veuillez sélectionner un opérateur",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
