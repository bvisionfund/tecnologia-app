// lib/widgets/reservation_detail_sheet.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_router.dart';
import '../models/reservation.dart';

class ReservationDetailSheet extends StatelessWidget {
  final Reservation reservation;
  final String clientName;
  final String clientPhone;

  const ReservationDetailSheet({
    Key? key,
    required this.reservation,
    required this.clientName,
    required this.clientPhone,
  }) : super(key: key);

  Future<void> _openMaps() async {
    final lat = reservation.pickupLocation.latitude;
    final lng = reservation.pickupLocation.longitude;
    final navUri = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(navUri)) {
      await launchUrl(navUri, mode: LaunchMode.externalApplication);
      return;
    }
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  }

  Future<void> _callClient() async {
    final uri = Uri(scheme: 'tel', path: clientPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'No se pudo iniciar la llamada';
    }
  }

  Future<void> _markCompleted(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(reservation.id)
        .update({'status': ReservationStatus.completed.name});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pickup = reservation.pickupTime.toLocal().toString();
    final destination = reservation.pickupLocation ?? 'No especificado';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente: $clientName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Recogida: $pickup'),
          const SizedBox(height: 4),
          Text('Destino: $destination'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.navigation),
            label: const Text('Abrir en Maps'),
            onPressed: _openMaps,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.call),
            label: const Text('Llamar al cliente'),
            onPressed: _callClient,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Reserva completada'),
            onPressed: () => _markCompleted(context),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.star),
            label: const Text('Calificar carrera'),
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.rateClient,
                arguments: reservation,
              );
            },
          ),
        ],
      ),
    );
  }
}
