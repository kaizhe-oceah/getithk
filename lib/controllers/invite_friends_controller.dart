// Project imports:
import '../imports.dart';
import '../models/invite_point_model.dart';

class InviteFriendsController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  bool isLoading = true;

  /// The latest listing: the totals and how many rounds there are.
  InvitePointModel? invitePoint;

  /// The round on show, swiped between; the player's current one to start.
  int round = 1;

  /// Each round's listing, as last loaded; on show while it loads again.
  final Map<int, InvitePointModel> rounds = {};

  final Set<int> _loadingRounds = {};

  InviteFriendsController() {
    _load();
  }

  int get totalRounds => invitePoint?.totalRounds ?? 1;

  /// No listing for round [value] yet, but one on the way.
  bool isRoundLoading(int value) =>
      rounds[value] == null && (isLoading || _loadingRounds.contains(value));

  /// The player's current round to start with; [round] once it's been
  /// swiped to another.
  Future<void> _load() async {
    isLoading = true;
    update();

    await _getListing(invitePoint == null ? null : round);

    isLoading = false;
    update();
    _prefetchAround(round);
  }

  Future<void> _getListing(int? value) async {
    await ApiService.api.getInvitePointListing(
      round: value,
      onSuccess: (response) {
        if (response.data is! Map) return;

        final InvitePointModel listing = InvitePointModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        if (invitePoint == null) round = listing.round;
        invitePoint = listing;
        rounds[value ?? listing.round] = listing;
      },
    );
  }

  /// Swiped to round [value]: on show at once, from the API afresh.
  Future<void> onSelectRound(int value) async {
    if (value < 1 || value > totalRounds || value == round) return;

    round = value;
    update();
    _prefetchAround(value);
    await _loadRound(value);
  }

  // the rounds either side, so a swipe drags in their rewards, not a
  // skeleton
  void _prefetchAround(int value) {
    for (final int side in [value - 1, value + 1]) {
      if (side >= 1 && side <= totalRounds && !rounds.containsKey(side)) {
        _loadRound(side);
      }
    }
  }

  Future<void> _loadRound(int value) async {
    // already on the way
    if (!_loadingRounds.add(value)) return;
    update();

    await _getListing(value);

    _loadingRounds.remove(value);
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  /// 一鍵領取: every reward still to claim in round [value].
  void onClaimRound(int value) => _claim(round: value);

  /// 領取: [tier]'s reward, in round [value].
  void onClaim(int value, InvitePointTierModel tier) =>
      _claim(round: value, position: tier.position);

  /// Claims; a success toast with the API's message, then the balance and
  /// the round on show catch up. A failure's toast is the API call's.
  Future<void> _claim({int? round, int? position}) async {
    bool isClaimed = false;
    await ApiService.api.claimInvitePoint(
      round: round,
      position: position,
      showLoader: true,
      onSuccess: (response) {
        isClaimed = true;
        ToastHelper.success(
          response.message ?? context.tr(AppStrings.claimSuccess),
        );
        context.read<AppController>().getWalletBalance();
      },
    );
    if (!isClaimed || _isDisposed) return;

    await _getListing(round ?? this.round);
    update();
  }

  @override
  void dispose() {
    _isDisposed = true;
    refreshController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
