// Package imports:
import 'package:socket_io_client/socket_io_client.dart' as io;

// Project imports:
import '../imports.dart';

/// Live connection to the backend. It listens for the server saying this
/// session was kicked (e.g. the account logged in on another device), so the
/// player is logged out right away instead of on their next API call.
class SocketService {
  static io.Socket? _socket;

  /// Connects with the saved token, replacing any earlier connection.
  /// Does nothing when logged out or when `socket_url` isn't configured.
  static Future<void> connect() async {
    final String? url = GlobalConfigs().get("socket_url");
    final String? token = await ApiService.getApiToken();

    disconnect();
    if (url == null || url.isEmpty || token == null || token.isEmpty) return;

    final socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(["websocket"])
          // the server reads the token from one of these
          .setAuth({"token": token})
          .setExtraHeaders({"Authorization": "Bearer $token"})
          // a fresh connection per token, not the cached one from before
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) => printLog("Socket connected"));
    socket.onConnectError((error) => printLog("Socket connect error: $error"));
    socket.onDisconnect((reason) => printLog("Socket disconnected: $reason"));

    socket.on(kSocketSessionExpired, (_) => _checkSession());
    // events sent while offline or in the background are lost
    socket.onReconnect((_) => _checkSession());

    _socket = socket..connect();
  }

  static void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  // Ask the API instead of logging out straight away: if the token really is
  // dead, the profile call's 401 logs out (HttpServiceCustom). So an event
  // the server sends to every device on the account can't log out the
  // device that just signed in.
  static void _checkSession() {
    NavigationService.context.read<AppController>().getUser();
  }
}
