import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reservation.dart';
import '../services/firestore_service.dart';

final reservationServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
final firestoreServiceProvider = Provider((_) => FirestoreService());

/// Crea una nueva reserva y devuelve cuando termine
final createReservationProvider = FutureProvider.family<void, Reservation>(
  (ref, res) => ref.read(reservationServiceProvider).createReservation(res),
);

/// Lista de reservas para un usuario dado
final userReservationsProvider =
    StreamProvider.family<List<Reservation>, String>((ref, userId) {
      return ref.watch(firestoreServiceProvider).watchUserReservations(userId);
    });
