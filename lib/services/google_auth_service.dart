// Package imports:
import 'package:google_sign_in/google_sign_in.dart';

// Project imports:
import '../imports.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _initialization;

  static String get _serverClientId =>
      GlobalConfigs().get<String>('google_server_client_id') ?? '';
  static String get _iosClientId =>
      GlobalConfigs().get<String>('google_ios_client_id') ?? '';

  static bool get isConfigured =>
      _serverClientId.isNotEmpty &&
      (!Platform.isIOS || _iosClientId.isNotEmpty);

  static Future<void> _initialize() =>
      _initialization ??= _googleSignIn.initialize(
        clientId: Platform.isIOS ? _iosClientId : null,
        serverClientId: _serverClientId,
      );

  static Future<String?> signIn() async {
    try {
      await _initialize();
      await _googleSignIn.signOut();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null) {
        printLog('Google sign-in: no ID token; check google_server_client_id');
        ToastHelper.error(
          NavigationService.context.tr(AppStrings.somethingWentWrong),
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }

      printLog('Google sign-in failed: ${e.code} ${e.description}');
      ToastHelper.error(
        NavigationService.context.tr(AppStrings.somethingWentWrong),
      );
      return null;
    }
  }

  static Future<void> signOut() async {
    if (_initialization == null) return;
    await _googleSignIn.signOut();
  }
}
