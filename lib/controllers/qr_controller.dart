import 'package:get/get.dart';

class QRController extends GetxController {
  var scannedData = ''.obs;
  // Fonction pour déterminer l'opérateur à partir du numéro de téléphone
  String determineOperator(String phoneNumber) {
    // Nettoyer le numéro en supprimant les espaces et +237 si présent
    String cleanedNumber = phoneNumber.replaceAll(' ', '').replaceAll(
        '+237', '');

    // Vérifier que le numéro a au moins 9 chiffres (format Camerounais)
    if (cleanedNumber.length != 9 || !cleanedNumber.startsWith('6')) {
      return 'Numéro invalide';
    }

    // Extraire le préfixe
    String prefix = cleanedNumber.substring(0, 3);

    // Liste des préfixes pour MTN Cameroun
    List<String> mtnPrefixes = [
      '650', '651', '652', '653', '654', '680', '681', '682', '683',
      '670', '671', '672', '673', '674', '675', '676', '677', '678', '679',
    ];

    // Liste des préfixes pour Orange Cameroun
    List<String> orangePrefixes = [
      '655', '656', '657', '658', '659',
      '690', '691', '692', '693', '694', '695', '696', '697', '698', '699'
    ];

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
