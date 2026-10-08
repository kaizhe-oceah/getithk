class RouteName {
  static const String splashPage = '/splash';
  static const String mainPage = '/main';
  static const String loginPage = '/login';
  static const String registerPage = '/register';
  static const String homePage = '/home';
  static const String backpackPage = '/backpack';
  static const String activityPage = '/activity';
  static const String profilePage = '/profile';
  static const String tncPage = '/tnc';
  static const String inviteFriendsPage = '/invite-friends';
  static const String topupPage = '/top-up';

  static List<String> allRoutes = [
    splashPage,
    mainPage,
    loginPage,
    registerPage,
    homePage,
    backpackPage,
    activityPage,
    profilePage,
    tncPage,
    inviteFriendsPage,
    topupPage,
  ];

  static bool containsRoute(String routeName) {
    return allRoutes.contains(routeName);
  }
}
