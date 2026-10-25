import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/settings.dart';
import 'services/native_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final settings = await AppSettingsController.load();
  final accent = await SystemAccent.load();
  runApp(CognitiveShufflerApp(settings: settings, systemAccent: accent));
}
