import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<void> updateDriverLocation(String driverId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied)
      return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance.collection('drivers').doc(driverId).update(
      {'currentLocation': GeoPoint(pos.latitude, pos.longitude)},
    );
  }

  /// Actualiza la ubicación del conductor en Firestore
  /// Obtiene la ubicación actual del dispositivo
  /// Retorna un GeoPoint o null si no se puede obtener la ubicación
  Future<GeoPoint?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied)
      return null;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return GeoPoint(pos.latitude, pos.longitude);
  }
}
