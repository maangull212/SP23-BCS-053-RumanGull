import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/game_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Style the status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const NumQuestApp(),
    ),
  );
}

class NumQuestApp extends StatelessWidget {
  const NumQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NumQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const HomeScreen(),
        '/game': (ctx) => const GameScreen(),
        '/result': (ctx) => const ResultScreen(),
        '/history': (ctx) => const HistoryScreen(),
      },
    );
  }
}
