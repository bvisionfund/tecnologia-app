import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Instancia de FirebaseAuth
final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// Estado de autenticación del usuario
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authProvider).authStateChanges(),
);
