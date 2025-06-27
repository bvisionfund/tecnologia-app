import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';
import '../models/availability_slot.dart';
import '../models/reservation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Driver>> watchApprovedDrivers() => _db
      .collection('drivers')
      .where('estadoAprobacion', isEqualTo: 'aprobado')
      .snapshots()
      .asyncMap((snap) async {
        final drivers = <Driver>[];
        for (var doc in snap.docs) {
          final slotsSnap = await doc.reference.collection('availability').get();
          final slots = slotsSnap.docs
              .map((s) => AvailabilitySlot.fromMap(s.data()))
              .toList();
          drivers.add(Driver.fromDoc(doc, slots));
        }
        return drivers;
      });

  Future<Driver> fetchDriverDetail(String driverId) async {
    final doc = await _db.collection('drivers').doc(driverId).get();
    final slotsSnap = await doc.reference.collection('availability').get();
    final slots = slotsSnap.docs
        .map((s) => AvailabilitySlot.fromMap(s.data()))
        .toList();
    return Driver.fromDoc(doc, slots);
  }

  Future<void> createReservation(Reservation res) async {
    final data = {
      'userId': res.userId,
      'driverId': res.driverId,
      'fechaReserva': Timestamp.fromDate(res.fechaReserva),
      'slot': res.slot.toMap(),
      'estadoReserva': res.estado,
    };
    final userResRef = _db
        .collection('users')
        .doc(res.userId)
        .collection('reservations')
        .doc();
    final driverResRef = _db
        .collection('drivers')
        .doc(res.driverId)
        .collection('reservations')
        .doc();
    final batch = _db.batch();
    batch.set(userResRef, data);
    batch.set(driverResRef, data);
    final slotQuery = await _db
        .collection('drivers')
        .doc(res.driverId)
        .collection('availability')
        .where('inicio', isEqualTo: Timestamp.fromDate(res.slot.inicio))
        .limit(1)
        .get();
    if (slotQuery.docs.isNotEmpty) {
      batch.update(slotQuery.docs.first.reference, {'reservado': true});
    }
    await batch.commit();
  }
}