// lib/models/driver.dart

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
  final GeoPoint? currentLocation; // para matching geográfico
  final double rating; // promedio de calificaciones
  final int ratingCount;

  Driver({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.ciudadResidencia,
    required this.valorHora,
    required this.estadoAprobacion,
    this.availability = const [],
    this.currentLocation,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  factory Driver.fromDoc(
    DocumentSnapshot doc, [
    List<AvailabilitySlot>? slots,
  ]) {
    final d = doc.data()! as Map<String, dynamic>;
    return Driver(
      id: doc.id,
      nombre: d['nombre'] as String,
      apellido: d['apellido'] as String,
      ciudadResidencia: d['ciudadResidencia'] as String,
      valorHora: (d['valorHora'] as num).toDouble(),
      estadoAprobacion: d['estadoAprobacion'] as String,
      availability: slots ?? const [],
      currentLocation: d['currentLocation'] as GeoPoint?,
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (d['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'apellido': apellido,
    'ciudadResidencia': ciudadResidencia,
    'valorHora': valorHora,
    'estadoAprobacion': estadoAprobacion,
    if (currentLocation != null) 'currentLocation': currentLocation!,
    'rating': rating,
    'ratingCount': ratingCount,
  };
}
