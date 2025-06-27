import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/driver_provider.dart';
import '../services/firestore_service.dart';
import '../models/driver.dart';
import '../widgets/reservation_slot_picker.dart';
import '../app_router.dart';

class DriverDetailScreen extends ConsumerWidget {
  final String driverId;
  const DriverDetailScreen({required this.driverId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svc = ref.watch(firestoreServiceProvider);
    return FutureBuilder<Driver>(
      future: svc.fetchDriverDetail(driverId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final driver = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text('${driver.nombre} ${driver.apellido}')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ReservationSlotPicker(
              availability: driver.availability,
              onSlotSelected: (slot) {
                Navigator.pushNamed(
                  context,
                  Routes.reservation,
                  arguments: {'driverId': driver.id, 'slot': slot},
                );
              },
            ),
          ),
        );
      },
    );
  }
}