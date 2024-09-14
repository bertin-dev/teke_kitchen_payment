import 'package:flutter/material.dart';
import 'package:teke_kitchen_payments/screen/receiver_page.dart';
import 'package:teke_kitchen_payments/screen/sender_page.dart';
import 'package:teke_kitchen_payments/themes/app_color.dart';

import 'history_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BottomNavigationBarExample(),
      ),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  @override
  _BottomNavigationBarExampleState createState() => _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [ReceiverPage(), SenderPage(), HistoryPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColor.secondaryColor,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Recevoir'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Payer'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
