// Package imports:
import "package:getithk/pages/address_page.dart";
import "package:getithk/pages/voucher_page.dart";
import "package:modal_bottom_sheet/modal_bottom_sheet.dart";
import "package:page_transition/page_transition.dart";

// Project imports:
import "../imports.dart";
import "../pages/activity_page.dart";
import "../pages/add_address_page.dart";
import "../pages/backpack_page.dart";
import "../pages/checkout_page.dart";
import "../pages/home_page.dart";
import "../pages/invite_friends_page.dart";
import "../pages/login_page.dart";
import "../pages/main_page.dart";
import "../pages/my_orders_page.dart";
import "../pages/order_details_page.dart";
import "../pages/profile_page.dart";
import "../models/address_model.dart";
import "../models/draw_result_model.dart";
import "../models/main_product_model.dart";
import "../models/shipment_item_model.dart";
import "../pages/prize_result_page.dart";
import "../pages/splash_page.dart";
import "../pages/sub_product_page.dart";
import "../pages/tnc_page.dart";
import "../pages/topup_page.dart";
import "../pages/topup_reward_page.dart";
import "../pages/webview_page.dart";

class RouteGenerator {
  static Route? generateRoute(RouteSettings settings) {
    final Widget? page = _page(settings);
    if (page == null) return null;

    return MaterialWithModalsPageRoute(
      settings: settings,
      builder: (context) => page,
    );
  }

  static const Duration _fadeDuration = Duration(milliseconds: 750);

  static Route? generateFadeRoute(
    RouteSettings settings, {
    SystemUiOverlayStyle? fromStyle,
  }) {
    final Widget? page = _page(settings);
    if (page == null) return null;

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: _fadeDuration,
      reverseTransitionDuration: _fadeDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.15, 1, curve: Curves.easeInOutCubic),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.03, end: 1).animate(curved),
                child: child,
              ),
            ),
            if (fromStyle != null)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: curved,
                  builder: (context, _) =>
                      animation.status == AnimationStatus.forward &&
                          curved.value < 0.5
                      ? AnnotatedRegion<SystemUiOverlayStyle>(
                          value: fromStyle,
                          child: const SizedBox.expand(),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
          ],
        );
      },
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

      case RouteName.inviteFriendsPage:
        return const InviteFriendsPage();

      case RouteName.topupRewardPage:
        return const TopupRewardPage();

      case RouteName.vouhcerPage:
        return const VoucherPage();

      case RouteName.topupPage:
        return const TopupPage();

      case RouteName.subProductPage:
        final Object? product = settings.arguments;
        return product is MainProductModel
            ? SubProductPage(product: product)
            : null;

      case RouteName.prizeResultPage:
        final Object? result = settings.arguments;
        return result is DrawResultModel
            ? PrizeResultPage(result: result)
            : null;

      case RouteName.checkoutPage:
        final Object? items = settings.arguments;
        return items is List<ShipmentItemModel>
            ? CheckoutPage(items: items)
            : null;

      case RouteName.tncPage:
        final Object? type = settings.arguments;
        return TncPage(type: type is TncType ? type : TncType.terms);

      case RouteName.addressPage:
        final Object? arguments = settings.arguments;
        return arguments is ({bool isSelect, int? selectedId})
            ? AddressPage(
                isSelect: arguments.isSelect,
                selectedId: arguments.selectedId,
              )
            : const AddressPage();

      case RouteName.myOrdersPage:
        return const MyOrdersPage();

      case RouteName.orderDetailsPage:
        final Object? shippingId = settings.arguments;
        return shippingId is int
            ? OrderDetailsPage(shippingId: shippingId)
            : null;

      // arguments: {"url": …, "title": …, "returnPath": …}; it pops with
      // "close1" / "close0" when the page says so, or returnPath's `status`
      case RouteName.webviewPage:
        final Object? arguments = settings.arguments;
        if (arguments is! Map || arguments['url'] is! String) return null;
        return WebviewPage(
          url: arguments['url'],
          title: arguments['title']?.toString(),
          returnPath: arguments['returnPath']?.toString(),
        );

      case RouteName.addAddressPage:
        final Object? arguments = settings.arguments;
        return AddAddressPage(
          address: arguments is AddressModel ? arguments : null,
          isDefault: arguments == true,
        );

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
