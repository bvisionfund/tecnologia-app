import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapDriverListScreen extends ConsumerStatefulWidget {
  const MapDriverListScreen({super.key});

  @override
  ConsumerState<MapDriverListScreen> createState() =>
      _MapDriverListScreenState();
}

class _MapDriverListScreenState extends ConsumerState<MapDriverListScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _permisosOtorgados = false;

  Future<void> _moverCamaraAUbicacionActual() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        13,
      ),
    );
  }

  LatLngBounds _crearLimitesDesdeMarcadores(Set<Marker> markers) {
    final latitudes = markers.map((m) => m.position.latitude);
    final longitudes = markers.map((m) => m.position.longitude);

    final southwest = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );
    final northeast = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final permisos = await Permission.location.request();

    if (permisos.isGranted && mounted) {
      setState(() {
        _permisosOtorgados = true;
      });
      _loadDrivers();
    } else {
      await openAppSettings(); // por si están denegados
    }
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

          if (mounted) {
            setState(() {
              _markers
                ..clear()
                ..addAll(markers);
            });
            if (_markers.isNotEmpty) {
              final bounds = _crearLimitesDesdeMarcadores(_markers);
              _mapController.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 50),
              );
            } else {
              _moverCamaraAUbicacionActual();
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choferes Cercanos')),
      body: _permisosOtorgados
          ? GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-0.1807, -78.4678), // Quito
                zoom: 7,
              ),
              onMapCreated: (controller) async {
                _mapController = controller;
                await _moverCamaraAUbicacionActual(); // 👉 opcional si quieres mostrar Ibarra por defecto
              },
              markers: _markers,
              myLocationEnabled: true,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
