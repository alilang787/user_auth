import 'package:twitter_login/entity/auth_result.dart';
import 'package:user_auth/main.dart';
import 'package:user_auth/providers/p_conditions.dart';
import 'package:user_auth/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class XPostAuth extends ConsumerStatefulWidget {
  final AuthResult authResult;
  final OAuthCredential credential;

  const XPostAuth(
      {super.key, required this.credential, required this.authResult});

  @override
  ConsumerState<XPostAuth> createState() => _PostAuthState();
}

class _PostAuthState extends ConsumerState<XPostAuth> {
  void _authUser() async {
    ref.read(isSignInAllowed.notifier).changeVal(false);
    final _fireAuth = FirebaseAuth.instance;

    try {
      final _auth = await _fireAuth.signInWithCredential(widget.credential);

      if (_auth.user != null) {
        //  -------------- extract and update data ---------------

        String? _porfileUrl = widget.authResult.user!.thumbnailImage;
        String _userName = widget.authResult.user!.screenName;
        String? fullName = widget.authResult.user!.name;
        List<String>? nameParts = fullName.split(" ");
        String? _firstName = nameParts.first;
        String? _lastName = nameParts.sublist(1, nameParts.length).join(" ");

        //  -------------- uloading data ---------------

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.user!.uid)
              .set({
            'profileUrl': _porfileUrl,
            'firstName': _firstName,
            'lastName': _lastName,
            'username': _userName + '-xuser',
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
