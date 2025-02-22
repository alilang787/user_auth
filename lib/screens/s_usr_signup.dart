import 'package:user_auth/screens/s_post_signup.dart';
import 'package:user_auth/screens/widgets/w_back_button.dart';
import 'package:user_auth/screens/widgets/w_loading.dart';
import 'package:user_auth/screens/widgets/w_padText.dart';
import 'package:user_auth/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsrSignUp extends StatefulWidget {
  const UsrSignUp({super.key});

  @override
  State<UsrSignUp> createState() => _UsrSignUpState();
}

class _UsrSignUpState extends State<UsrSignUp> with WidgetsBindingObserver {
  bool _obsecurePass = true;
  bool _isKeyboardOpen = false;
  bool _isLoading = false;
  String? _username;
  String? _usernameError;
  String? _email;
  String? _emailError;
  String? _password;
  String? _rePassError;
  late TextEditingController _dateOfBirthController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dateOfBirthController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _dateOfBirthController.dispose();
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
                    'Sign Up',
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
                      // ----------- userName Field --------------

                      paddText(text: 'Username'),
                      TextFormField(
                        onSaved: (newValue) {
                          _username = newValue;
                        },
                        validator: _usernameValidator,
                        maxLength: 12,
                        decoration: InputDecoration(
                          errorText: _usernameError,
                          errorMaxLines: 2,
                          prefixIcon: Icon(Icons.email),
                          hintText: 'enter username',
                        ),
                      ),
                      Gap(2),

                      // ----------- Email Field --------------

                      paddText(text: 'Email'),
                      TextFormField(
                        onSaved: (newValue) {
                          _email = newValue;
                        },
                        validator: _emailValidator,
                        decoration: InputDecoration(
                          errorText: _emailError,
                          prefixIcon: Icon(Icons.email),
                          hintText: 'example@domain.com',
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
                            hintText: 'enter password',
                            errorMaxLines: 3),
                      ),
                      Gap(32),

                      // ----------- Retype Password Field --------------

                      paddText(text: 'Verify Password'),
                      TextFormField(
                        validator: _vpasswordValidator,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        obscureText: _obsecurePass,
                        decoration: InputDecoration(
                          errorText: _rePassError,
                          prefixIcon: Icon(Icons.lock),
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
                          hintText: 'verify password',
                        ),
                      ),
                      Gap(32),

                      // ----------- Next Sign Up Button ------------

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _onSubmit,
                            //  _onSubmit,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text('Next'),
                            ),
                          )
                        ],
                      ),
                      Gap(26)
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
    ));
  }

  // =================== M E T H O D S ====================

  //      ................  sign up ................
  void _onSubmit() async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) return;

    bool error = await Utils.checkConnectivity(context);
    if (error) return;

    setState(() {
      _isLoading = true;
    });

    late UserCredential _userCredential;

    //  ---- try to signUp ------

    try {
      _userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );
    } on FirebaseException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'email-already-in-use') {
        _emailError = 'email already in use.';
      }

      if (e.code == 'network-request-failed') {
        Utils.showDialog(
          context: context,
          title: 'Connection error',
          content: Text('make sure you have working internet connection'),
        );
      }
      FocusScope.of(context).unfocus();
      return;
    }

    if (_userCredential.user != null) {
      //  ---- chekc if username already taken ----
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _username!.toLowerCase())
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _usernameError = 'username already taken.';
        });
        await _userCredential.user!.delete();
        return;
      }

      //  ---- store username & email in database ----
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_userCredential.user!.uid)
            .set({
          'username': _username!.toLowerCase(),
          'email': _email,
        });
      } on FirebaseException catch (_) {
        await _userCredential.user!.delete();
        setState(() {
          _isLoading = false;
        });
        Utils.showDialog(
          context: context,
          title: 'Something went wrong',
          content: Text('make sure you have working internet connection.'),
        );
      }
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('postSignUp', true);
    await prefs.setBool('introPostSignUp', true);
    setState(() {
      _emailError = null;
      _isLoading = false;
    });
    _formKey.currentState!.reset();
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return PostSignUp();
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

  //      ................email validator................
  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an email address';
    final emailPattern = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    if (!emailPattern.hasMatch(value))
      return 'Please enter a valid email address';

    return null;
  }

  //      ................password validator................
  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';

    final RegExp passwordPattern = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#^])[A-Za-z\d@$!%*?&#^]+$',
    );
    if (!passwordPattern.hasMatch(value))
      return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character';
    if (value.trim().length < 6)
      return 'Password length should be at least six letters';
    return null;
  }

  //      ................vpassword validator................
  String? _vpasswordValidator(String? value) {
    if (value == null || value.isEmpty || value != _password)
      return 'Password doesn\'t match';

    return null;
  }
}
