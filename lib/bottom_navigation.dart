import 'package:flutter/material.dart';

import 'data/models/menus.dart';

class HomeBottomNavigation {

  static final Menus receive = Menus(
    'Receive',
    const Icon(Icons.route, size: 32),
    Colors.blue,
    const Icon(Icons.route, size: 32),
  );
  static final Menus sender = Menus(
    'Sender',
    const Icon(Icons.warehouse),
    Colors.blue,
    const Icon(Icons.warehouse),
  );
  static final Menus historique = Menus(
    'historique',
    const Icon(Icons.supervised_user_circle, size: 32),
    Colors.blue,
    const Icon(Icons.supervised_user_circle, size: 32),
  );
  static final List<Menus> menus = <Menus>[
    receive,
    sender,
    historique,
  ];
}
