// lib/models/reservation.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import 'availability_slot.dart';

enum ReservationStatus {
  requested,
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled,
  rejected,
}

enum PaymentStatus { pending, paid, failed }

class Reservation {
  final String id;
  final String userId;
  final String driverId;
  final DateTime requestTime;
  final DateTime pickupTime;
  final String pickupAddress;
  final GeoPoint pickupLocation;
  final String? dropoffAddress;
  final GeoPoint? dropoffLocation;
  final double estimatedFare;
  final double? actualFare;
  final ReservationStatus status;
  final PaymentStatus paymentStatus;
  final AvailabilitySlot? slot; // si aun usas slots fijos

  Reservation({
    required this.id,
    required this.userId,
    required this.driverId,
    required this.requestTime,
    required this.pickupTime,
    required this.pickupAddress,
    required this.pickupLocation,
    this.dropoffAddress,
    this.dropoffLocation,
    required this.estimatedFare,
    this.actualFare,
    this.status = ReservationStatus.requested,
    this.paymentStatus = PaymentStatus.pending,
    this.slot,
  });

  factory Reservation.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      userId: d['userId'] as String,
      driverId: d['driverId'] as String,
      requestTime: d['requestTime'] != null
          ? (d['requestTime'] as Timestamp).toDate()
          : DateTime.now(), // o null si haces requestTime nullable
      pickupTime: d['pickupTime'] != null
          ? (d['pickupTime'] as Timestamp).toDate()
          : DateTime.now(),
      pickupAddress: d['pickupAddress'] as String,
      pickupLocation: d['pickupLocation'] as GeoPoint,
      dropoffAddress: d['dropoffAddress'] as String?,
      dropoffLocation: d['dropoffLocation'] as GeoPoint?,
      estimatedFare: (d['estimatedFare'] as num).toDouble(),
      actualFare: (d['actualFare'] as num?)?.toDouble(),
      status: ReservationStatus.values.byName(d['status'] as String),
      paymentStatus: PaymentStatus.values.byName(d['paymentStatus'] as String),
      slot: d['slot'] != null
          ? AvailabilitySlot.fromMap(
              (d['slot'] as Map<String, dynamic>),
              d['slotDocId'] as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'driverId': driverId,
    'requestTime': Timestamp.fromDate(requestTime),
    'pickupTime': Timestamp.fromDate(pickupTime),
    'pickupAddress': pickupAddress,
    'pickupLocation': pickupLocation,
    if (dropoffAddress != null) 'dropoffAddress': dropoffAddress!,
    if (dropoffLocation != null) 'dropoffLocation': dropoffLocation!,
    'estimatedFare': estimatedFare,
    if (actualFare != null) 'actualFare': actualFare!,
    'status': status.name,
    'paymentStatus': paymentStatus.name,
    if (slot != null) 'slot': slot!.toMap(),
    if (slot != null) 'slotDocId': slot!.docId,
  };
}
