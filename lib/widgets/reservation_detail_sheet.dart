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

  /// Construye la URL de Google Maps para navegar a [destination].
  Future<void> _openMaps(String destination) async {
    final encoded = Uri.encodeComponent(destination);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$encoded',
    );
    if (!await canLaunchUrl(uri)) {
      throw 'No se pudo abrir Google Maps';
    }
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final pickup = reservation.pickupTime.toLocal().toString();
    final destination = 'reservation.destination ' ?? 'No especificado';
    final notes = 'reservation.notes' ?? '—';

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
          const Text(
            'Notas adicionales:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(notes),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.navigation),
            label: const Text('Abrir en Maps'),
            onPressed: () => _openMaps(destination),
          ),
        ],
      ),
    );
  }
}
