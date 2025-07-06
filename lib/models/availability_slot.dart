// lib/models/availability_slot.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilitySlot {
  final DateTime inicio;
  final DateTime fin;
  bool reservado;
  final String docId; // día YYYY-MM-DD

  AvailabilitySlot({
    required this.inicio,
    required this.fin,
    this.reservado = false,
    required this.docId,
  });

  factory AvailabilitySlot.fromMap(Map<String, dynamic> map, String docId) =>
      AvailabilitySlot(
        inicio: (map['inicio'] as Timestamp).toDate(),
        fin: (map['fin'] as Timestamp).toDate(),
        reservado: map['reservado'] as bool,
        docId: docId,
      );

  Map<String, dynamic> toMap() => {
    'inicio': Timestamp.fromDate(inicio),
    'fin': Timestamp.fromDate(fin),
    'reservado': reservado,
  };
}
