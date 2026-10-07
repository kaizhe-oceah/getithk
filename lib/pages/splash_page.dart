// Package imports:
import 'package:upgrader/upgrader.dart';

// Project imports:
import '../components/splash_view.dart';
import '../imports.dart';
import '../services/notification_service.dart';

// import '../services/network_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final Upgrader upgrader = Upgrader(durationUntilAlertAgain: Duration.zero);

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
      await SplashView.precache(context);
      if (!mounted) return;

      // check app version while the intro animation plays
      final Future<bool> updateCheck = upgrader.initialize().then(
        (_) => upgrader.isUpdateAvailable(),
      );
      await _introController.forward();
      bool isAvailable = await updateCheck;
      if (!mounted) return;

      if (isAvailable) {
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
        return;
      }

      // access some services
      await 0.001.delay();
      NotificationService.shouldListenNotification();
      // NetworkService.shouldListenNetwork();

      // restore the saved user, if any
      if (AppPreferences.getUser() != null) {
        await context.read<ThemeController>().loadTheme();
        if (!mounted) return;
        context.read<AppController>().setUser = AppPreferences.getUser()!;

        // update api path name follow by role
        ApiService.updateApiBaseUrl(role: AppPreferences.getThemeRole());
      }

      // always open on the home tab, logged in or not
      AppNavigator.pushReplacementNamedWithoutTransition(
        context,
        RouteName.mainPage,
      );
    });
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
      forceOverlayStyle: SystemUiOverlayStyle.light,
      child: AnimatedBuilder(
        animation: _introController,
        builder: (context, _) => SplashView(progress: _introController.value),
      ),
    );
  }
}
