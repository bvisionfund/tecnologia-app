import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final driversProvider = StreamProvider(
    (ref) => ref.watch(firestoreServiceProvider).watchApprovedDrivers());