// Project imports:
import '../imports.dart';
import '../models/backpack_model.dart';
import '../models/draw_result_model.dart';
import '../models/shipment_item_model.dart';

class PrizeResultController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final DrawResultModel result;

  Set<DrawHistoryModel> selectedPrizes = {};

  /// What was won, less what's since been shipped or exchanged.
  late List<DrawHistoryModel> prizes = List.of(result.drawHistories);

  PrizeResultController({required this.result});

  /// A trial draw's result: nothing to pick, ship or exchange; only
  /// 會員註冊.
  bool get isTrial => result.isTrial;

  /// [prizes] grouped by grade.
  late List<List<DrawHistoryModel>> gradeGroups = _byGrade(prizes);

  /// [prizes] grouped by grade, in [ProductGrade]'s order (尾賞, 一等獎, …);
  /// prizes of a grade it doesn't list come last, in the API's order.
  static List<List<DrawHistoryModel>> _byGrade(List<DrawHistoryModel> prizes) {
    final Map<int?, List<DrawHistoryModel>> byGrade = {};
    for (final DrawHistoryModel prize in prizes) {
      byGrade.putIfAbsent(prize.subProduct?.gradeId, () => []).add(prize);
    }

    final List<List<DrawHistoryModel>> groups = [];
    for (final ProductGrade grade in ProductGrade.values) {
      final List<DrawHistoryModel>? items = byGrade.remove(grade.value);
      if (items != null) groups.add(items);
    }
    return [...groups, ...byGrade.values];
  }

  bool isSelected(DrawHistoryModel prize) => selectedPrizes.contains(prize);

  /// [selectedPrizes] as the backpack holds them, for its 申請出貨 and 兌換PTS
  /// sheets: one stock per card, in the page's order.
  List<BackpackModel> get _selectedStocks {
    final Map<Object, List<DrawHistoryModel>> byCard = {};
    for (final List<DrawHistoryModel> group in gradeGroups) {
      for (final DrawHistoryModel prize in group) {
        if (!isSelected(prize)) continue;
        byCard.putIfAbsent(prize.subProduct?.id ?? prize, () => []).add(prize);
      }
    }
    return [
      for (final List<DrawHistoryModel> card in byCard.values)
        BackpackModel.fromPrizes(card),
    ];
  }

  /// What [prizes] are worth, all together.
  static double amountOf(Iterable<DrawHistoryModel> prizes) =>
      prizes.fold(0, (double sum, prize) => sum + prize.amount);

  double get selectedAmount => amountOf(selectedPrizes);

  List<DrawHistoryModel> get deliveryOnly => prizes
      .where((element) => element.subProduct?.isDeliveryOnly ?? false)
      .toList();

  List<DrawHistoryModel> get nonDeliveryOnly => prizes
      .where((element) => !(element.subProduct?.isDeliveryOnly ?? false))
      .toList();

  bool _isPicked(List<DrawHistoryModel> group) =>
      group.isNotEmpty &&
      selectedPrizes.length == group.length &&
      selectedPrizes.containsAll(group);

  bool get isAllSelected => _isPicked(prizes);
  bool get isAllDeliveryOnlySelected => _isPicked(deliveryOnly);
  bool get isAllNonDeliveryOnlySelected => _isPicked(nonDeliveryOnly);

  /// Any prize ships; only one that isn't delivery only (is_delivery_only
  /// 2) can be exchanged for PTS too.
  bool get canRequestShipment => selectedPrizes.isNotEmpty;
  bool get canExchange =>
      selectedPrizes.isNotEmpty &&
      !selectedPrizes.any(
        (element) => element.subProduct?.isDeliveryOnly ?? false,
      );

  void onToggle(DrawHistoryModel prize) {
    if (isTrial) return;

    if (!selectedPrizes.remove(prize)) selectedPrizes.add(prize);
    update();
  }

  void onSelectAll() => _pick(prizes);
  void onSelectAllDeliveryOnly() => _pick(deliveryOnly);
  void onSelectAllNonDeliveryOnly() => _pick(nonDeliveryOnly);

  void _pick(List<DrawHistoryModel> group) {
    if (isTrial) return;

    selectedPrizes = _isPicked(group) ? {} : group.toSet();
    update();
  }

  /// 會員註冊: the login page, on its register tab.
  void onRegister() => AppNavigator.pushNamed(context, RouteName.registerPage);

  void onRequestShipment() {
    if (isTrial) return;

    if (!canRequestShipment) {
      ToastHelper.showToast(context.tr(AppStrings.pleaseSelectAnItem));
    } else {
      BottomSheetHelper.requestShipment(
        stocks: _selectedStocks,
        onConfirm: (items) async {
          // true once the prizes are shipped: they've left the backpack
          final Object? isShipped = await AppNavigator.pushNamed(
            context,
            RouteName.checkoutPage,
            arguments: items,
          );
          if (isShipped == true && !_isDisposed) _remove(items);
        },
      );
    }
  }

  void onExchange() {
    if (isTrial) return;

    if (selectedPrizes.isEmpty) {
      ToastHelper.showToast(context.tr(AppStrings.pleaseSelectAnItem));
    } else if (!canExchange) {
      ToastHelper.showToast(context.tr(AppStrings.deliveryOnlyCannotExchange));
    } else {
      BottomSheetHelper.exchangeStocks(
        stocks: _selectedStocks,
        onConfirm: _sellStocks,
      );
    }
  }

  /// 確認兌換: exchanges [items] for PTS; once done, the balance catches up
  /// and it's back to the page the draw was on (home, or the sub product
  /// page).
  Future<void> _sellStocks(List<ShipmentItemModel> items) async {
    await ApiService.api.sellStock(
      showLoader: true,
      stockIds: [for (final ShipmentItemModel item in items) ...item.stockIds],
      onSuccess: (response) {
        response.showMessage();
        context.read<AppController>().getWalletBalance();
        if (!_isDisposed) AppNavigator.pop(context);
      },
    );
  }

  /// The prizes [items] shipped or exchanged have left the backpack: off the
  /// page too, and nothing's picked.
  void _remove(List<ShipmentItemModel> items) {
    final Set<int> stockIds = {
      for (final ShipmentItemModel item in items) ...item.stockIds,
    };
    prizes = prizes
        .where((prize) => !stockIds.contains(prize.userStockId))
        .toList();
    gradeGroups = _byGrade(prizes);
    selectedPrizes = {};
    update();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
