import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

enum UserType { user, driver }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _identificacionCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  DateTime? _fechaNacimiento;
  UserType _userType = UserType.user;
  bool _loading = false;

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fechaNacimiento = d);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userType == UserType.driver && _fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha de nacimiento')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await ref
          .read(authProvider)
          .createUserWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      final uid = cred.user!.uid;
      final db = FirebaseFirestore.instance;

      if (_userType == UserType.user) {
        await db.collection('users').doc(uid).set({
          'nombre': _nombreCtrl.text.trim(),
          'apellido': _apellidoCtrl.text.trim(),
          'correo': _emailCtrl.text.trim(),
          'telefono': _telefonoCtrl.text.trim(),
          'fechaRegistro': Timestamp.now(),
        });
      } else {
        await db.collection('drivers').doc(uid).set({
          'nombre': _nombreCtrl.text.trim(),
          'apellido': _apellidoCtrl.text.trim(),
          'identificacion': _identificacionCtrl.text.trim(),
          'fechaNacimiento': Timestamp.fromDate(_fechaNacimiento!),
          'ciudadResidencia': _ciudadCtrl.text.trim(),
          'correo': _emailCtrl.text.trim(),
          'telefono': _telefonoCtrl.text.trim(),
          'descripcion': '',
          'valorHora': 0.0,
          'estadoAprobacion': 'pendiente',
          'fechaRegistro': Timestamp.now(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Por favor inicia sesión.'),
        ),
      );
      Navigator.pop(context); // volvemos al login
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al registrarse')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apellidoCtrl,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const Divider(height: 32),

              // Selección de rol
              RadioListTile<UserType>(
                title: const Text('Cliente'),
                value: UserType.user,
                groupValue: _userType,
                onChanged: (v) => setState(() => _userType = v!),
              ),
              RadioListTile<UserType>(
                title: const Text('Conductor'),
                value: UserType.driver,
                groupValue: _userType,
                onChanged: (v) => setState(() => _userType = v!),
              ),
              const SizedBox(height: 8),

              // Campos extra para conductor
              if (_userType == UserType.driver) ...[
                TextField(
                  controller: _identificacionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Identificación',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Fecha de nacimiento',
                    hintText: _fechaNacimiento == null
                        ? 'Selecciona fecha'
                        : _fechaNacimiento!.toLocal().toString().split(' ')[0],
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ciudadCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad de residencia',
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Crear cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
