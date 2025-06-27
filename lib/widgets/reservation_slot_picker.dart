import 'package:flutter/material.dart';
import '../models/availability_slot.dart';

class ReservationSlotPicker extends StatelessWidget {
  final List<AvailabilitySlot> availability;
  final void Function(AvailabilitySlot) onSlotSelected;

  const ReservationSlotPicker({
    Key? key,
    required this.availability,
    required this.onSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: availability
          .where((s) => !s.reservado)
          .map((s) => ListTile(
                title: Text(
                  '${s.inicio.hour.toString().padLeft(2, '0')}:${s.inicio.minute.toString().padLeft(2, '0')} - '
                  '${s.fin.hour.toString().padLeft(2, '0')}:${s.fin.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () => onSlotSelected(s),
              ))
          .toList(),
    );
  }
}