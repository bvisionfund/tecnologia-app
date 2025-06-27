import 'package:flutter/material.dart';

class RatingStar extends StatelessWidget {
  final int filled;

  const RatingStar({Key? key, required this.filled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < filled ? Icons.star : Icons.star_border,
        );
      }),
    );
  }
}