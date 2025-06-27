import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final Timestamp fechaRegistro;

  AppUser({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.fechaRegistro,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      nombre: data['nombre'] as String,
      apellido: data['apellido'] as String,
      correo: data['correo'] as String,
      telefono: data['telefono'] as String,
      fechaRegistro: data['fechaRegistro'] as Timestamp,
    );
  }
}