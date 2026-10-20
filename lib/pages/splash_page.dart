// Package imports:
import 'package:upgrader/upgrader.dart';

// Project imports:
import '../components/splash_view.dart';
import '../controllers/home_controller.dart';
import '../imports.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';

// import '../services/network_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final Upgrader upgrader = Upgrader(durationUntilAlertAgain: Duration.zero);

  /// Light icons, on the dark splash.
  static const SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle.light;

  late final AnimationController _introController = AnimationController(
    vsync: this,
    duration: SplashView.introDuration,
  );

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      HomeController.preload().ignore();

      await SplashView.precache(context);
      if (!mounted) return;

      _checkForUpdate();

      await _introController.forward();
      if (!mounted) return;

      // access some services
      await 0.001.delay();
      NotificationService.shouldListenNotification();

      if (AppPreferences.getUser() != null) {
        await context.read<ThemeController>().loadTheme();
        if (!mounted) return;
        context.read<AppController>().setUser = AppPreferences.getUser()!;

        ApiService.updateApiBaseUrl(role: AppPreferences.getThemeRole());
        SocketService.connect();
      }

      AppNavigator.pushReplacementNamedWithFade(
        context,
        RouteName.mainPage,
        fromStyle: _overlayStyle,
      );
    });
  }

  Future<void> _checkForUpdate() async {
    final bool isAvailable = await upgrader
        .initialize()
        .then((_) => upgrader.isUpdateAvailable())
        .catchError((Object _) => false);
    if (!isAvailable) return;

    final BuildContext context = NavigationService.context;
    DialogHelper().showNormalDialog(
      barrierDismissible: false,
      title: context.tr(AppStrings.newVersion),
      description: context.tr(
        AppStrings.newVersionDescAppNameOldVersionNewVersionChanges,
        args: [
          upgrader.appName(),
          upgrader.appName(),
          "${upgrader.currentInstalledVersion}",
          "${upgrader.currentAppStoreVersion}",
          (upgrader.releaseNotes ?? "Changes:\n- Improved app performance"),
        ],
      ),
      rightButtonText: context.tr(AppStrings.update),
      rightFunction: () {
        upgrader.sendUserToAppStore();
      },
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: AppColors.darkBackgroundColor,
      forceOverlayStyle: _overlayStyle,
      child: AnimatedBuilder(
        animation: _introController,
        builder: (context, _) => SplashView(progress: _introController.value),
      ),
    );
  }
}
