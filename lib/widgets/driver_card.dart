import 'package:flutter/material.dart';
import '../models/driver.dart';

class DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback onTap;

  const DriverCard({Key? key, required this.driver, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${driver.nombre} ${driver.apellido}'),
        subtitle: Text(driver.ciudadResidencia),
        trailing: Text('\$${driver.valorHora}/h'),
        onTap: onTap,
      ),
    );
  }
}