// Package imports:
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:page_transition/page_transition.dart";

// Project imports:
import "../imports.dart";
import "../pages/activity_page.dart";
import "../pages/backpack_page.dart";
import "../pages/home_page.dart";
import "../pages/invite_friends_page.dart";
import "../pages/login_page.dart";
import "../pages/main_page.dart";
import "../pages/profile_page.dart";
import "../pages/splash_page.dart";
import "../pages/tnc_page.dart";
import "../pages/topup_page.dart";

class RouteGenerator {
  static Route? generateRoute(RouteSettings settings) {
    final Widget? page = _page(settings);
    if (page == null) return null;

    return MaterialWithModalsPageRoute(
      settings: settings,
      builder: (context) => page,
    );
  }

  /// Same pages as [generateRoute], shown instantly with no transition.
  static Route? generateRouteWithoutTransition(RouteSettings settings) {
    final Widget? page = _page(settings);
    if (page == null) return null;

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (context, animation, secondaryAnimation) => page,
    );
  }

  static Widget? _page(RouteSettings settings) {
    final uri = Uri.parse(settings.name!);

    switch (uri.path) {
      case RouteName.splashPage:
        return const SplashPage();

      case RouteName.mainPage:
        return const MainPage();

      case RouteName.loginPage:
        return const LoginPage();

      case RouteName.registerPage:
        return const LoginPage(isRegister: true);

      case RouteName.homePage:
        return const HomePage();

      case RouteName.backpackPage:
        return const BackpackPage();

      case RouteName.activityPage:
        return const ActivityPage();

      case RouteName.profilePage:
        return const ProfilePage();

      // arguments: the TncType to show (terms of service by default)
      case RouteName.inviteFriendsPage:
        return const InviteFriendsPage();

      case RouteName.topupPage:
        return const TopupPage();

      case RouteName.tncPage:
        final Object? type = settings.arguments;
        return TncPage(type: type is TncType ? type : TncType.terms);

      default:
        return null;
    }
  }
}

PageTransition customPageTransition({
  required Widget child,
  required RouteSettings settings,
  PageTransitionType? type,
}) {
  return PageTransition(
    settings: settings,
    type: type ?? PageTransitionType.rightToLeft,
    isIos: kIsWeb
        ? false
        : Platform.isIOS
        ? true
        : false,
    child: child,
  );
}

class CupertinoRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;
  CupertinoRoute({required this.exitPage, required this.enterPage})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return enterPage;
            },
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return Stack(
                children: <Widget>[
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.0, 0.0),
                          end: const Offset(-0.33, 0.0),
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.linearToEaseOut,
                            reverseCurve: Curves.easeInToLinear,
                          ),
                        ),
                    child: exitPage,
                  ),
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.linearToEaseOut,
                            reverseCurve: Curves.easeInToLinear,
                          ),
                        ),
                    child: enterPage,
                  ),
                ],
              );
            },
      );
}
