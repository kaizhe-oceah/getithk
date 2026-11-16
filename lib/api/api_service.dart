// Package imports:
import "package:flutter_secure_storage/flutter_secure_storage.dart";

// Project imports:
import "../imports.dart";
import "api.dart";

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static late Api _api;
  static Api get api => _api;
  static const _flutterSecureStorage = FlutterSecureStorage();

  // true: the trial API (api_trial_base_url), false: live (api_base_url);
  // set by [loadApiMode]
  static bool isTrial = false;

  static const Duration _settingsTimeout = Duration(seconds: 5);

  static Future<void> init() async {
    updateApiBaseUrl();
    if (AppPreferences.instance.getBool(SP_FIRST_RUN) ?? true) {
      FlutterSecureStorage storage = const FlutterSecureStorage();
      await storage.deleteAll();
      AppPreferences.instance.setBool(SP_FIRST_RUN, false);
    }
  }

  static void updateApiBaseUrl({
    UserRole? role,
    bool useSharedPrefs = true,
    String? username,
    bool isDemoMode = false,
  }) {
    final String baseUrl = isTrial
        ? GlobalConfigs().get("api_trial_base_url")
        : GlobalConfigs().get("api_base_url");

    final String apiUrl = baseUrl;

    printLog("API URL : $apiUrl");

    _api = Api(apiUrl: apiUrl);
  }

  /// Asks the live API's /app/settings which API to use: staging (the trial
  /// one) when data.app_setting is true, else live; live too if it can't be
  /// reached in time. Silent: no loader, toast or dialog.
  static Future<void> loadApiMode() async {
    bool trial = false;

    try {
      await Api(apiUrl: GlobalConfigs().get("api_base_url"))
          .getAppSettings(
            onSuccess: (response) {
              final dynamic data = response.data;
              trial = data is Map && parseBool(data["app_setting"]);
            },
            onError: (_) {},
          )
          .timeout(_settingsTimeout);
    } catch (e) {
      printLog("--- loadApiMode error: $e");
    }

    isTrial = trial;
    updateApiBaseUrl();
  }

  static Future<void> updateApiToken(String token) async {
    try {
      printLog("--- updateApiToken");
      return await _flutterSecureStorage.write(key: "apiToken", value: token);
    } catch (e) {
      printLog("--- updateApiToken error: $e");
      return;
    }
  }

  static Future<void> deleteApiToken() async {
    try {
      return await _flutterSecureStorage.delete(key: "apiToken");
    } catch (e) {
      return;
    }
  }

  static Future<String?> getApiToken() async {
    try {
      return await _flutterSecureStorage.read(key: "apiToken");
    } catch (e) {
      return null;
    }
  }
}
