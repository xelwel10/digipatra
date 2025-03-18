import 'package:flutter/material.dart';
import 'package:simple_app/core/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Badapatra',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: MyApp.navigatorKey,
      initialRoute: AppRoute.homeRoute,
      routes: AppRoute.getAppRoutes(),
    );
  }
}
