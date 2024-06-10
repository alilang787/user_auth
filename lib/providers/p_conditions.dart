import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//  -----------  isSignInAllowed provider ------------

class isSignInAllowedNotify extends StateNotifier<bool> {
  isSignInAllowedNotify() : super(true);

  void fetchdata() async {
    final prefs = await SharedPreferences.getInstance();
    final val =await prefs.getBool('isSignInAllowed') ?? true;
    state = val;
  }

  void changeVal(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignInAllowed',val);
    state = val;
  }
}

final isSignInAllowed =
    StateNotifierProvider<isSignInAllowedNotify, bool>((ref) {
  return isSignInAllowedNotify();
});
