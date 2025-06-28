import 'package:cloud_firestore/cloud_firestore.dart';

import 'availability_slot.dart';

class Reservation {
  final String id;
  final String userId;
  final String driverId;
  final DateTime fechaReserva;
  final AvailabilitySlot slot;
  final String estado;

  Reservation({
    required this.id,
    required this.userId,
    required this.driverId,
    required this.fechaReserva,
    required this.slot,
    required this.estado,
  });

  factory Reservation.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      userId: data['userId'],
      driverId: data['driverId'],
      fechaReserva: (data['fechaReserva'] as Timestamp).toDate(),
      slot: AvailabilitySlot.fromMap(data['slot'], data['slotDocId']),
      estado: data['estado'],
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'driverId': driverId,
    'fechaReserva': Timestamp.fromDate(fechaReserva),
    'slot': slot.toMap(),
    'slotDocId': slot.docId,
    'estado': estado,
  };
}
