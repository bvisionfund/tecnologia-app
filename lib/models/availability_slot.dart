import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilitySlot {
  final DateTime inicio;
  final DateTime fin;
  bool reservado;

  AvailabilitySlot({
    required this.inicio,
    required this.fin,
    this.reservado = false,
  });

  factory AvailabilitySlot.fromMap(Map<String, dynamic> map) =>
      AvailabilitySlot(
        inicio: (map['inicio'] as Timestamp).toDate(),
        fin: (map['fin'] as Timestamp).toDate(),
        reservado: map['reservado'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'inicio': Timestamp.fromDate(inicio),
        'fin': Timestamp.fromDate(fin),
        'reservado': reservado,
      };
}