import 'dart:async';
import 'package:user_auth/screens/widgets/w_pstsignup_intro.dart';
import 'package:user_auth/screens/widgets/w_pstsignup_main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostSignUp extends StatefulWidget {
  const PostSignUp({Key? key}) : super(key: key);

  @override
  State<PostSignUp> createState() => _PostSignUpState();
}

class _PostSignUpState extends State<PostSignUp> {
  bool _introPostSignUp = true;

  @override
  void initState() {
    super.initState();
    _checkIntroStatus().then((value) {
      setState(() {
        _introPostSignUp = value;
      });
      if (_introPostSignUp) _startTimer();
    });
  }

  void _startTimer() {
    Timer(Duration(seconds: 2), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('introPostSignUp', false);
      setState(() {
        _introPostSignUp = false;
      });
    });
  }

  Future<bool> _checkIntroStatus() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    final postSignUp = true;
    // prefs.getBool('introPostSignUp') ?? true;
    return postSignUp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Personal Info'),
      ),
      body: FutureBuilder<bool>(
        future: _checkIntroStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else {
            // final bool introPostSignUp = snapshot.data!;
            return Center(
              child: _introPostSignUp
                  ? IntroPostSignUp()
                  : WPostSignUp(
                      ctx: context,
                    ),
            );
          }
        },
      ),
    );
  }
}
