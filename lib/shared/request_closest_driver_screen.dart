import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/reservation.dart';
import '../../providers/auth_provider.dart';

class RequestClosestDriverScreen extends ConsumerStatefulWidget {
  const RequestClosestDriverScreen({super.key});

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
      Position userPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final userLocation = GeoPoint(userPos.latitude, userPos.longitude);

      final snapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('estadoAprobacion', isEqualTo: 'aprobado')
          .get();

      GeoPoint? closest;
      String? closestDriverId;
      double minDistance = double.infinity;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final GeoPoint? location = data['currentLocation'];
        if (location == null) continue;
        final distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          location.latitude,
          location.longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
          closest = location;
          closestDriverId = doc.id;
        }
      }

      if (closestDriverId == null) {
        setState(() => _message = 'No se encontró ningún chofer cercano.');
        return;
      }

      final userId = ref.read(authStateProvider).value?.uid;
      if (userId == null) {
        setState(() => _message = 'Usuario no autenticado.');
        return;
      }

      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reservations')
          .add({
            'userId': userId,
            'driverId': closestDriverId,
            'requestTime': Timestamp.now(),
            'pickupTime': Timestamp.fromDate(
              now.add(const Duration(minutes: 5)),
            ),
            'pickupAddress': 'Ubicación actual',
            'pickupLocation': userLocation,
            'estimatedFare': 5.0,
            'status': ReservationStatus.requested.name,
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
                  ? const CircularProgressIndicator()
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
