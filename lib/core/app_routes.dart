import 'package:simple_app/view/home_view.dart';

class AppRoute {
  AppRoute._();

  static const String homeRoute = '/home';

  static getAppRoutes() {
    return {
      homeRoute: (context) => const HomePageView(),
    };
  }
}
