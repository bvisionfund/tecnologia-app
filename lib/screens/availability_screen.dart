import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tecnologia_app/providers/driver_provider.dart';

import '../models/availability_slot.dart';
import '../providers/auth_provider.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});
  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  DateTime? _start;
  DateTime? _end;
  bool _loading = false;

  Future<void> _pickStart() async {
    final dt = await showDateTimePicker(context);
    if (dt != null) setState(() => _start = dt);
  }

  Future<void> _pickEnd() async {
    final dt = await showDateTimePicker(context);
    if (dt != null) setState(() => _end = dt);
  }

  Future<void> _save() async {
    if (_start == null || _end == null) return;
    setState(() => _loading = true);
    final uid = ref.read(authProvider).currentUser!.uid;
    final slot = AvailabilitySlot(
      inicio: _start!,
      fin: _end!,
      reservado: false,
      docId: _start!.toIso8601String().split('T').first,
    );
    await ref.read(firestoreServiceProvider).addAvailabilitySlot(uid, slot);
    setState(() {
      _start = null;
      _end = null;
      _loading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Horario agregado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disponibilidad')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextButton(
              onPressed: _pickStart,
              child: Text(
                _start == null ? 'Seleccionar inicio' : _start.toString(),
              ),
            ),
            TextButton(
              onPressed: _pickEnd,
              child: Text(_end == null ? 'Seleccionar fin' : _end.toString()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Disponibilidad'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Función de utilidad
Future<DateTime?> showDateTimePicker(BuildContext ctx) async {
  final date = await showDatePicker(
    context: ctx,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 30)),
  );
  if (date == null) return null;
  final time = await showTimePicker(
    context: ctx,
    initialTime: const TimeOfDay(hour: 8, minute: 0),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
