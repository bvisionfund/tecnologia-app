// lib/providers/user_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import 'auth_provider.dart';

/// Provee un Stream de AppUser (perfil completo) basado en el usuario autenticado.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUser = ref.watch(authStateProvider).value;
  if (firebaseUser == null) {
    // Si no hay usuario logueado, no emitimos nada
    return const Stream.empty();
  }

  // Escuchamos el documento en 'users/{uid}' y mappeamos a AppUser
  return FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);
});
