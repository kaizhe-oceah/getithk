// Project imports:
import '../imports.dart';
import '../models/draw_result_model.dart';

class PrizeResultController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final DrawResultModel result;

  Set<DrawHistoryModel> selectedPrizes = {};

  PrizeResultController({required this.result});

  List<DrawHistoryModel> get prizes => result.drawHistories;

  /// [prizes] grouped by grade, in [ProductGrade]'s order (尾賞, 一等獎, …);
  /// prizes of a grade it doesn't list come last, in the API's order.
  late final List<List<DrawHistoryModel>> gradeGroups = () {
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
  }();

  bool isSelected(DrawHistoryModel prize) => selectedPrizes.contains(prize);

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

  /// Only delivery-only prizes ship; the others are exchanged ([canExchange]).
  bool get canRequestShipment =>
      selectedPrizes.isNotEmpty &&
      selectedPrizes.every(
        (element) => element.subProduct?.isDeliveryOnly ?? false,
      );
  bool get canExchange =>
      selectedPrizes.isNotEmpty &&
      !selectedPrizes.any(
        (element) => element.subProduct?.isDeliveryOnly ?? false,
      );

  void onToggle(DrawHistoryModel prize) {
    if (!selectedPrizes.remove(prize)) selectedPrizes.add(prize);
    update();
  }

  void onSelectAll() => _pick(prizes);
  void onSelectAllDeliveryOnly() => _pick(deliveryOnly);
  void onSelectAllNonDeliveryOnly() => _pick(nonDeliveryOnly);

  void _pick(List<DrawHistoryModel> group) {
    selectedPrizes = _isPicked(group) ? {} : group.toSet();
    update();
  }

  void onRequestShipment() {
    if (selectedPrizes.isEmpty) {
      ToastHelper.showToast(context.tr(AppStrings.pleaseSelectAnItem));
    } else if (!canRequestShipment) {
      ToastHelper.showToast(context.tr(AppStrings.onlyDeliveryOnlyCanShip));
    } else {
      ToastHelper.showToast(context.tr(AppStrings.comingSoon));
    }
  }

  void onExchange() {
    if (selectedPrizes.isEmpty) {
      ToastHelper.showToast(context.tr(AppStrings.pleaseSelectAnItem));
    } else if (!canExchange) {
      ToastHelper.showToast(context.tr(AppStrings.deliveryOnlyCannotExchange));
    } else {
      ToastHelper.showToast(context.tr(AppStrings.comingSoon));
    }
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
