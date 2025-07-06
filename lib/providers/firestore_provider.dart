import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_service.dart';

/// Proveedor de la instancia única de FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
