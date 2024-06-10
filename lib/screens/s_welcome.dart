import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child: user.photoURL == null
                  ? Image.asset('assets/icons/user-auth/user.png')
                  : FadeInImage(
                      fit: BoxFit.cover,
                      placeholder:
                          AssetImage('assets/icons/user-auth/user.png'),
                      image: NetworkImage(
                        user.photoURL!,
                      ),
                    ),
            ),
            SizedBox(height: 12),
            Text('Welcome ${user.displayName?.split(' ').first}'),
          ],
        ),
      ),
    );
  }
}
