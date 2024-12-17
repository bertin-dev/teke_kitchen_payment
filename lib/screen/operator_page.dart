import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/operator_controller.dart';
import '../themes/app_color.dart';

class OperatorPage extends StatelessWidget {
  final OperatorController controller = Get.put(OperatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0), // Ajout d'un padding à gauche
          child: Text('Choisir un opérateur',
            style: TextStyle(color: AppColor.primary),),
        ),
        backgroundColor: AppColor.secondaryColor,
        iconTheme: IconThemeData(color: AppColor.primary), //
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildOperatorCard(
            context,
            label: "Orange Money",
            logo: 'assets/images/om.png'
          ),
          const SizedBox(height: 20),
          _buildOperatorCard(
            context,
            label: "MTN Mobile Money",
            logo: 'assets/images/mtn.png'
          ),
          const Spacer(),
          Obx(
                () =>  Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 2),
                  child: ElevatedButton(
                    onPressed: controller.proceed,
                    child: Text(
                      "Suivant (${controller.selectedOperator.value.isEmpty ? "Aucun" : controller.selectedOperator.value})",
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.secondaryColor,
                        foregroundColor: AppColor.white, // foreground
                        textStyle: TextStyle(
                            fontSize: 20,
                            color: AppColor.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOperatorCard(BuildContext context,
      {required String label,
        required String logo}) {
    return GestureDetector(
      onTap: () {
        controller.setOperator(label);
        controller.showMarchandNumberDialog(context, label);
        controller.setPhoneNumber;
      },
      child: Card(
        elevation: 4,
        child: ListTile(
          leading: Image.asset(logo, width: 40, height: 40,),
          title: Text(label, style: TextStyle(fontSize: 18)),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
