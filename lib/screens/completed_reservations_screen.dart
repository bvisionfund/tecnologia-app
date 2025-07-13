// lib/screens/completed_reservations_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../models/reservation.dart';
import '../providers/auth_provider.dart';

class CompletedReservationsScreen extends ConsumerWidget {
  static const routeName = Routes.completedReservations;
  const CompletedReservationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('No estás autenticado')));
    }

    final stream = FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: ReservationStatus.completed.name)
        .orderBy('pickupTime', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Reservas Completadas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: \${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No tienes reservas completadas.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final r = Reservation.fromDoc(docs[i]);
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(r.driverId)
                    .get(),
                builder: (context, driverSnap) {
                  String driverName = 'Cargando...';
                  if (driverSnap.connectionState == ConnectionState.done &&
                      driverSnap.hasData &&
                      driverSnap.data!.data() != null) {
                    final data =
                        driverSnap.data!.data() as Map<String, dynamic>;
                    driverName = data['nombre'] as String? ?? 'Sin nombre';
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text('Chofer: $driverName'),
                      subtitle: Text(
                        '${r.pickupTime.toLocal()} → ${r.dropoffAddress ?? 'Sin destino'}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.rateDriver,
                            arguments: r,
                          );
                        },
                        child: const Text('Calificar chofer'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
