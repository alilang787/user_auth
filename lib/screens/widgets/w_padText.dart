import 'package:flutter/material.dart';

class paddText extends StatelessWidget {
  final String text;
  paddText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
