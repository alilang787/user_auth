import 'package:user_auth/providers/p_conditions.dart';
import 'package:user_auth/providers/p_theme_mode.dart';
import 'package:user_auth/screens/s_auth_main.dart';
import 'package:user_auth/screens/s_post_signup.dart';
import 'package:user_auth/screens/s_welcome.dart';
import 'package:user_auth/themes/dark.dart';
import 'package:user_auth/themes/light.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

//  -------------------  main function ---------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  // );
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/bungee/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(ProviderScope(child: const MainApp()));
}

//  -------------------  App Main Widget ---------------------

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  bool _postSignUp = false;

  void _authConditions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final isSignInAllowed = await prefs.getBool('isSignInAllowed') ?? true;
    // await prefs.setBool('postSignUp',false) ;
    final postSignUp = await prefs.getBool('postSignUp') ?? false;

    setState(() {
      _postSignUp = postSignUp;
    });
  }

  @override
  void initState() {
    super.initState();
    _authConditions();
    ref.read(isSignInAllowed.notifier).fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    //  ------------ Material App ----------

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // debugShowCheckedModeBanner: false,
      title: 'User Auth',

      themeMode: ref.watch(themeSetting),
      theme: lighTheme,
      darkTheme: darkTheme,

      // ------------- Home Stream Builder ----------

      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            if (_postSignUp) return PostSignUp();
            if (!_postSignUp) {
              bool _isSignInAllowed = ref.watch(isSignInAllowed);
              if (_isSignInAllowed) return WelcomeScreen();
            }
          }
          return UserAuthMain();
        },
      ),
    );
  }
}
