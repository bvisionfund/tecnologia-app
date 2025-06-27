import 'package:cloud_firestore/cloud_firestore.dart';
import 'availability_slot.dart';

class Driver {
  final String id;
  final String nombre;
  final String apellido;
  final String ciudadResidencia;
  final double valorHora;
  final String estadoAprobacion;
  final List<AvailabilitySlot> availability;

  Driver({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.ciudadResidencia,
    required this.valorHora,
    required this.estadoAprobacion,
    this.availability = const [],
  });

  factory Driver.fromDoc(DocumentSnapshot doc, [List<AvailabilitySlot>? slots]) {
    final data = doc.data() as Map<String, dynamic>;
    return Driver(
      id: doc.id,
      nombre: data['nombre'] as String,
      apellido: data['apellido'] as String,
      ciudadResidencia: data['ciudadResidencia'] as String,
      valorHora: (data['valorHora'] as num).toDouble(),
      estadoAprobacion: data['estadoAprobacion'] as String,
      availability: slots ?? const [],
    );
  }
}