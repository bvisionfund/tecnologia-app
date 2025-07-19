// lib/screens/request_closest_driver_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/reservation.dart';
import '../providers/auth_provider.dart';

class RequestClosestDriverScreen extends ConsumerStatefulWidget {
  const RequestClosestDriverScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RequestClosestDriverScreen> createState() =>
      _RequestClosestDriverScreenState();
}

class _RequestClosestDriverScreenState
    extends ConsumerState<RequestClosestDriverScreen> {
  bool _loading = false;
  String? _message;

  Future<void> _findAndRequest() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      // Obtener posición del usuario
      Position userPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final userLocation = GeoPoint(userPos.latitude, userPos.longitude);

      // Obtener choferes aprobados
      final snapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('estadoAprobacion', isEqualTo: 'aprobado')
          .get();

      GeoPoint? closestLoc;
      String? closestDriverId;
      double minDistance = double.infinity;

      // Calcular el chofer más cercano
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final loc = data['currentLocation'] as GeoPoint?;
        if (loc == null) continue;
        final dist = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          loc.latitude,
          loc.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          closestLoc = loc;
          closestDriverId = doc.id;
        }
      }

      if (closestDriverId == null) {
        setState(() => _message = 'No se encontró ningún chofer cercano.');
        return;
      }

      // Obtener UID del usuario
      final userId = ref.read(authStateProvider).value?.uid;
      if (userId == null) {
        setState(() => _message = 'Usuario no autenticado.');
        return;
      }

      final now = DateTime.now();
      // Guardar en colección top-level 'reservations'
      await FirebaseFirestore.instance.collection('reservations').add({
        'userId': userId,
        'driverId': closestDriverId,
        'requestTime': Timestamp.fromDate(now),
        'pickupTime': Timestamp.fromDate(now.add(const Duration(minutes: 5))),
        'pickupAddress': 'Ubicación actual',
        'pickupLocation': userLocation,
        'estimatedFare': 5.0,
        'status': ReservationStatus.pending.name,
        'paymentStatus': PaymentStatus.pending.name,
      });

      setState(() => _message = 'Reserva realizada con chofer más cercano.');
    } catch (e) {
      setState(() => _message = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar chofer más cercano')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _findAndRequest,
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Buscar y reservar'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 20),
              Text(_message!, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
