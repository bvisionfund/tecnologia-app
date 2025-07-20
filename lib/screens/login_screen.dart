// lib/screens/login_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../providers/auth_provider.dart';
import '../services/role_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      // 1) Autenticamos en Firebase Auth
      final cred = await ref
          .read(authProvider)
          .signInWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      final uid = cred.user!.uid;

      // 1a) Verificar si es un chofer pendiente de aprobación
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(uid)
          .get();
      if (driverDoc.exists) {
        final estado = driverDoc.data()?['estadoAprobacion'] as String?;
        if (estado != 'aprobado') {
          // Navegar a pantalla de solicitud pendiente
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
          );
          return;
        }
      }

      // 2) Detectamos el rol en Firestore (admins, drivers, users)
      final role = await RoleService().detectRole(uid);

      // 3) Navegamos según rol
      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, Routes.adminHome);
          break;
        case 'driver':
          Navigator.pushReplacementNamed(context, Routes.driverHome);
          break;
        case 'user':
          Navigator.pushReplacementNamed(context, Routes.home);
          break;
        default:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Rol desconocido.')));
      }
    } on FirebaseAuthException catch (e) {
      // Error de autenticación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al iniciar sesión')),
      );
    } catch (e) {
      // Cualquier otro error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ocurrió un error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : const Text('Ingresar'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushNamed(context, Routes.register),
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla que informa al chofer que su solicitud está pendiente
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud Pendiente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Tu solicitud como chofer aún no ha sido aprobada por el administrador.\n\nPor favor, espera a que revisen y aprueben tu cuenta.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
