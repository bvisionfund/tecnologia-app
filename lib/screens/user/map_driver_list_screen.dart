import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDriverListScreen extends ConsumerStatefulWidget {
  const MapDriverListScreen({super.key});

  @override
  ConsumerState<MapDriverListScreen> createState() =>
      _MapDriverListScreenState();
}

class _MapDriverListScreenState extends ConsumerState<MapDriverListScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  void _loadDrivers() {
    FirebaseFirestore.instance
        .collection('drivers')
        .where('estadoAprobacion', isEqualTo: 'aprobado')
        .snapshots()
        .listen((snapshot) {
          final markers = <Marker>{};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final GeoPoint? location = data['currentLocation'];
            if (location != null) {
              markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(location.latitude, location.longitude),
                  infoWindow: InfoWindow(
                    title: '${data['nombre']} ${data['apellido']}',
                    snippet: 'Ciudad: ${data['ciudadResidencia']}',
                  ),
                ),
              );
            }
          }
          setState(() => _markers.clear());
          setState(() => _markers.addAll(markers));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choferes Cercanos')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-0.1807, -78.4678), // Quito
          zoom: 13,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _markers,
        myLocationEnabled: true,
      ),
    );
  }
}
