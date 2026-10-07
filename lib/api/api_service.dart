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
    const bool isTrial = true;

    final String baseUrl = isTrial
        ? GlobalConfigs().get("api_trial_base_url")
        // ignore: dead_code
        : GlobalConfigs().get("api_base_url");

    final String apiUrl = baseUrl;

    printLog("API URL : $apiUrl");

    _api = Api(apiUrl: apiUrl);
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
