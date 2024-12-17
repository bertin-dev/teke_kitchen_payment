import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/marchand_controller.dart';
import '../themes/app_color.dart';

class MarchandHomePage extends StatelessWidget {
  final MarchandController controller = Get.put(MarchandController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
          child: Text('Accueil',
            style: TextStyle(color: AppColor.primary),),
        ),
        backgroundColor: AppColor.secondaryColor,
        iconTheme: IconThemeData(color: AppColor.primary), //
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Montant en FCFA",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0), // Ajustez la taille selon vos besoins
              ),
              style: TextStyle(
                fontSize: 40.0, // Changez la taille de police ici
              ),
              controller: TextEditingController(text: controller.amount.value),
            )),
            SizedBox(height: 20,),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                itemCount: 12,
                itemBuilder: (context, index) {
                  String label;
                  if (index < 9) {
                    label = '${index + 1}';
                  } else if (index == 9) {
                    label = 'C';
                  } else if (index == 10) {
                    label = '0';
                  } else {
                    label = '⌫';
                  }

                  return GestureDetector(
                    onTap: () {
                      if (label == 'C') {
                        controller.clearAmount();
                      } else if (label == '⌫') {
                        controller.deleteLastDigit();
                      } else {
                        controller.addDigit(label);
                      }
                    },
                    child: Card(
                      child: Center(
                        child: Text(label,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: controller.validateAmount,
              child: const Text("Valider"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.secondaryColor,
                  foregroundColor: AppColor.white, // foreground
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  textStyle: TextStyle(
                      fontSize: 20,
                      color: AppColor.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
