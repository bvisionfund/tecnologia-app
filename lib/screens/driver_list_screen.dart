// lib/screens/driver_list_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_card.dart';

class DriverListScreen extends ConsumerWidget {
  // static const routeName = Routes.driverList;
  const DriverListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(availableDriversProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Choferes Disponibles')),
      body: driversAsync.when(
        data: (drivers) {
          if (drivers.isEmpty) {
            return const Center(child: Text('No hay choferes disponibles'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final d = drivers[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DriverCard(
                    driver: d,
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.driverDetail,
                      arguments: d.id,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Estrella de calificación promedio
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('ratings')
                        .where('rateeId', isEqualTo: d.id)
                        .get(),
                    builder: (context, ratingSnap) {
                      if (ratingSnap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final docs = ratingSnap.data?.docs ?? [];
                      double avg = 0;
                      if (docs.isNotEmpty) {
                        final total = docs.fold<double>(
                          0,
                          (sum, doc) => sum + (doc['rating'] as num).toDouble(),
                        );
                        avg = total / docs.length;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            return Icon(
                              i < avg.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.star),
                    label: const Text('Ver calificaciones'),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.driverRatings,
                        arguments: d.id,
                      );
                    },
                  ),
                  const Divider(thickness: 1),
                ],
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
