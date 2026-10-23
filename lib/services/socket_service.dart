// Package imports:
import 'package:socket_io_client/socket_io_client.dart' as io;

// Project imports:
import '../imports.dart';
import 'http_services/http_service_custom.dart';

/// Live connection to the backend's socket.io bridge, for the app's whole
/// run: the public channels for everyone (live.main-products), and this
/// login's own session channel while logged in, for the server kicking it.
///
/// assets/cfg/config.json: socket_url, socket_path and socket_bridge_token
/// (the bridge's shared token, not the player's).
class SocketService {
  static io.Socket? _socket;

  /// This login's session channel, while logged in.
  static String? _sessionChannel;

  static const List<String> _publicChannels = ['live.main-products'];

  static const String _sessionEvent = 'session.update';
  static const String _mainProductEvent = 'main-product.update';

  static final StreamController<Map<String, dynamic>> _mainProductUpdates =
      StreamController.broadcast();

  /// A main product changed (live.main-products' main-product.update).
  static Stream<Map<String, dynamic>> get mainProductUpdates =>
      _mainProductUpdates.stream;

  /// Connects, once; does nothing when not configured.
  static void start() {
    if (_socket != null) return;

    final String? url = GlobalConfigs().get("socket_url");
    final String path = GlobalConfigs().get("socket_path") ?? '/socket.io';
    final String? bridgeToken = GlobalConfigs().get("socket_bridge_token");
    if (url == null || url.isEmpty) return;
    if (bridgeToken == null || bridgeToken.isEmpty) {
      printLog("Socket: no socket_bridge_token");
      return;
    }

    final socket = io.io(
      url,
      io.OptionBuilder()
          .setPath(path)
          .setTransports(["websocket"])
          .setAuth({"token": bridgeToken})
          .disableAutoConnect()
          .build(),
    );

    // on every connect: the bridge forgets subscriptions on a disconnect
    socket.onConnect((_) {
      printLog("Socket connected");
      for (final String channel in [..._publicChannels, ?_sessionChannel]) {
        socket.emit('subscribe', channel);
      }
    });
    socket.onConnectError((error) => printLog("Socket connect error: $error"));
    socket.onDisconnect((reason) => printLog("Socket disconnected: $reason"));
    // {message: 'unauthorized'}: a wrong or missing socket_bridge_token
    socket.on('error', (error) => printLog("Socket error: $error"));

    // straight away: the token is deleted too, but maybe a moment later
    socket.on(_sessionEvent, (data) {
      if (data is Map && data['is_logged_out'] == true) {
        HttpServiceCustom.handleSessionExpired();
      }
    });
    socket.on(_mainProductEvent, (data) {
      if (data is Map) _mainProductUpdates.add(Map.from(data));
    });
    // an event sent while offline or in the background is lost: the API
    // says whether the token's still good (a 401 logs out)
    socket.onReconnect((_) {
      if (_sessionChannel != null) _checkSession();
    });

    _socket = socket..connect();
  }

  /// After a login: this login's session channel too, instead of the last
  /// one's.
  static Future<void> joinSession() async {
    leaveSession();

    final String? token = await ApiService.getApiToken();
    if (token == null || token.isEmpty) return;
    final String? channel = _sessionChannelFor(token);
    if (channel == null) return;

    _sessionChannel = channel;
    start();
    // not connected yet: onConnect joins it
    if (_socket?.connected ?? false) _socket!.emit('subscribe', channel);
  }

  /// On logout: off the session channel; the public ones stay.
  static void leaveSession() {
    final String? channel = _sessionChannel;
    _sessionChannel = null;
    if (channel != null && (_socket?.connected ?? false)) {
      _socket!.emit('unsubscribe', channel);
    }
  }

  /// private-player.{playerId}.{playerTokenId}.session: this login's own.
  /// The token id is the number before the token's "|"; null without one.
  static String? _sessionChannelFor(String token) {
    final int? playerId = NavigationService.context
        .read<AppController>()
        .user
        ?.id;
    final int separator = token.indexOf('|');
    if (playerId == null || separator <= 0) {
      printLog("Socket: no session channel (player $playerId)");
      return null;
    }

    return 'private-player.$playerId.${token.substring(0, separator)}.session';
  }

  static void _checkSession() {
    NavigationService.context.read<AppController>().getUser();
  }
}
