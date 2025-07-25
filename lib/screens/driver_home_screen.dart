// lib/screens/driver_home_screen.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../app_router.dart';
import '../models/reservation.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../widgets/reservation_detail_sheet.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _locationUpdated = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _handleLocationPermissionAndUpdate();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
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
      if (permission == LocationPermission.denied) return false;
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

    final granted = await ensureLocationPermission();
    if (!granted) return;

    await LocationService().updateDriverLocation(user.uid);
    setState(() => _locationUpdated = true);

    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await LocationService().updateDriverLocation(user.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = user.uid;

    final acceptedStream = FirebaseFirestore.instance
        .collection('reservations')
        .where('driverId', isEqualTo: uid)
        .where('status', isEqualTo: ReservationStatus.accepted.name)
        .orderBy('pickupTime', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Conductor'),
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
                'Menú del Conductor',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.gps_fixed),
              title: const Text('Solicitar Ubicación'),
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
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Mis Reservas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.driverReservations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Disponibilidad'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.availability);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: acceptedStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No tienes reservas aceptadas.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final r = Reservation.fromDoc(docs[i]);
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(r.userId)
                    .get(),
                builder: (context, userSnap) {
                  String clientName = 'Cargando...';
                  String clientPhone = 'Cargando...';
                  if (userSnap.connectionState == ConnectionState.done &&
                      userSnap.hasData &&
                      userSnap.data!.data() != null) {
                    final data = userSnap.data!.data()! as Map<String, dynamic>;
                    clientName = data['nombre'] as String? ?? 'Sin nombre';
                    clientPhone = data['telefono'] as String? ?? 'Sin Teléfono';
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        clientName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${r.pickupTime.toLocal()} → ${r.pickupAddress ?? 'Sin destino'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => ReservationDetailSheet(
                            reservation: r,
                            clientName: clientName,
                            clientPhone: clientPhone,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
