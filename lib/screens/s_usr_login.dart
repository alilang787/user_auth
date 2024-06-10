import 'package:user_auth/main.dart';
import 'package:user_auth/screens/widgets/w_back_button.dart';
import 'package:user_auth/screens/widgets/w_loading.dart';
import 'package:user_auth/screens/widgets/w_padText.dart';
import 'package:user_auth/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UsrLogIn extends StatefulWidget {
  const UsrLogIn({super.key});

  @override
  State<UsrLogIn> createState() => _UsrLogInState();
}

class _UsrLogInState extends State<UsrLogIn> with WidgetsBindingObserver {
  bool _obsecurePass = true;
  bool _isKeyboardOpen = false;
  bool _isLoading = false;
  String? _username;
  String? _usernameError;
  String? _password;
  String? _passwordError;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    setState(() {
      // Check if the keyboard is open based on the bottom inset
      _isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    });
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                if (!_isKeyboardOpen)
                  Image.asset(
                    Theme.of(context).brightness == Brightness.light
                        ? 'assets/icons/user-auth/user_auth.png'
                        : 'assets/icons/user-auth/user_auth_dark.png',
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                  ),
                if (_isKeyboardOpen) Gap(16),
                if (_isKeyboardOpen)
                  SafeArea(
                    child: Text(
                      'Log In',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                Gap(16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //
                        // ----------- Username Field --------------

                        paddText(text: 'Username'),
                        TextFormField(
                          onSaved: (newValue) {
                            _username = newValue;
                          },
                          validator: _usernameValidator,
                          decoration: InputDecoration(
                            errorText: _usernameError,
                            prefixIcon: Icon(Icons.email),
                            hintText: 'Enter username',
                          ),
                        ),
                        Gap(22),

                        // ----------- Password Field --------------

                        paddText(text: 'Password'),
                        TextFormField(
                          onSaved: (newValue) {
                            _password = newValue;
                          },
                          validator: _passwordValidator,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          obscureText: _obsecurePass,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            errorText: _passwordError,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obsecurePass = !_obsecurePass;
                                });
                              },
                              icon: Icon(
                                _obsecurePass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            hintText: 'Enter password',
                          ),
                        ),
                        Gap(32),

                        // ----------- Log In Button ------------

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _onSubmit,
                              //  _onSubmit,
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Text('Log In'),
                              ),
                            )
                          ],
                        ),
                        Gap(26),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          GoBack(),
          if (_isLoading) Loading(),
        ],
      ),
    );
  }

  // =================== M E T H O D S ====================

  //      ................  onSubmit ................
  void _onSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    bool error = await Utils.checkConnectivity(context);
    if (error) return;

    setState(() {
      _isLoading = true;
    });

    // --------  check if username is present ----------

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _username)
        .get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _usernameError = null;
      });
      final String _email = snapshot.docs[0].data()['email'];
      // late UserCredential auth;
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _email,
              password: _password!,
            )
            .timeout(Duration(seconds: 15));
      } on FirebaseException catch (e) {
        setState(() {
          _isLoading = false;
        });
        // printLog(v: e.code);
        if (e.code == 'invalid-credential') {
          setState(() {
            _passwordError = 'Incorrect password';
          });
          return;
        }

        Utils.showDialog(
          context: context,
          title: 'Something went wrong',
          content: Text('make sure you have working internet connection.'),
        );
        return;
      }
    } else {
      setState(() {
        _usernameError = 'No account found regarding this username,';
      });
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return MainApp();
        },
      ),
    );
  }

  //      ................username validator................
  String? _usernameValidator(String? value) {
    if (value == null || value.isEmpty) return 'Enter username';
    final RegExp usernamePattern = RegExp(
      r'^[A-Za-z][a-z]*[0-9]+$',
    );

    if (!usernamePattern.hasMatch(value))
      return 'Username must consists numbers followed by letters';
    if (value.length < 3) return 'Username consist at least 3 letters';

    return null;
  }

  //      ................password validator................
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 6) return 'wrong password';
    return null;
  }
}
