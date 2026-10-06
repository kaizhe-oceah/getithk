// Project imports:
import 'package:getithk/models/user_model.dart';
import 'package:getithk/services/notification_service.dart';
import '../imports.dart';
import 'main_controller.dart';

class AppController with ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  UserModel? user;

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

  Future<void> logout() async {
    Loader.show(status: "${context.tr(AppStrings.loggingOut)}...");

    // await ApiService.api.logout(onSuccess: (_) {});
    // await ApiService.deleteApiToken();
    // await NotificationService.deleteToken();
    // await NotificationService.getToken();
    AppPreferences.clearSharedPrefs();
    user = null;
    ApiService.updateApiBaseUrl();

    context.read<ThemeController>().resetTheme();
    navigateToTab(kBottomNavHome);
    AppNavigator.popUntilFirst(context);
    AppNavigator.pushReplacementNamed(context, RouteName.loginPage);
    Loader.hide();
  }

  Future<void> getUser() async {
    final token = await ApiService.getApiToken();
    if (token == null || token.isEmpty) return;

    await ApiService.api.getCustomerProfile(
      onSuccess: (response) {
        if (response.data != null) {
          setUser = UserModel.fromJson(response.data);
        }
      },
    );
  }
}
