import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/app/app.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();

  // Shared Preferences object : because shared prefs is async and provider is sync

  // Shared Prefs object
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: App(),
    ),
  );
}
