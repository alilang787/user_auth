import 'dart:io';

import 'package:flutter/material.dart';

class ImageGetter extends StatelessWidget {
  final File? userImage;
  ImageGetter({super.key, this.userImage});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CircleAvatar(
        radius: 45,
        backgroundImage: userImage != null
            ? FileImage(userImage!) as ImageProvider
            : AssetImage(
                Theme.of(context).brightness == Brightness.light
                    ? 'assets/icons/user-auth/user.png'
                    : 'assets/icons/user-auth/user_dark.png',
              ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                ),
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Edit',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
