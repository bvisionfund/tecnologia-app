import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reservation.dart';
import '../providers/auth_provider.dart';

class DriverReservationsScreen extends ConsumerWidget {
  const DriverReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = user.uid;
    final stream = FirebaseFirestore.instance
        .collection('reservations')
        .where('driverId', isEqualTo: uid)
        .orderBy('pickupTime', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Reservas recibidas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes reservas aún.'));
          }

          final reservas = snapshot.data!.docs.map((doc) {
            try {
              final r = Reservation.fromDoc(doc);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(r.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Cargando cliente...'));
                  }

                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;

                  final name = userData != null && userData['nombre'] != null
                      ? userData['nombre'] as String
                      : 'Sin nombre';
                  // pon dos botones para aceptar o rechazar la reserva

                  return ListTile(
                    title: Text('Cliente: $name'),
                    subtitle: Text('Fecha: ${r.pickupTime.toLocal()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //  Text(r.status.name),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('reservations')
                                .doc(r.id)
                                .update({'status': 'accepted'});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('reservations')
                                .doc(r.id)
                                .update({'status': 'rejected'});
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            } catch (e) {
              print('Error al convertir reserva: $e');
              return const ListTile(title: Text('Error al cargar reserva'));
            }
          }).toList();

          return ListView(children: reservas);
        },
      ),
    );
  }
}
