import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../app_router.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _locationUpdated = false;

  @override
  void initState() {
    super.initState();
    _handleLocationPermissionAndUpdate();
  }

  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  Future<void> _handleLocationPermissionAndUpdate() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    await LocationService().updateDriverLocation(user.uid);
    setState(() => _locationUpdated = true);
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'Solicitar Ubicación',
            onPressed: () async {
              final granted = await ensureLocationPermission();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    granted
                        ? 'Permiso de ubicación concedido'
                        : 'Permiso de ubicación no concedido',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.gps_fixed),
            label: const Text('Solicitar Ubicación'),
          ),
          FloatingActionButton.extended(
            heroTag: 'reservas',
            onPressed: () =>
                Navigator.pushNamed(context, Routes.driverReservations),
            icon: const Icon(Icons.assignment),
            label: const Text('Mis Reservas'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'disponibilidad',
            onPressed: () => Navigator.pushNamed(context, Routes.availability),
            icon: const Icon(Icons.schedule),
            label: const Text('Disponibilidad'),
          ),
        ],
      ),
      body: Center(
        child: Text(
          _locationUpdated
              ? 'Ubicación actualizada. Registra tu disponibilidad abajo.'
              : 'Esperando permisos de ubicación...',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
