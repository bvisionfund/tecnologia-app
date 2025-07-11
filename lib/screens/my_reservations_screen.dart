import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';

class UserReservationsScreen extends ConsumerWidget {
  const UserReservationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('No estás autenticado')));
    }

    final reservationsAsync = ref.watch(userReservationsProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reservas')),
      body: ref
          .watch(myReservationsProvider)
          .when(
            data: (reservas) => ListView(
              children: reservas.map((r) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('drivers')
                      .doc(r.driverId)
                      .get(),
                  builder: (context, snapDriver) {
                    String driverName;
                    if (snapDriver.connectionState == ConnectionState.waiting) {
                      driverName = 'Cargando chofer…';
                    } else if (snapDriver.hasError ||
                        !snapDriver.hasData ||
                        snapDriver.data!.data() == null) {
                      driverName = 'Nombre no disponible';
                    } else {
                      final data =
                          snapDriver.data!.data()! as Map<String, dynamic>;
                      driverName = data['nombre'] as String? ?? 'Sin nombre';
                    }

                    return ListTile(
                      title: Text('Chofer: $driverName'),
                      subtitle: Text(
                        'Hora: ${r.slot?.inicio} - ${r.slot?.fin}',
                      ),
                      trailing: Text(
                        r.status == 'pending'
                            ? 'Pendiente'
                            : r.status == 'accepted'
                            ? 'Aceptada'
                            : 'Rechazada',
                        style: TextStyle(
                          color: r.status == 'accepted'
                              ? Colors.green
                              : r.status == 'rejected'
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
    );
  }
}
