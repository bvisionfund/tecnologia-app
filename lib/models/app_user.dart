// lib/models/app_user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String username; // opcional si usas login por usuario
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final Timestamp fechaRegistro;

  AppUser({
    required this.id,
    this.username = '',
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.fechaRegistro,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      username: d['username'] as String? ?? '',
      nombre: d['nombre'] as String,
      apellido: d['apellido'] as String,
      correo: d['correo'] as String,
      telefono: d['telefono'] as String,
      fechaRegistro: d['fechaRegistro'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    if (username.isNotEmpty) 'username': username,
    'nombre': nombre,
    'apellido': apellido,
    'correo': correo,
    'telefono': telefono,
    'fechaRegistro': fechaRegistro,
  };
}
