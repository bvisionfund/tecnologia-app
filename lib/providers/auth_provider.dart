import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(authProvider).authStateChanges());