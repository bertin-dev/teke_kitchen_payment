import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';

class HistoryPage extends StatelessWidget {
  final HistoryController historyController = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: Obx(() {
        return ListView.builder(
          itemCount: historyController.history.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(historyController.history[index]),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.defaultDialog(
            title: 'Add Phone Number',
            content: TextField(
              controller: historyController.phoneController,
              decoration: InputDecoration(hintText: 'Enter phone number'),
            ),
            textConfirm: 'Save',
            onConfirm: () {
              historyController.savePhoneNumber();
              Get.back();
            },
          );
        },
      ),
    );
  }
}
