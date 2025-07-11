import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../models/availability_slot.dart';
import '../models/reservation.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';

class ReservationScreen extends ConsumerWidget {
  final String driverId;
  final AvailabilitySlot slot;
  const ReservationScreen({
    required this.driverId,
    required this.slot,
    super.key,
  });

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
                  requestTime: DateTime.now(),
                  pickupTime: slot.inicio,
                  pickupAddress: 'Por definir',
                  pickupLocation: const GeoPoint(
                    0.0,
                    0.0,
                  ), // valor temporal o real
                  estimatedFare: 5.0,
                  status: ReservationStatus.pending,
                  paymentStatus: PaymentStatus.pending,
                  slot: slot,
                );
                await ref.read(createReservationProvider(res).future);
                Navigator.pushNamed(context, Routes.myReservation);
              },
              child: const Text('Reservar'),
            ),
          ],
        ),
      ),
    );
  }
}
