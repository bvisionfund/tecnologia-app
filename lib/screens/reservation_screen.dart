import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation.dart';
import '../models/availability_slot.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../app_router.dart';

class ReservationScreen extends ConsumerWidget {
  final String driverId;
  final AvailabilitySlot slot;
  const ReservationScreen({required this.driverId, required this.slot, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value!;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${slot.inicio} - ${slot.fin}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final res = Reservation(
                  id: '',
                  userId: user.uid,
                  driverId: driverId,
                  fechaReserva: DateTime.now(),
                  slot: slot,
                  estado: 'pendiente',
                );
                await ref.read(createReservationProvider(res).future);
                Navigator.popUntil(context, ModalRoute.withName(Routes.home));
              },
              child: const Text('Reservar'),
            ),
          ],
        ),
      ),
    );
  }
}