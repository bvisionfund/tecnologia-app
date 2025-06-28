import 'package:flutter/material.dart';

import '../app_router.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Chofer')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.availability);
          },
          child: const Text('Ingresar Horario Disponible'),
        ),
      ),
    );
  }
}
