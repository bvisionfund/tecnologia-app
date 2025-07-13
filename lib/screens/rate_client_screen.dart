// lib/screens/rate_client_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../models/reservation.dart';
import '../providers/auth_provider.dart';

class RateClientScreen extends ConsumerStatefulWidget {
  static const routeName = Routes.rateClient;
  final Reservation reservation;
  const RateClientScreen({Key? key, required this.reservation})
    : super(key: key);

  @override
  ConsumerState<RateClientScreen> createState() => _RateClientScreenState();
}

class _RateClientScreenState extends ConsumerState<RateClientScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);

    final driverId = ref.read(authStateProvider).value!.uid;
    final ratingData = {
      'reservationId': widget.reservation.id,
      'raterId': driverId,
      'rateeId': widget.reservation.userId,
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Guarda en colección 'ratings'
    await FirebaseFirestore.instance.collection('ratings').add(ratingData);

    // Opcional: marca la reserva como valorada por el conductor
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservation.id)
        .update({'driverRated': true});

    setState(() => _isSubmitting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final clientName = widget.reservation.userId;
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Califica al cliente de la reserva:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => _rating = starIndex);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comentario (opcional)',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting || _rating == 0 ? null : _submitRating,
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text('Enviar Calificación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
