import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:taskmate/app.dart';
import 'package:taskmate/providers/theme_provider.dart';
import 'package:taskmate/providers/task_provider.dart';
import 'package:taskmate/providers/auth_provider.dart';
import 'package:taskmate/providers/settings_provider.dart';

void main() {
  testWidgets('App smoke test — renders without crashing',
      (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: TaskmateApp(navigatorKey: navigatorKey),
      ),
    );

    // App should render the title somewhere
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
