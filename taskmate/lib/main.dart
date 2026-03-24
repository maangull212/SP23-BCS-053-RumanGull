// Updated main.dart (no ToastService navigator key call needed for host version)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notifications/notifications_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationsService.instance.init();
  NotificationsService.instance.setNavigatorKey(navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: TaskmateApp(navigatorKey: navigatorKey),
    ),
  );
}
