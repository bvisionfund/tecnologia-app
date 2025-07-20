// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../app_router.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'user/map_driver_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el perfil completo del usuario
    final appUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: appUserAsync.when(
          data: (appUser) {
            final name = appUser?.nombre ?? '';
            return Text('Bienvenido, ${name.isNotEmpty ? name : 'Usuario'}');
          },
          loading: () => const Text('Bienvenido'),
          error: (_, __) => const Text('Bienvenido'),
        ),
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
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                'Menú',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil del Usuario'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Ver choferes en mapa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.mapDrivers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Ver choferes disponibles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.drivers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Solicitar chofer más cercano'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.requestClosest);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Mis reservas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.myReservation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Reservas Completadas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.completedReservations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.gps_fixed),
              title: const Text('Activar Ubicación'),
              onTap: () async {
                Navigator.pop(context);
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
            ),
          ],
        ),
      ),
      // Mostrar directamente los choferes en mapa como pantalla principal
      body: const MapDriverListScreen(),
    );
  }
}
