// Package imports:
import 'package:socket_io_client/socket_io_client.dart' as io;

// Project imports:
import '../imports.dart';
import 'draw_video_service.dart';
import 'http_services/http_service_custom.dart';

class SocketService {
  static io.Socket? _socket;

  /// This login's player and session channel, while logged in.
  static int? _playerId;
  static String? _sessionChannel;

  static const List<String> _publicChannels = [
    'live.main-products',
    'live.draw-videos',
  ];

  /// The channels screens are on (a product's while its page is open), and
  /// how many screens are on each.
  static final Map<String, int> _screenChannels = {};

  /// The same for this login's player, without the private-player.{id}. in
  /// front; joined only while logged in.
  static final Map<String, int> _playerScreenChannels = {};

  static const String _sessionEvent = 'session.update';
  static const String _mainProductEvent = 'main-product.update';
  static const String _drawVideosEvent = 'draw-videos.update';
  static const String _productRemainingEvent = 'product-remaining.update';
  static const String _playerProductRemainingEvent =
      'player-product-remaining.update';

  static final StreamController<Map<String, dynamic>> _mainProductUpdates =
      StreamController.broadcast();
  static final StreamController<Map<String, dynamic>> _productRemainingUpdates =
      StreamController.broadcast();
  static final StreamController<Map<String, dynamic>>
  _playerProductRemainingUpdates = StreamController.broadcast();

  /// A main product changed (live.main-products' main-product.update).
  static Stream<Map<String, dynamic>> get mainProductUpdates =>
      _mainProductUpdates.stream;

  /// [mainProductId]'s draws left changed (live.{id}.product-remaining's
  /// product-remaining.update); on its channel only while listened to.
  static Stream<Map<String, dynamic>> productRemainingUpdates(
    int mainProductId,
  ) => _onChannel(
    'live.$mainProductId.product-remaining',
    _productRemainingUpdates.stream.where(
      (data) => _isForProduct(data, mainProductId),
    ),
  );

  /// This player's draws left of [mainProductId] changed
  /// (private-player.{playerId}.{id}.product-remaining's
  /// player-product-remaining.update); on its channel only while listened to
  /// and logged in.
  static Stream<Map<String, dynamic>> playerProductRemainingUpdates(
    int mainProductId,
  ) => _onChannel(
    '$mainProductId.product-remaining',
    _playerProductRemainingUpdates.stream.where(
      (data) => _isForProduct(data, mainProductId),
    ),
    forPlayer: true,
  );

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
      for (final String channel in [
        ..._publicChannels,
        ..._screenChannels.keys,
        ?_sessionChannel,
        ..._playerChannels,
      ]) {
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
    socket.on(_drawVideosEvent, (data) {
      printLog("Socket $_drawVideosEvent: $data");
      DrawVideoService.refresh();
    });
    socket.on(_productRemainingEvent, (data) {
      printLog("Socket $_productRemainingEvent: $data");
      if (data is Map) _productRemainingUpdates.add(Map.from(data));
    });
    socket.on(_playerProductRemainingEvent, (data) {
      printLog("Socket $_playerProductRemainingEvent: $data");
      if (data is Map) _playerProductRemainingUpdates.add(Map.from(data));
    });
    // an event sent while offline or in the background is lost: the API
    // says whether the token's still good (a 401 logs out), and what the
    // draw videos are now
    socket.onReconnect((_) {
      if (_sessionChannel != null) _checkSession();
      DrawVideoService.refresh();
    });

    _socket = socket..connect();
  }

  /// After a login: this login's own channels too, instead of the last
  /// one's.
  static Future<void> joinSession() async {
    leaveSession();

    final String? token = await ApiService.getApiToken();
    if (token == null || token.isEmpty) return;
    final int? playerId = NavigationService.context
        .read<AppController>()
        .user
        ?.id;
    if (playerId == null) {
      printLog("Socket: no player channels (no player)");
      return;
    }

    _playerId = playerId;
    _sessionChannel = _sessionChannelFor(playerId, token);
    start();
    // not connected yet: onConnect joins them
    for (final String channel in [?_sessionChannel, ..._playerChannels]) {
      _emit('subscribe', channel);
    }
  }

  /// On logout: off this login's own channels; the public ones and the
  /// screens' stay.
  static void leaveSession() {
    for (final String channel in [?_sessionChannel, ..._playerChannels]) {
      _emit('unsubscribe', channel);
    }
    _sessionChannel = null;
    _playerId = null;
  }

  /// The screens' channels for this login's player; none when logged out.
  static Iterable<String> get _playerChannels {
    final int? playerId = _playerId;
    if (playerId == null) return const [];
    return _playerScreenChannels.keys.map(
      (channel) => 'private-player.$playerId.$channel',
    );
  }

  // another product's page may be open under this one
  static bool _isForProduct(Map<String, dynamic> data, int mainProductId) {
    final Object? id = data['main_product_id'];
    return id == null || '$id' == '$mainProductId';
  }

  /// [events], with [channel] joined from the first listen until it's
  /// cancelled; [forPlayer]: [channel] is this login's player's, joined only
  /// while logged in.
  static Stream<Map<String, dynamic>> _onChannel(
    String channel,
    Stream<Map<String, dynamic>> events, {
    bool forPlayer = false,
  }) {
    StreamSubscription<Map<String, dynamic>>? subscription;
    late final StreamController<Map<String, dynamic>> controller;
    controller = StreamController(
      onListen: () {
        _joinChannel(channel, forPlayer: forPlayer);
        subscription = events.listen(controller.add);
      },
      onCancel: () {
        subscription?.cancel();
        _leaveChannel(channel, forPlayer: forPlayer);
      },
    );
    return controller.stream;
  }

  static void _joinChannel(String channel, {required bool forPlayer}) {
    final Map<String, int> channels = forPlayer
        ? _playerScreenChannels
        : _screenChannels;
    final int screens = channels[channel] ?? 0;
    channels[channel] = screens + 1;
    if (screens > 0) return;

    start();
    // not connected yet: onConnect joins it; logged out: joinSession
    final String? name = forPlayer ? _forPlayer(channel) : channel;
    if (name != null) _emit('subscribe', name);
  }

  static void _leaveChannel(String channel, {required bool forPlayer}) {
    final Map<String, int> channels = forPlayer
        ? _playerScreenChannels
        : _screenChannels;
    final int screens = (channels[channel] ?? 0) - 1;
    if (screens > 0) {
      channels[channel] = screens;
      return;
    }

    channels.remove(channel);
    final String? name = forPlayer ? _forPlayer(channel) : channel;
    if (name != null) _emit('unsubscribe', name);
  }

  static String? _forPlayer(String channel) {
    final int? playerId = _playerId;
    return playerId == null ? null : 'private-player.$playerId.$channel';
  }

  static void _emit(String event, String channel) {
    if (_socket?.connected ?? false) _socket!.emit(event, channel);
  }

  /// private-player.{playerId}.{playerTokenId}.session: this login's own.
  /// The token id is the number before the token's "|"; null without one.
  static String? _sessionChannelFor(int playerId, String token) {
    final int separator = token.indexOf('|');
    if (separator <= 0) {
      printLog("Socket: no session channel (player $playerId)");
      return null;
    }

    return 'private-player.$playerId.${token.substring(0, separator)}.session';
  }

  static void _checkSession() {
    NavigationService.context.read<AppController>().getUser();
  }
}
