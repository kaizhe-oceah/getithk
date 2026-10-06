// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../imports.dart';
import '../models/user_model.dart';

// SHARED PREFERRENCE
const SP_FIRST_RUN = "sp_first_run";
const SP_USER = "spUser";
const themeRoleKey = "themeRole";

class AppPreferences {
  static late final SharedPreferences _instance;

  static Future<SharedPreferences> init() async =>
      _instance = await SharedPreferences.getInstance();

  static SharedPreferences get instance => _instance;

  static Future<void> clearSharedPrefs({bool isClearAll = false}) async {
    if (isClearAll) {
      _instance.clear();
    } else {
      clearMultipleSp(spList: [SP_USER, themeRoleKey]);
    }
  }

  static Future<void> clearMultipleSp({required List<String> spList}) async {
    for (var element in spList) {
      _instance.remove(element);
    }
  }

  static Future<void> setUser({required UserModel user}) async {
    printLog("json.encode(user.toJson()) : ${json.encode(user.toJson())}");
    _instance.setString(SP_USER, json.encode(user.toJson()));
  }

  static UserModel? getUser() {
    UserModel? _user;
    if (_instance.containsKey(SP_USER)) {
      _user = UserModel.fromJson(json.decode(_instance.getString(SP_USER)!));
    }
    return _user;
  }

  ///
  /// Theme color role management
  ///

  static Future<void> setThemeRole(UserRole role) async {
    await _instance.setString(themeRoleKey, role.name);
  }

  static UserRole getThemeRole() {
    final roleStr = _instance.getString(themeRoleKey);
    return UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => UserRole.user,
    );
  }
}
