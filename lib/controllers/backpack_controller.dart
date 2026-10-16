// Project imports:
import '../imports.dart';
import '../models/category_model.dart';
import '../models/backpack_model.dart';
import '../models/shipment_item_model.dart';

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

  /// The tabs in the app bar and the pages swiped between; the page's
  /// ticker drives it.
  late final TabController tabController;

  /// One per tab: each tab's page has its own refresher, and while swiping
  /// two are on screen at once.
  final Map<BackpackTab, RefreshController> refreshControllers = {
    for (final BackpackTab tab in BackpackTab.values) tab: RefreshController(),
  };

  /// The current tab's.
  RefreshController get refreshController => refreshControllers[tab]!;

  BackpackTab tab = BackpackTab.cards;

  CategoryModel? filterCategory;

  bool isLoading = true;

  List<BackpackModel> stocks = [];
  Set<BackpackModel> selectedStocks = {};

  int page = 1;

  static const int _perPage = 30;

  BackpackController({required TickerProvider vsync}) {
    tabController = TabController(
      length: BackpackTab.values.length,
      vsync: vsync,
    )..addListener(_onTabChanged);
    setInit();
  }

  /// A tab tapped or swiped to: once it settles, its stocks.
  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    onSelectTab(BackpackTab.values[tabController.index]);
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

  /// Any card ships; only one that isn't delivery only (is_delivery_only 2)
  /// can be exchanged for PTS too.
  bool get canRequestShipment => selectedStocks.isNotEmpty;
  bool get canExchange =>
      selectedStocks.isNotEmpty &&
      !selectedStocks.any((element) => element.isDeliveryOnly);

  void setInit() async {
    await onRefresh();
  }

  Future<void> onRefresh() async {
    // the tab's own, should it change meanwhile
    final RefreshController refresher = refreshController;
    isLoading = true;
    page = 1;
    stocks = [];
    selectedStocks = {};
    await getStockListing();
    refresher.refreshCompleted();
    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await getStockListing();
    update();
  }

  Future<void> getStockListing() async {
    final BackpackTab currentTab = tab;
    final RefreshController refresher = refreshController;
    final int? categoryId = filterCategory?.id;
    final StockStatus? status = tab.status;
    if (status == null) {
      refresher.loadNoData();
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
          refresher.loadComplete();
        } else {
          refresher.loadNoData();
        }

        update();
      },
      onError: (_) => refresher.loadFailed(),
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
    if (!canRequestShipment) {
      ToastHelper.showToast(context.tr(AppStrings.pleaseSelectAnItem));
    } else {
      BottomSheetHelper.requestShipment(
        stocks: selectedStocks.toList(),
        onConfirm: (items) async {
          // true once the cards are shipped: they've left the backpack
          final Object? isShipped = await AppNavigator.pushNamed(
            context,
            RouteName.checkoutPage,
            arguments: items,
          );
          if (isShipped == true && !_isDisposed) onRefresh();
        },
      );
    }
  }

  void onExchange() {
    if (selectedStocks.isEmpty) {
      ToastHelper.showToast(context.tr(AppStrings.pleaseSelectAnItem));
    } else if (!canExchange) {
      ToastHelper.showToast(context.tr(AppStrings.deliveryOnlyCannotExchange));
    } else {
      BottomSheetHelper.exchangeStocks(
        stocks: selectedStocks.toList(),
        onConfirm: _sellStocks,
      );
    }
  }

  /// 確認兌換: exchanges [items] for PTS; once done, the balance and the
  /// backpack (pulled down to refresh) catch up.
  Future<void> _sellStocks(List<ShipmentItemModel> items) async {
    await ApiService.api.sellStock(
      showLoader: true,
      stockIds: [for (final ShipmentItemModel item in items) ...item.stockIds],
      onSuccess: (response) {
        response.showMessage();
        context.read<AppController>().getWalletBalance();
        if (!_isDisposed) refreshController.requestRefresh();
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    tabController.dispose();
    for (final RefreshController controller in refreshControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
