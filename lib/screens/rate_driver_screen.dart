// lib/screens/rate_driver_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../models/reservation.dart';
import '../providers/auth_provider.dart';

class RateDriverScreen extends ConsumerStatefulWidget {
  static const routeName = Routes.rateDriver;
  final Reservation reservation;

  const RateDriverScreen({Key? key, required this.reservation})
    : super(key: key);

  @override
  ConsumerState<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends ConsumerState<RateDriverScreen> {
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

    final clientId = ref.read(authStateProvider).value!.uid;
    final ratingData = {
      'reservationId': widget.reservation.id,
      'raterId': clientId,
      'rateeId': widget.reservation.driverId,
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Guarda en colección 'ratings'
    await FirebaseFirestore.instance.collection('ratings').add(ratingData);

    // Opcional: marca en la reserva que el cliente ya calificó
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservation.id)
        .update({'clientRated': true});

    setState(() => _isSubmitting = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar Chofer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Califica al chofer de la reserva:',
              style: Theme.of(context).textTheme.headlineMedium,
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
