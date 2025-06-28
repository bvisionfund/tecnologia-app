import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/driver_provider.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDriversProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administrador')),
      body: pendingAsync.when(
        data: (drivers) {
          if (drivers.isEmpty) {
            return const Center(child: Text('No hay choferes pendientes'));
          }
          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final drv = drivers[index];
              return ListTile(
                title: Text('${drv.nombre} ${drv.apellido}'),
                subtitle: Text('ID: ${drv.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .updateDriverApproval(drv.id, true);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .updateDriverApproval(drv.id, false);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
