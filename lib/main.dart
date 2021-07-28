import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './Screens/homescreen.dart';
import 'Screens/coordinate.dart';
import 'Screens/address.dart';
import 'Screens/distance.dart';

import 'Models/routes.dart';

void main() {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Locator',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: HomeScreen(),
      routes: {
        Routes.coordinate: (ctx) => Coordinates(),
        Routes.address: (ctx) => Address(),
        Routes.distance: (ctx) => Distance(),
      },
    );
  }
}
