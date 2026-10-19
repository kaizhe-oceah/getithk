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
  static const String topupRewardPage = '/top-up-reward';
  static const String subProductPage = '/sub-product';
  static const String prizeResultPage = '/prize-result';
  static const String checkoutPage = '/checkout';
  static const String addressPage = "/address-page";
  static const String addAddressPage = "/add-address-page";
  static const String myOrdersPage = '/my-orders';
  static const String orderDetailsPage = '/order-details';
  static const String vouhcerPage = "/voucher-page";
  static const String webviewPage = '/webview';

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
    topupRewardPage,
    subProductPage,
    prizeResultPage,
    checkoutPage,
    addressPage,
    addAddressPage,
    myOrdersPage,
    orderDetailsPage,
    vouhcerPage,
    webviewPage,
  ];

  static bool containsRoute(String routeName) {
    return allRoutes.contains(routeName);
  }
}
