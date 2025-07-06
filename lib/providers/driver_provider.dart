import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/driver.dart';
import '../services/firestore_service.dart';

/// Proveedor de la instancia de FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

/// Provider para obtener todos los choferes aprobados
final approvedDriversProvider = StreamProvider<List<Driver>>(
  (ref) => ref.watch(firestoreServiceProvider).watchApprovedDrivers(),
);

/// Provider para obtener solo choferes que tengan al menos una franja disponible
final availableDriversProvider = StreamProvider<List<Driver>>(
  (ref) => ref.watch(firestoreServiceProvider).watchAvailableDrivers(),
);

/// Provider para traer choferes pendientes de aprobación
final pendingDriversProvider = StreamProvider<List<Driver>>(
  (ref) => ref.watch(firestoreServiceProvider).watchPendingDrivers(),
);

/// Proveedor para obtener el detalle de un chofer específico
final driverDetailProvider = FutureProvider.family<Driver, String>(
  (ref, driverId) =>
      ref.watch(firestoreServiceProvider).fetchDriverDetail(driverId),
);
