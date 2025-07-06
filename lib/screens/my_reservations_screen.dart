// lib/screens/user_reservations_screen.dart

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
      body: reservationsAsync.when(
        data: (reservas) {
          if (reservas.isEmpty) {
            return const Center(child: Text('No tienes reservas'));
          }
          return ListView.builder(
            itemCount: reservas.length,
            itemBuilder: (_, i) {
              final r = reservas[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Reserva:${r.driverId}'),
                  subtitle: Text('Estado: ${r.status.name}'),
                  // podrías navegar a un detail con más info
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
