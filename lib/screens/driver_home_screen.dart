import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import '../app_router.dart';
import '../providers/auth_provider.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _requestLocationPermission() async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    }

    void _startLocationUpdates() {
      final uid = ref.read(authStateProvider).value?.uid;
      if (uid != null) {
        LocationService().updateDriverLocation(uid);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Chofer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider).signOut();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.availability),
        child: const Icon(Icons.schedule),
      ),
      body: const Center(
        child: Text(
          'Bienvenido, registra tu disponibilidad usando el botón abajo.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
