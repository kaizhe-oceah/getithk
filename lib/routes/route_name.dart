class RouteName {
  static const String splashPage = '/splash';
  static const String mainPage = '/main';
  static const String loginPage = '/login';
  static const String registerPage = '/register';

  static List<String> allRoutes = [
    splashPage,
    mainPage,
    loginPage,
    registerPage,
  ];

  static bool containsRoute(String routeName) {
    return allRoutes.contains(routeName);
  }
}
