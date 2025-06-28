import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  final _db = FirebaseFirestore.instance;

  /// Devuelve 'admin', 'driver' o 'user'
  Future<String> detectRole(String uid) async {
    // 1) ¿Es admin?
    final adminDoc = await _db.collection('admins').doc(uid).get();
    if (adminDoc.exists) return 'admin';

    // 2) ¿Es chófer aprobado?
    final drvSnap = await _db.collection('drivers').doc(uid).get();
    if (drvSnap.exists) {
      final estado = drvSnap['estadoAprobacion'] as String;
      if (estado == 'aprobado') return 'driver';
    }

    // 3) Si no, es cliente normal
    return 'user';
  }
}
