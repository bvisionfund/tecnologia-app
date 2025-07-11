import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tecnologia_app/providers/auth_provider.dart';

import '../models/reservation.dart';
import '../services/firestore_service.dart';

final reservationServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
final firestoreServiceProvider = Provider((_) => FirestoreService());

/// Crea una nueva reserva y devuelve cuando termine
final createReservationProvider = FutureProvider.family<void, Reservation>((
  ref,
  res,
) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('reservations').add(res.toMap());
});

/// Lista de reservas para un usuario dado
final userReservationsProvider =
    StreamProvider.family<List<Reservation>, String>((ref, userId) {
      return ref.watch(firestoreServiceProvider).watchUserReservations(userId);
    });

/// Lista de reservas para un conductor dado
final myReservationsProvider = StreamProvider<List<Reservation>>((ref) {
  final user = ref.watch(authStateProvider).value!;
  return ref
      .watch(firestoreServiceProvider)
      .watchReservationsByClient(user.uid);
});
