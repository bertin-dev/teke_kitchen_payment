import 'package:get/get.dart';

class QRController extends GetxController {
  var scannedData = ''.obs;

  // Fonction pour déterminer l'opérateur à partir du numéro de téléphone
  String determineOperator(String phoneNumber) {
    // Nettoyer le numéro en supprimant les espaces et +237 si présent
    String cleanedNumber = phoneNumber.replaceAll(' ', '').replaceAll('+237', '');

    if (cleanedNumber.length != 9 || !cleanedNumber.startsWith('6')) {
      return 'Numéro invalide';
    }

    String prefix = cleanedNumber.substring(0, 3);

    // Préfixes pour MTN et Orange Cameroun
    List<String> mtnPrefixes = ['650', '651', '652', '653', '654', '680', '681', '682', '683', '684', '670', '671', '672', '673', '674', '675', '676', '677', '678', '679'];
    List<String> orangePrefixes = ['655', '656', '657', '658', '659', '690', '691', '692', '693', '694', '695', '696', '697', '698', '699', '685', '686', '687', '688', '689'];

    // Déterminer l'opérateur
    if (mtnPrefixes.contains(prefix)) {
      return 'mtn';
    } else if (orangePrefixes.contains(prefix)) {
      return 'orange';
    } else {
      return 'Opérateur inconnu';
    }
  }
}

