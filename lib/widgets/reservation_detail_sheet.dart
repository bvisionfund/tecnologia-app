// lib/widgets/reservation_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/reservation.dart';

class ReservationDetailSheet extends StatelessWidget {
  final Reservation reservation;
  final String clientName;

  const ReservationDetailSheet({
    Key? key,
    required this.reservation,
    required this.clientName,
  }) : super(key: key);

  Future<void> _openMaps() async {
    final lat = reservation.pickupLocation.latitude;
    final lng = reservation.pickupLocation.longitude;

    // Intento abrir en la app nativa de Google Maps (URI scheme)
    final navUri = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(navUri)) {
      await launchUrl(navUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Si no funciona, usamos la versión web de Google Maps
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
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
        ],
      ),
    );
  }
}
