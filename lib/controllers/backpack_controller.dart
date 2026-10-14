// Project imports:
import '../imports.dart';
import '../models/category_model.dart';
import '../models/backpack_model.dart';

enum BackpackTab {
  cards(AppStrings.backpackCards, StockStatus.active),
  sold(AppStrings.backpackSold, StockStatus.sold),
  toShip(AppStrings.backpackToShip, StockStatus.shipping),
  toReceive(AppStrings.backpackToReceive, null);

  const BackpackTab(this.label, this.status);
  final String label;
  final StockStatus? status;
}

class BackpackController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  BackpackTab tab = BackpackTab.cards;

  CategoryModel? filterCategory;

  bool isLoading = true;

  List<BackpackModel> stocks = [];
  Set<BackpackModel> selectedStocks = {};

  int page = 1;

  static const int _perPage = 30;

  BackpackController() {
    setInit();
  }

  bool get canSelect => tab == BackpackTab.cards;

  bool isSelected(BackpackModel stock) => selectedStocks.contains(stock);

  double get selectedAmount => selectedStocks.fold(
    0,
    (double sum, BackpackModel stock) => sum + stock.totalAmount,
  );

  List<BackpackModel> get _deliveryOnly =>
      stocks.where((element) => element.isDeliveryOnly).toList();

  List<BackpackModel> get _nonDeliveryOnly =>
      stocks.where((element) => !element.isDeliveryOnly).toList();

  bool _isPicked(List<BackpackModel> group) =>
      group.isNotEmpty &&
      selectedStocks.length == group.length &&
      selectedStocks.containsAll(group);

  bool get isAllSelected => _isPicked(stocks);
  bool get isAllDeliveryOnlySelected => _isPicked(_deliveryOnly);
  bool get isAllNonDeliveryOnlySelected => _isPicked(_nonDeliveryOnly);

  /// Only delivery-only cards ship; the others are exchanged ([canExchange]).
  bool get canRequestShipment =>
      selectedStocks.isNotEmpty &&
      selectedStocks.every((element) => element.isDeliveryOnly);
  bool get canExchange =>
      selectedStocks.isNotEmpty &&
      !selectedStocks.any((element) => element.isDeliveryOnly);

  void setInit() async {
    await onRefresh();
  }

  Future<void> onRefresh() async {
    isLoading = true;
    page = 1;
    stocks = [];
    selectedStocks = {};
    await getStockListing();
    refreshController.refreshCompleted();
    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await getStockListing();
    update();
  }

  Future<void> getStockListing() async {
    final BackpackTab currentTab = tab;
    final int? categoryId = filterCategory?.id;
    final StockStatus? status = tab.status;
    if (status == null) {
      refreshController.loadNoData();
      return;
    }

    await ApiService.api.getPlayerStockListing(
      page: page,
      perPage: _perPage,
      status: status,
      productCategoryId: categoryId,
      onSuccess: (response) {
        if (currentTab != tab || categoryId != filterCategory?.id) return;

        final List<BackpackModel> listing = List.from(
          response.data['listing'],
        ).map((element) => BackpackModel.fromJson(element)).toList();
        stocks.addAll(listing);

        final int currentPage = parseInt(response.data['current_page'], page);
        final int totalPages = parseInt(response.data['total_pages']);
        if (currentPage < totalPages) {
          page = currentPage + 1;
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }

        update();
      },
      onError: (_) => refreshController.loadFailed(),
    );
  }

  void onSelectTab(BackpackTab value) {
    if (value == tab) return;

    tab = value;
    onRefresh();
    update();
  }

  void onFilterCategory(CategoryModel? category) {
    if (category?.id == filterCategory?.id) return;

    filterCategory = category;
    onRefresh();
    update();
  }

  void onToggle(BackpackModel stock) {
    if (!selectedStocks.remove(stock)) selectedStocks.add(stock);
    update();
  }

  void onSelectAll() => _pick(stocks);
  void onSelectAllDeliveryOnly() => _pick(_deliveryOnly);
  void onSelectAllNonDeliveryOnly() => _pick(_nonDeliveryOnly);

  void _pick(List<BackpackModel> group) {
    selectedStocks = _isPicked(group) ? {} : group.toSet();
    update();
  }

  void onRequestShipment() {
    if (selectedStocks.isEmpty) {
      ToastHelper.showToast(context.tr(AppStrings.pleaseSelectAnItem));
    } else if (!canRequestShipment) {
      ToastHelper.showToast(context.tr(AppStrings.onlyDeliveryOnlyCanShip));
    } else {
      ToastHelper.showToast(context.tr(AppStrings.comingSoon));
    }
  }

  void onExchange() {
    if (selectedStocks.isEmpty) {
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
    refreshController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
