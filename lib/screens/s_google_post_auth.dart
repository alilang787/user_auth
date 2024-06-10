import 'package:user_auth/main.dart';
import 'package:user_auth/providers/p_conditions.dart';
import 'package:user_auth/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GPostAuth extends ConsumerStatefulWidget {
  final OAuthCredential credential;
  final GoogleSignInAccount gUser;
  const GPostAuth({super.key, required this.credential, required this.gUser});

  @override
  ConsumerState<GPostAuth> createState() => _PostAuthState();
}

class _PostAuthState extends ConsumerState<GPostAuth> {
  void _authUser() async {
    final _gUser = widget.gUser;
    ref.read(isSignInAllowed.notifier).changeVal(false);
    final _fireAuth = FirebaseAuth.instance;

    try {
      final _auth = await _fireAuth.signInWithCredential(widget.credential);

      if (_auth.user != null) {
        //  -------------- extracting data ---------------
        String? _porfileUrl = _gUser.photoUrl;
        String email = _gUser.email;
        String userNameRaw = email.split('@').first;
        String _userName = userNameRaw.replaceAll('.', '');
        String? fullName = _gUser.displayName;
        List<String>? nameParts = fullName?.split(" ");
        String? _firstName = nameParts?.first;

        String? _lastName = nameParts?.sublist(1, nameParts.length).join(" ");

        //  -------------- uloading data ---------------

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.user!.uid)
              .set({
            'email': email,
            'profileUrl': _porfileUrl,
            'firstName': _firstName,
            'lastName': _lastName,
            'username': _userName + '-guser',
          }).timeout(Duration(seconds: 15));
          await _auth.user!.updateDisplayName(fullName);
          await _auth.user!.updatePhotoURL(_porfileUrl);
        } catch (e) {
          await _auth.user!.delete();
          _generalExceptions(context);
          return;
        }
      }
    } catch (e) {
      _generalExceptions(context);
      return;
    }
    ref.read(isSignInAllowed.notifier).changeVal(true);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return MainApp();
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    _authUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  //  ==================== M E T H O D S =====================

  //     ................ firebase exceptions .................
  void _generalExceptions(BuildContext context) {
    Utils.showDialog(
      context: context,
      title: 'Something went wrong',
      content: Text('make sure you have working internet connection.'),
      goHome: true,
    );
  }
}
