import 'dart:ui';

import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Align(
          child: Container(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 6,
            ),
          ),
        ),
      ),
    );
  }
}
