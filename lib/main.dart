import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:quickshift/const/color.dart';
import 'package:quickshift/router.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  appWindow.title = "QuickShift";
  runApp(const ProviderScope(child: MyApp()));

  doWhenWindowReady(() {
    appWindow.show();
  });

  await WindowManipulator.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: titleBarColorDark,
            brightness: Brightness.dark,
          )),
      //themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
