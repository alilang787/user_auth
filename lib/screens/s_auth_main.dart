import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:user_auth/screens/s_google_post_auth.dart';
import 'package:user_auth/screens/s_twitter_post_auth.dart';
import 'package:user_auth/screens/s_usr_login.dart';
import 'package:user_auth/screens/s_usr_signup.dart';
import 'package:user_auth/screens/widgets/w_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_auth/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UserAuthMain extends ConsumerStatefulWidget {
  const UserAuthMain({super.key});

  @override
  ConsumerState<UserAuthMain> createState() => _UserAuthMainState();
}

class _UserAuthMainState extends ConsumerState<UserAuthMain> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : null,
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHH = constraints.maxHeight;
                final maxWW = constraints.maxWidth;
                return Column(
                  children: [
                    Container(
                      height: maxHH * 0.4,
                      width: maxWW,
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.light
                            ? 'assets/icons/user-auth/user_auth.png'
                            : 'assets/icons/user-auth/user_auth_dark.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxH = constraints.maxHeight;
                            final maxW = constraints.maxWidth;
                            return Column(
                              children: [
                                Gap(maxH * 0.05),
                                Container(
                                  height: maxH * 0.15,
                                  child: FittedBox(
                                    child: Text(
                                      'HELLO',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                    ),
                                  ),
                                ),
                                Gap(maxH * 0.1),
                                Container(
                                  width: maxW * 0.8,
                                  height: maxH * 0.12,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return UsrLogIn();
                                        },
                                      ),
                                    ),
                                    child: Text('Log In'),
                                  ),
                                ),
                                Gap(maxH * 0.08),
                                Container(
                                  width: maxW * 0.8,
                                  height: maxH * 0.12,
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return UsrSignUp();
                                        },
                                      ),
                                    ),
                                    child: Text('Sign Up'),
                                  ),
                                ),
                                Gap(maxH * 0.12),
                                Container(
                                  height: maxH * 0.05,
                                  padding: EdgeInsets.symmetric(horizontal: 48),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Text('OR'),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                ),
                                Gap(maxH * 0.03),
                                Container(
                                  height: maxH * 0.1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => _googleSignUp(context),
                                        icon: Image.asset(
                                          'assets/icons/user-auth/google.png',
                                        ),
                                      ),
                                      Gap(4),
                                      IconButton(
                                        onPressed: _fbSignUp,
                                        icon: Image.asset(
                                            'assets/icons/user-auth/facebook.png'),
                                      ),
                                      Gap(4),
                                      IconButton(
                                        onPressed: _xSignUp,
                                        icon: Image.asset(
                                            'assets/icons/user-auth/twitter.png'),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          if (_isLoading) Loading()
        ],
      ),
    );
  }

  // ========================= M E T H O D S ============================

  // ------------- google singup --------------------

  void _googleSignUp(BuildContext context) async {
    bool error = await Utils.checkConnectivity(context);
    if (error) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final _gUser = await GoogleSignIn().signIn();
      if (_gUser != null) {
        final _gAuth = await _gUser.authentication;
        final _credential = GoogleAuthProvider.credential(
          accessToken: _gAuth.accessToken,
          idToken: _gAuth.idToken,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return GPostAuth(
              credential: _credential,
              gUser: _gUser,
            );
          },
        ));
      }
    } catch (e) {
      Utils.showDialog(
        context: context,
        title: 'Something went wrong',
        content: Text('make sure you have working internet connection.'),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ------------- facebook singup --------------------

  void _fbSignUp() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final accessToken = result.accessToken!.toString();
      final fbCredential = FacebookAuthProvider.credential(accessToken);

      // final userData = await FacebookAuth.instance.getUserData();
      await FirebaseAuth.instance.signInWithCredential(fbCredential);

      // Use the access token to fetch user information
    } else {
      // Handle the error
      print(result.status);
      print(result.message);
    }
  }

  // ------------- twitter singup --------------------

  void _xSignUp() async {
    final twitterLogin = TwitterLogin(
      apiKey: 'your api key key got from x developer account',
      apiSecretKey: 'your api secret key got from x developer account',
      redirectURI:
          'your redirUrl provided by firebase',
    );

    setState(() {
      _isLoading = true;
    });

    late AuthResult authResult;
    try {
      authResult = await twitterLogin.login();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      printLog(v: e.toString());
    }

    if (authResult.status == TwitterLoginStatus.loggedIn) {
      //
      // ---------- generate firebase user ------------
      //
      printLog(v: authResult.user!.name);
      setState(() {
        _isLoading = false;
      });
      final xCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return XPostAuth(
            credential: xCredential,
            authResult: authResult,
          );
        },
      ));
      //
      // ---------------------------------------
      //
    } else {
      printLog(v: 'error');
    }

    setState(() {
      _isLoading = false;
    });
  }
}

// ref.read(isSignInAllowed.notifier).changeVal(true);
