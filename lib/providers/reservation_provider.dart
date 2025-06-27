import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/reservation.dart';

final reservationServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final createReservationProvider = FutureProvider.family<void, Reservation>(
    (ref, res) => ref.read(reservationServiceProvider).createReservation(res));