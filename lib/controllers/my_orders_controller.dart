// Project imports:
import '../imports.dart';
import '../models/shipping_order_model.dart';

enum OrderTab {
  all(AppStrings.allOrders, null),
  toShip(AppStrings.backpackToShip, ShippingStatus.toShip),
  toReceive(AppStrings.backpackToReceive, ShippingStatus.toReceive);

  const OrderTab(this.label, this.status);
  final String label;

  /// The orders it lists; null: all of them.
  final ShippingStatus? status;
}

class MyOrdersController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  /// The tabs in the app bar and the pages swiped between; the page's
  /// ticker drives it.
  late final TabController tabController;

  /// One per tab: each tab's page has its own refresher, and while swiping
  /// two are on screen at once.
  final Map<OrderTab, RefreshController> refreshControllers = {
    for (final OrderTab tab in OrderTab.values) tab: RefreshController(),
  };

  /// The current tab's.
  RefreshController get refreshController => refreshControllers[tab]!;

  OrderTab tab = OrderTab.all;

  /// True while the first page loads (on open, on every refresh and tab
  /// change); the list shows a skeleton meanwhile.
  bool isLoading = true;

  List<ShippingOrderModel> orders = [];

  int page = 1;

  static const int _perPage = 20;

  MyOrdersController({required TickerProvider vsync}) {
    tabController = TabController(length: OrderTab.values.length, vsync: vsync)
      ..addListener(_onTabChanged);
    onRefresh();
  }

  /// A tab tapped or swiped to: once it settles, its orders.
  void _onTabChanged() {
    if (tabController.indexIsChanging) return;

    final OrderTab value = OrderTab.values[tabController.index];
    if (value == tab) return;
    tab = value;
    onRefresh();
  }

  Future<void> onRefresh() async {
    // the tab's own, should it change meanwhile
    final RefreshController refresher = refreshController;
    isLoading = true;
    page = 1;
    orders = [];
    update();
    await getShippingListing();
    refresher.refreshCompleted();
    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await getShippingListing();
    update();
  }

  Future<void> getShippingListing() async {
    final OrderTab currentTab = tab;
    final RefreshController refresher = refreshController;

    await ApiService.api.getShippingListing(
      page: page,
      perPage: _perPage,
      status: currentTab.status,
      onSuccess: (response) {
        if (currentTab != tab) return;

        // the page: its orders under `data`, then where it stands
        final dynamic data = response.data;
        if (data is! Map) {
          refresher.loadNoData();
          return;
        }
        orders.addAll(ShippingOrderModel.listFromJson(data['data']));

        final int currentPage = parseInt(data['current_page'], page);
        final int totalPages = parseInt(data['total_pages']);
        if (currentPage < totalPages) {
          page = currentPage + 1;
          refresher.loadComplete();
        } else {
          refresher.loadNoData();
        }
      },
      onError: (_) => refresher.loadFailed(),
    );
  }

  Future<void> onCancel(ShippingOrderModel order) async {
    final int? shippingId = order.shippingId;
    if (shippingId == null) return;

    final bool? isCancelled = await BottomSheetHelper.confirm(
      title: AppStrings.cancelOrder,
      description: AppStrings.cancelOrderDescription,
      cancelText: AppStrings.thinkAgain,
      confirmText: AppStrings.confirmCancel,
      onConfirm: () => _cancelShipping(shippingId),
    );
    if (isCancelled == true && !_isDisposed) {
      refreshController.requestRefresh();
    }
  }

  Future<bool> _cancelShipping(int shippingId) async {
    bool isCancelled = false;
    await ApiService.api.cancelShipping(
      shippingId: shippingId,
      showLoader: true,
      onSuccess: (response) {
        isCancelled = true;
        response.showMessage();
      },
    );
    return isCancelled;
  }

  void onView(ShippingOrderModel order) {
    final int? shippingId = order.shippingId;
    if (shippingId == null) return;

    AppNavigator.pushNamed(
      context,
      RouteName.orderDetailsPage,
      arguments: shippingId,
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
    if (!_isDisposed) notifyListeners();
  }
}
