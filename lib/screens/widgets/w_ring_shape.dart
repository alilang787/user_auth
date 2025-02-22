import 'package:flutter/material.dart';

class RingShape extends StatelessWidget {
  const RingShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: RingClipper(),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.width * 0.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade800,
                Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).primaryColor.withOpacity(0.6)
                    : Colors.grey,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RingClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    path.addOval(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius - 10,
    )); // Adjust the value as needed for the ring thickness
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
