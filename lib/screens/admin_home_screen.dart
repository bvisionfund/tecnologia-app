// lib/screens/admin_home_screen.dart

import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administrador')),
      body: const Center(child: Text('Bienvenido, Admin')),
    );
  }
}
