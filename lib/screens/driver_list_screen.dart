import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_card.dart';

class DriverListScreen extends ConsumerWidget {
  const DriverListScreen({super.key});

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
          return ListView(
            children: drivers
                .map(
                  (d) => DriverCard(
                    driver: d,
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.driverDetail,
                      arguments: d.id,
                    ),
                  ),
                )
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
