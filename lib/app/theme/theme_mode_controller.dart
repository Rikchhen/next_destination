import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';

@immutable
class ThemeSettings {
  final ThemeMode themeMode;
  final bool autoDarkModeEnabled;

  const ThemeSettings({
    required this.themeMode,
    required this.autoDarkModeEnabled,
  });

  ThemeSettings copyWith({ThemeMode? themeMode, bool? autoDarkModeEnabled}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      autoDarkModeEnabled: autoDarkModeEnabled ?? this.autoDarkModeEnabled,
    );
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeSettings>(
      () => ThemeModeController(),
    );

final activeThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeControllerProvider).themeMode;
});

class ThemeModeController extends Notifier<ThemeSettings> {
  StreamSubscription<int>? _lightSubscription;

  @override
  ThemeSettings build() {
    ref.onDispose(stopAutoByLight);
    return const ThemeSettings(
      themeMode: ThemeMode.light,
      autoDarkModeEnabled: false,
    );
  }

  void startAutoByLight() {
    if (state.autoDarkModeEnabled) return;
    state = state.copyWith(autoDarkModeEnabled: true);

    try {
      _lightSubscription ??= Light().lightSensorStream.listen(
        (lux) {
          // Hysteresis to avoid rapid flicker around threshold.
          if (lux <= 25 && state.themeMode != ThemeMode.dark) {
            state = state.copyWith(themeMode: ThemeMode.dark);
          } else if (lux >= 45 && state.themeMode != ThemeMode.light) {
            state = state.copyWith(themeMode: ThemeMode.light);
          }
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {}
  }

  void stopAutoByLight() {
    _lightSubscription?.cancel();
    _lightSubscription = null;
    if (state.autoDarkModeEnabled || state.themeMode != ThemeMode.light) {
      state = state.copyWith(
        autoDarkModeEnabled: false,
        themeMode: ThemeMode.light,
      );
    }
  }

  void setAutoDarkModeEnabled(bool enabled) {
    if (enabled) {
      startAutoByLight();
    } else {
      stopAutoByLight();
    }
  }
}
