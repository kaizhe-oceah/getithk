// Project imports:
import '../components/default/accumulate_box_reward_dialog.dart';
import '../components/default/draw_video_dialog.dart';
import '../imports.dart';
import '../models/accumulate_box_model.dart';
import '../models/draw_result_model.dart';

class TopupRewardController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  bool isLoading = true;

  /// The reward levels, lowest top-up first, as the API lists them.
  List<AccumulateBoxModel> levels = [];

  /// The level picked along the top; its reward and prizes show below.
  int selectedIndex = 0;

  TopupRewardController() {
    _load();
  }

  AccumulateBoxModel? get selected => levels.elementAtOrNull(selectedIndex);

  Future<void> _load() async {
    isLoading = true;
    update();

    await ApiService.api.getAccumulateBoxListing(
      onSuccess: (response) {
        final AccumulateBoxModel? before = selected;
        levels = AccumulateBoxModel.listFromJson(response.data);
        selectedIndex = _indexToShow(before);
      },
    );

    isLoading = false;
    update();
  }

  /// [before], the level picked till a refresh, if it's still there; else
  /// the first with a reward to claim, else the first.
  int _indexToShow(AccumulateBoxModel? before) {
    if (before != null) {
      final int index = levels.indexWhere(
        (level) => level.requiredTopupAmount == before.requiredTopupAmount,
      );
      if (index != -1) return index;
    }

    final int claimable = levels.indexWhere((level) => level.canClaim);
    return claimable == -1 ? 0 : claimable;
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  void onSelect(int index) {
    if (index == selectedIndex) return;

    selectedIndex = index;
    update();
  }

  /// 領取獎勵: redeems the level's box, plays it opening, then shows what
  /// came out; the levels catch up after.
  Future<void> onClaim() async {
    final int? mainProductId = selected?.mainProductId;
    if (mainProductId == null) return;

    bool isRedeemed = false;
    DrawHistoryModel? prize;
    await ApiService.api.redeemAccumulateBox(
      mainProductId: mainProductId,
      showLoader: true,
      onSuccess: (response) {
        isRedeemed = true;
        prize = DrawResultModel.fromJson(
          response.data,
        ).drawHistories.firstOrNull;
      },
    );
    if (!isRedeemed) return;

    await DrawVideoDialog.showAsset(context, AppAssets.accumulateBoxVideo);
    final DrawHistoryModel? won = prize;
    if (won != null) await AccumulateBoxRewardDialog.show(context, won);
    if (!_isDisposed) await _load();
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
