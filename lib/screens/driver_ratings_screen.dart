// lib/screens/driver_ratings_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';

class DriverRatingsScreen extends ConsumerWidget {
  static const routeName = Routes.driverRatings;
  final String driverId;

  const DriverRatingsScreen({Key? key, required this.driverId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsStream = FirebaseFirestore.instance
        .collection('ratings')
        .where('rateeId', isEqualTo: driverId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Calificaciones del Chofer')),
      body: StreamBuilder<QuerySnapshot>(
        stream: ratingsStream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('Este chofer aún no tiene calificaciones.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data()! as Map<String, dynamic>;
              final rating = d['rating'] as int? ?? 0;
              final comment = d['comment'] as String? ?? '';
              final timestamp = (d['timestamp'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  title: Text(comment.isNotEmpty ? comment : 'Sin comentario'),
                  subtitle: timestamp != null
                      ? Text(
                          'Fecha: ${timestamp.toLocal()}',
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
