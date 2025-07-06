import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Actualiza la ubicación del conductor en Firestore
  Future<void> updateDriverLocation(String driverId) async {
    final position = await _getValidPosition();
    if (position == null) return;

    await FirebaseFirestore.instance.collection('drivers').doc(driverId).update(
      {'currentLocation': GeoPoint(position.latitude, position.longitude)},
    );
  }

  /// Retorna la ubicación actual como GeoPoint, o null si no está disponible
  Future<GeoPoint?> getCurrentLocation() async {
    final position = await _getValidPosition();
    if (position == null) return null;

    return GeoPoint(position.latitude, position.longitude);
  }

  /// Verifica permisos y retorna una posición válida
  Future<Position?> _getValidPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
