// Package imports:
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Project imports:
import '../imports.dart';

class AppleAuthService {
  static String get _serviceId =>
      GlobalConfigs().get<String>('apple_service_id') ?? '';
  static String get _redirectUri =>
      GlobalConfigs().get<String>('apple_redirect_uri') ?? '';

  static bool get isConfigured =>
      Platform.isIOS || (_serviceId.isNotEmpty && _redirectUri.isNotEmpty);

  /// The identity token; null if the sheet was closed, or it failed (with a
  /// toast).
  static Future<String?> signIn() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            webAuthenticationOptions: Platform.isIOS
                ? null
                : WebAuthenticationOptions(
                    clientId: _serviceId,
                    redirectUri: Uri.parse(_redirectUri),
                  ),
          );

      final String? identityToken = credential.identityToken;
      if (identityToken == null) _failed('no identity token');
      return identityToken;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        _failed('${e.code} ${e.message}');
      }
      return null;
    } on SignInWithAppleException catch (e) {
      _failed('$e');
      return null;
    }
  }

  static void _failed(String reason) {
    printLog('Apple sign-in failed: $reason');
    ToastHelper.error(
      NavigationService.context.tr(AppStrings.somethingWentWrong),
    );
  }
}
