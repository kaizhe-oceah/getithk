// Package imports:
import "package:bot_toast/bot_toast.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter_easyloading/flutter_easyloading.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:url_strategy/url_strategy.dart";

// Project imports:
import "components/default/lifecycle_manager.dart";
import "controllers/main_controller.dart";
import "firebase_options.dart";
import "routes/route_generator.dart";
import "../imports.dart";

@pragma("vm:entry-point")
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  printLog(
    "notification(${notificationResponse.id}) action tapped: "
    "${notificationResponse.actionId} with"
    "payload: ${notificationResponse.payload}",
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    printLog(
      "notification action tapped with input: ${notificationResponse.input}",
    );
  }
}

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfigs().loadJsonFromdir("assets/cfg/config.json");
  await EasyLocalization.ensureInitialized();
  await AppPreferences.init();
  await ApiService.init();

  if (!kIsWeb) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      if (e.toString().contains(
        'A Firebase App named "[DEFAULT]" already exists',
      )) {
        debugPrint("Firebase already initialized.");
      } else {
        rethrow;
      }
    }
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  HttpOverrides.global = MyHttpOverrides();

  // debugRepaintRainbowEnabled = true;

  // Only call clearSavedSettings() during testing to reset internal values.
  // await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  runApp(
    EasyLocalization(
      // Traditional Chinese (zh-TW.json) is the default language
      supportedLocales: const [Locale("zh", "TW"), Locale("en"), Locale("ms")],
      path: "assets/translations",
      startLocale: const Locale("zh", "TW"),
      fallbackLocale: const Locale("zh", "TW"),
      child: MultiProvider(
        providers: [
          // global controller
          ChangeNotifierProvider(create: (_) => AppController()),
          ChangeNotifierProvider(create: (_) => ThemeController()),

          // other controllers
          ChangeNotifierProvider(create: (_) => MainController()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);

  static AppNavigator appNavigatorObserver = AppNavigator();
  static BotToastNavigatorObserver botToastNavigatorObserver =
      BotToastNavigatorObserver();

  @override
  Widget build(BuildContext context) {
    final _themeController = Provider.of<ThemeController>(context);
    final screenSize = MediaQuery.of(context).size;
    final botToastBuilder = BotToastInit();

    // Dark backing so no white shows before the first route paints
    // (matches the native launch screen and the splash page).
    return ColoredBox(
      color: AppColors.darkBackgroundColor,
      child: ScreenUtilInit(
        designSize: kIsWeb
            ? Size(screenSize.width, screenSize.height)
            : (MediaQuery.of(context).size.shortestSide > 600
                  ? const Size(768, 1024) // Tablet
                  : const Size(375, 812)), // Phone
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            initialRoute: RouteInitial.getRouteInitial(),
            navigatorObservers: <NavigatorObserver>[
              appNavigatorObserver,
              AppNavigator.routeObserver,
              botToastNavigatorObserver,
              HeroineController(),
            ],
            scrollBehavior: kIsWeb
                ? const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.unknown,
                    },
                  )
                : null,
            navigatorKey: NavigationService.navigatorKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: "GetItHK",
            builder: (context, widget) {
              widget = EasyLoading.init()(context, widget);
              widget = botToastBuilder(context, widget);

              Widget app = Material(
                type: MaterialType.transparency,
                child: LifeCycleManager(
                  child: KeyboardVisibilityProvider(child: widget),
                ),
              );

              // if (kDebugMode) {
              //   app = CueDebugTools(child: app);
              // }

              return app;
            },
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
            theme: _themeController.theme,
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
