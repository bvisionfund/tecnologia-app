import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_card.dart';
import '../app_router.dart';

class DriverListScreen extends ConsumerWidget {
  const DriverListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(driversProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Choferes Disponibles')),
      body: driversAsync.when(
        data: (drivers) => ListView(
          children: drivers.map((d) => DriverCard(
                driver: d,
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.driverDetail,
                  arguments: d.id,
                ),
              )).toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}