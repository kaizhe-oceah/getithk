class RouteName {
  static const String splashPage = '/splash';
  static const String mainPage = '/main';
  static const String loginPage = '/login';
  static const String registerPage = '/register';
  static const String homePage = '/home';
  static const String cartPage = '/cart';
  static const String favouritePage = '/favourite';
  static const String personPage = '/person';

  static List<String> allRoutes = [
    splashPage,
    mainPage,
    loginPage,
    registerPage,
    homePage,
    cartPage,
    favouritePage,
    personPage,
  ];

  static bool containsRoute(String routeName) {
    return allRoutes.contains(routeName);
  }
}
