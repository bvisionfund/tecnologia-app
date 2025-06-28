import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/availability_slot.dart';
import '../models/driver.dart';
import '../models/reservation.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Fetch approved drivers with availability
  Stream<List<Driver>> watchAvailableDrivers() => _db
      .collection('drivers')
      .where('estadoAprobacion', isEqualTo: 'aprobado')
      .snapshots()
      .asyncMap((snap) async {
        final drivers = <Driver>[];
        for (var doc in snap.docs) {
          final slotsSnap = await doc.reference
              .collection('availability')
              .where('slots.reservado', isEqualTo: false)
              .get();
          final slots = <AvailabilitySlot>[];
          for (var slotDoc in slotsSnap.docs) {
            for (var m in slotDoc['slots']) {
              slots.add(AvailabilitySlot.fromMap(m, slotDoc.id));
            }
          }
          drivers.add(Driver.fromDoc(doc, slots));
        }
        return drivers;
      });

  /// Obtiene el detalle de un conductor con sus franjas de disponibilidad
  Future<Driver> fetchDriverDetail(String driverId) async {
    final docSnap = await _db.collection('drivers').doc(driverId).get();
    // Obtener franjas disponibles
    final slotsSnap = await docSnap.reference.collection('availability').get();
    final slots = <AvailabilitySlot>[];
    for (var dayDoc in slotsSnap.docs) {
      final List<dynamic> rawSlots = dayDoc['slots'];
      for (var raw in rawSlots) {
        slots.add(
          AvailabilitySlot.fromMap(raw as Map<String, dynamic>, dayDoc.id),
        );
      }
    }
    // Retornar instancia con slots cargadas
    return Driver.fromDoc(docSnap, slots);
  }

  Stream<List<Driver>> watchApprovedDrivers() {
    return _db
        .collection('drivers')
        .where('estadoAprobacion', isEqualTo: 'aprobado')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Driver.fromDoc(doc, [])).toList(),
        );
  }

  // Add availability slot for driver
  Future<void> addAvailabilitySlot(
    String driverId,
    AvailabilitySlot slot,
  ) async {
    final collection = _db
        .collection('drivers')
        .doc(driverId)
        .collection('availability');
    // Use a fixed doc per day
    final dayId = slot.inicio.toIso8601String().split('T').first;
    final docRef = collection.doc(dayId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (snap.exists) {
        tx.update(docRef, {
          'slots': FieldValue.arrayUnion([slot.toMap()]),
        });
      } else {
        tx.set(docRef, {
          'date': slot.inicio,
          'slots': [slot.toMap()],
        });
      }
    });
  }

  Future<void> createReservation(Reservation res) async {
    final data = res.toMap();
    // similar batch code as antes...
  }

  /// Stream de choferes con estado 'pendiente'
  Stream<List<Driver>> watchPendingDrivers() {
    return _db
        .collection('drivers')
        .where('estadoAprobacion', isEqualTo: 'pendiente')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Driver.fromDoc(doc, [])).toList(),
        );
  }

  /// Aprueba o rechaza un chofer cambiando su estado en Firestore
  Future<void> updateDriverApproval(String driverId, bool approved) {
    return _db.collection('drivers').doc(driverId).update({
      'estadoAprobacion': approved ? 'aprobado' : 'rechazado',
    });
  }
}
