import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// enum themeMode {
//   dark,
//   light,
//   system,
// }

class themeSettingNotify extends StateNotifier<ThemeMode> {
  themeSettingNotify() : super(ThemeMode.system);

  void changeTheme(ThemeMode mode) {
    state = mode;
  }
}

final themeSetting =
    StateNotifierProvider<themeSettingNotify, ThemeMode>((ref) {
  return themeSettingNotify();
});
