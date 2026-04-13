import 'package:flutter/material.dart';

/// Reusable "SCANNED" badge widget — previously copy-pasted in 2 screens
/// with inconsistent sizes. Now a single source of truth.
class ScannedBadge extends StatelessWidget {
  final double fontSize;
  final EdgeInsets padding;

  const ScannedBadge({
    super.key,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'SCANNED',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
