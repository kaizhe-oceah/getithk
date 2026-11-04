// Project imports:
import 'package:getithk/models/level_model.dart';
import 'package:getithk/models/user_model.dart';
import '../imports.dart';
import '../services/apple_auth_service.dart';
import '../services/facebook_auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/http_services/http_service_custom.dart';
import '../services/socket_service.dart';
import 'main_controller.dart';

class AppController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  UserModel? user;

  LevelModel? level;

  double points = 0;

  /// What the backpack holds (stock-summary's total_quantity): 我的卡牌.
  int cardCount = 0;

  bool _isLoggingOut = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Navigate to specific bottom nav tab
  void navigateToTab(int tabId) {
    context.read<MainController>().callbackSelectTab(tabId);
  }

  set setUser(UserModel value) {
    user = value;

    // Save to preferences
    AppPreferences.setUser(user: user!);

    update();
  }

  Future<void> signIn(ApiResponseModel response) async {
    final data = response.data;
    if (data is Map) {
      if (data["token"] != null) {
        await ApiService.updateApiToken(data["token"].toString());
      }
      if (data["level"] is Map) {
        level = LevelModel.fromJson(Map<String, dynamic>.from(data["level"]));
      }
      if (data["user"] is Map) {
        setUser = UserModel.fromJson(Map<String, dynamic>.from(data["user"]));
      }
    }

    HttpServiceCustom.resetSessionFlag();
    SocketService.joinSession();

    navigateToTab(kBottomNavHome);
    AppNavigator.popUntilFirst(context);
    AppNavigator.pushReplacementNamed(context, RouteName.mainPage);
  }

  Future<void> socialSignIn(
    SocialProvider provider, {
    String? referralCode,
  }) async {
    final String? token = await socialToken(provider);
    if (token == null) return;

    await ApiService.api.socialLogin(
      showLoader: true,
      provider: provider,
      token: token,
      referralCode: referralCode,
      onSuccess: (response) {
        response.showMessage();
        signIn(response);
      },
    );
  }

  /// Opens [provider]'s sign-in for its token; null if it isn't set up
  /// (with a toast), isn't live yet (coming soon dialog), was cancelled or
  /// failed.
  Future<String?> socialToken(SocialProvider provider) async {
    // Facebook and Apple only work on staging for now
    if (!ApiService.isTrial && provider != SocialProvider.google) {
      _socialComingSoon(provider);
      return null;
    }

    final Future<String?> Function()? getToken = switch (provider) {
      SocialProvider.google when GoogleAuthService.isConfigured =>
        GoogleAuthService.signIn,
      SocialProvider.facebook when FacebookAuthService.isConfigured =>
        FacebookAuthService.signIn,
      SocialProvider.apple when AppleAuthService.isConfigured =>
        AppleAuthService.signIn,
      _ => null,
    };
    if (getToken == null) {
      ToastHelper.showToast(
        context.tr(AppStrings.socialLoginUnavailable, args: [provider.label]),
      );
      return null;
    }

    return getToken();
  }

  void _socialComingSoon(SocialProvider provider) {
    DialogHelper<void>().appDialog(
      title: context.tr(AppStrings.comingSoon),
      description: context.tr(
        AppStrings.socialLoginUnavailable,
        args: [provider.label],
      ),
      rightButtonText: context.tr(AppStrings.okay),
      rightButtonColor: context.color.primary,
      rightTextColor: AppColors.whiteColor,
      rightFunction: () => AppNavigator.pop(context),
    );
  }

  /// Clears the session, then on to the login page; with [toHome] (an
  /// expired session) the home tab fades in instead, logged out.
  Future<void> logout({bool toHome = false}) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    Loader.show(status: "${context.tr(AppStrings.loggingOut)}...");
    SocketService.leaveSession();

    final String? token = await ApiService.getApiToken();
    if (token != null && token.isNotEmpty) {
      await ApiService.api.logout();
    }

    // without this, the next profile refresh would log the player back in
    await ApiService.deleteApiToken();
    await GoogleAuthService.signOut();
    await FacebookAuthService.signOut();
    // await NotificationService.deleteToken();
    // await NotificationService.getToken();
    AppPreferences.clearSharedPrefs();
    user = null;
    level = null;
    points = 0;
    cardCount = 0;
    ApiService.updateApiBaseUrl();

    context.read<ThemeController>().resetTheme();
    navigateToTab(kBottomNavHome);
    AppNavigator.popUntilFirst(context);
    if (toHome) {
      AppNavigator.pushReplacementNamedWithFade(context, RouteName.mainPage);
    } else {
      AppNavigator.pushReplacementNamed(context, RouteName.loginPage);
    }
    Loader.hide();
    _isLoggingOut = false;
  }

  Future<void> getWalletBalance() async {
    final token = await ApiService.getApiToken();
    if (token == null || token.isEmpty) return;

    await ApiService.api.getWalletBalance(
      onSuccess: (response) {
        final data = response.data;
        points = parseDouble(data is Map ? data['amount'] : null);
        update();
      },
    );
  }

  Future<void> getStockSummary() async {
    final token = await ApiService.getApiToken();
    if (token == null || token.isEmpty) return;

    await ApiService.api.getStockSummary(
      onSuccess: (response) {
        final data = response.data;
        cardCount = parseInt(data is Map ? data['total_quantity'] : null);
        update();
      },
    );
  }

  Future<void> getUser() async {
    final token = await ApiService.getApiToken();
    if (token == null || token.isEmpty) return;

    await ApiService.api.getProfile(
      onSuccess: (response) {
        final data = response.data;
        if (data is! Map) return;

        if (data["level"] is Map) {
          level = LevelModel.fromJson(Map<String, dynamic>.from(data["level"]));
        }
        if (data["user"] is Map) {
          // also notifies listeners
          setUser = UserModel.fromJson(Map<String, dynamic>.from(data["user"]));
        } else {
          update();
        }
      },
    );
  }
}
