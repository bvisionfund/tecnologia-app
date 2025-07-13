// lib/screens/driver_list_screen.dart

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
