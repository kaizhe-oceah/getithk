// Package imports:
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// Project imports:
import '../imports.dart';

class FacebookAuthService {
  static FacebookAuth get _facebookAuth => FacebookAuth.instance;

  static bool get isConfigured =>
      (GlobalConfigs().get<String>('facebook_app_id') ?? '').isNotEmpty;

  static Future<String?> signIn() async {
    try {
      await _facebookAuth.logOut();

      final LoginResult result = await _facebookAuth.login();
      switch (result.status) {
        case LoginStatus.success:
          final String? token = result.accessToken?.tokenString;
          if (token == null) _failed('no access token');
          return token;
        case LoginStatus.cancelled:
        case LoginStatus.operationInProgress:
          return null;
        case LoginStatus.failed:
          _failed(result.message ?? 'failed');
          return null;
      }
    } on PlatformException catch (e) {
      _failed('${e.code} ${e.message}');
      return null;
    }
  }

  static Future<void> signOut() async {
    if (!isConfigured) return;
    await _facebookAuth.logOut();
  }

  static void _failed(String reason) {
    printLog('Facebook login failed: $reason');
    ToastHelper.error(
      NavigationService.context.tr(AppStrings.somethingWentWrong),
    );
  }
}
