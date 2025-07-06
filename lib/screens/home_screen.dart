import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../app_router.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final user = ref.watch(authStateProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${user?.email ?? ''}'),
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
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.drivers),
              child: const Text('Ver choferes disponibles'),
            ),
          ),
          //cuadro de separación
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, Routes.mapDrivers),
            child: const Text('Ver choferes en mapa'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, Routes.requestClosest),
            child: const Text('Solicitar chofer más cercano'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
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
            child: const Text('Activar ubicación'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: () => Navigator.pushNamed(context, Routes.profile),
            ),
          ],
        ),
      ),
    );
  }
}
