// Project imports:
import 'package:getithk/models/level_model.dart';
import 'package:getithk/models/user_model.dart';
import '../imports.dart';
import '../services/http_services/http_service_custom.dart';
import 'main_controller.dart';

class AppController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  UserModel? user;

  LevelModel? level;

  double points = 0;

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

    // a new session: let a later expiry log out again
    HttpServiceCustom.resetSessionFlag();

    navigateToTab(kBottomNavHome);
    AppNavigator.popUntilFirst(context);
    AppNavigator.pushReplacementNamed(context, RouteName.mainPage);
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    Loader.show(status: "${context.tr(AppStrings.loggingOut)}...");

    final String? token = await ApiService.getApiToken();
    if (token != null && token.isNotEmpty) {
      await ApiService.api.logout();
    }

    // without this, the next profile refresh would log the player back in
    await ApiService.deleteApiToken();
    // await NotificationService.deleteToken();
    // await NotificationService.getToken();
    AppPreferences.clearSharedPrefs();
    user = null;
    level = null;
    points = 0;
    ApiService.updateApiBaseUrl();

    context.read<ThemeController>().resetTheme();
    navigateToTab(kBottomNavHome);
    AppNavigator.popUntilFirst(context);
    AppNavigator.pushReplacementNamed(context, RouteName.loginPage);
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
