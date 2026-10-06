// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../controllers/app_controller.dart';
import '../models/route_stack_item_model.dart';
import '../routes/route_generator.dart';
import '../routes/route_name.dart';
import '../utils/utilities.dart';

class AppNavigator extends NavigatorObserver {
  static final navStack = <RouteStackItemModel>[];

  /// Observer pages can subscribe to (via [RouteAware]) to learn when a route
  /// above them pops back — e.g. to refresh after a payment webview that
  /// *replaced* its launcher page closes. Registered on the [MaterialApp].
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();

  static bool hasRoute(String routeName) {
    return navStack.any((e) => e.name == routeName);
  }

  static void popUntil(BuildContext context, String routeName) {
    for (var element in navStack) {
      printLog("popUntil nav stack name: ${element.name}");
    }

    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, ModalRoute.withName(routeName));
    }
  }

  static void pop<T>(BuildContext context, [T? result]) {
    for (var element in navStack) {
      printLog("pop nav stack name: ${element.name}");
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  static void popUntilFirstWithResult<T>(BuildContext context, [T? result]) {
    for (var element in navStack) {
      printLog("popUntilFirstWithResult nav stack name: ${element.name}");
    }

    while (navStack.length > 1) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, result);
      } else {
        break;
      }
    }
  }

  static void popUntilWithResult<T>(
    BuildContext context,
    String routeName, [
    T? result,
  ]) {
    for (var element in navStack) {
      printLog("popUntilWithResult nav stack name: ${element.name}");
    }

    while (navStack.length > 1) {
      if (Navigator.canPop(context)) {
        if (navStack.last.name == routeName) {
          break;
        }

        Navigator.pop(context, result);
      } else {
        break;
      }
    }
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget widget,
  ) {
    final settings = ModalRoute.of(context)?.settings;

    return Navigator.push(
      context,
      MaterialWithModalsPageRoute(
        settings: settings,
        builder: (context) => widget,
      ),
    );
  }

  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
    bool isRefreshUser = false,
  }) async {
    if (!RouteName.containsRoute(routeName)) {
      printLog("pushNamed route error: $routeName");
      return Future.value();
    }

    if (parameters != null) {
      final uri = Uri(path: routeName, queryParameters: parameters);
      routeName = uri.toString();
    }

    final result = await Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );

    if (isRefreshUser && context.mounted) {
      context.read<AppController>().getUser();
    }

    return result;
  }

  static Future<T?> pushReplacementNamed<T>(
    BuildContext context,
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    if (!RouteName.containsRoute(routeName)) {
      printLog("pushReplacementNamed route error: $routeName");
      return Future.value();
    }

    if (parameters != null) {
      final uri = Uri(path: routeName, queryParameters: parameters);
      routeName = uri.toString();
    }

    return Navigator.of(
      context,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// [pushReplacementNamed] without a page transition.
  static Future<dynamic> pushReplacementNamedWithoutTransition(
    BuildContext context,
    String routeName, {
    dynamic arguments,
  }) {
    final route = RouteGenerator.generateRouteWithoutTransition(
      RouteSettings(name: routeName, arguments: arguments),
    );
    if (route == null) {
      printLog("pushReplacementNamedWithoutTransition route error: $routeName");
      return Future.value();
    }

    return Navigator.of(context).pushReplacement(route);
  }

  static Future<T?> pushNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    required String removeUntil,
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    if (!RouteName.containsRoute(routeName)) {
      printLog("pushNamedAndRemoveUntil route error: $routeName");
      return Future.value();
    }

    if (parameters != null) {
      final uri = Uri(path: routeName, queryParameters: parameters);
      routeName = uri.toString();
    }

    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      ModalRoute.withName(removeUntil),
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamedAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    required String removeUntil,
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    if (!RouteName.containsRoute(routeName)) {
      printLog("pushReplacementNamedAndRemoveUntil route error: $routeName");
      return Future.value();
    }

    if (parameters != null) {
      final uri = Uri(path: routeName, queryParameters: parameters);
      routeName = uri.toString();
    }

    // Pop routes until removeUntil, then replace that route with the new one
    Navigator.popUntil(context, ModalRoute.withName(removeUntil));
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static void popUntilFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  ///
  ///
  ///
  ///

  @override
  void didPop(Route route, Route? previousRoute) {
    navStack.removeWhere((e) => e.name == route.settings.name);

    printLog("======== didPop: ${route.settings.name}");
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    navStack.add(RouteStackItemModel.fromRoute(route));

    printLog("======== didPush: ${route.settings.name}");
    super.didPush(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    navStack.removeWhere((e) => e.name == route.settings.name);

    printLog("======== didRemove: ${route.settings.name}");
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null) {
      navStack.removeWhere((e) => e.name == oldRoute.settings.name);
    }
    if (newRoute != null) {
      navStack.add(RouteStackItemModel.fromRoute(newRoute));
    }

    printLog("======== didReplace");
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
