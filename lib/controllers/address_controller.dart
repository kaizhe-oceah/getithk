// Project imports:
import '../imports.dart';
import '../models/address_model.dart';

class AddressController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  /// True while the first page loads (on open and on every refresh); the
  /// list shows a skeleton meanwhile.
  bool isLoading = true;

  List<AddressModel> addresses = [];

  int page = 1;

  static const int _perPage = 20;

  /// Picking an address for checkout (see AddressPage.isSelect).
  final bool isSelect;

  /// The picked address's id, when [isSelect]: the one passed in, else the
  /// default one.
  int? selectedId;

  AddressController({this.isSelect = false, this.selectedId}) {
    onRefresh();
  }

  AddressModel? get selectedAddress => addresses
      .where((element) => element.shippingAddressId == selectedId)
      .firstOrNull;

  Future<void> onRefresh() async {
    isLoading = true;
    page = 1;
    addresses = [];
    update();
    await getShippingAddress();
    refreshController.refreshCompleted();
    // nothing picked yet, or the picked one is gone: the default one
    if (isSelect && selectedAddress == null) {
      selectedId = AddressModel.defaultOf(addresses)?.shippingAddressId;
    }
    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await getShippingAddress();
    update();
  }

  Future<void> getShippingAddress() async {
    await ApiService.api.getShippingAddress(
      page: page,
      perPage: _perPage,
      onSuccess: (response) {
        final dynamic data = response.data;
        final bool isPaged = data is Map;
        addresses.addAll(AddressModel.listFromData(data));

        final int currentPage = isPaged
            ? parseInt(data['current_page'], page)
            : page;
        final int totalPages = isPaged ? parseInt(data['total_pages']) : page;
        if (currentPage < totalPages) {
          page = currentPage + 1;
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
      },
      onError: (error) {
        printLog("getShippingAddress error: $error");
        refreshController.loadComplete();
      },
    );
  }

  /// The add-address page, 設為預設地址 ticked for the first address; it pops
  /// with true once it saves one, and the list refreshes.
  Future<void> onAdd() => _openForm(!isLoading && addresses.isEmpty);

  /// The address page filled in with [address], to update it.
  Future<void> onEdit(AddressModel address) => _openForm(address);

  /// The address page with [arguments] (see RouteGenerator); it pops with
  /// true once it saves, and the list refreshes.
  Future<void> _openForm(Object arguments) async {
    // untyped: RouteGenerator's routes are Route<dynamic>, and pushing one
    // as a Route<bool?> fails its cast
    final Object? isSaved = await AppNavigator.pushNamed(
      context,
      RouteName.addAddressPage,
      arguments: arguments,
    );
    if (isSaved == true) refreshController.requestRefresh();
  }

  void onSelect(AddressModel address) {
    selectedId = address.shippingAddressId;
    update();
  }

  /// 選擇地址: back to checkout with the picked address.
  void onConfirmSelect() {
    final AddressModel? address = selectedAddress;
    if (address != null) AppNavigator.pop(context, address);
  }

  /// Asks first; once deleted, the list refreshes.
  void onDelete(AddressModel address) {
    final int? id = address.shippingAddressId;
    if (id == null) return;

    DialogHelper().showNormalDialog(
      title: context.tr(AppStrings.deleteAddress),
      description: context.tr(AppStrings.deleteAddressConfirm),
      leftButtonText: context.tr(AppStrings.cancel),
      leftFunction: () => AppNavigator.pop(context),
      rightButtonText: context.tr(AppStrings.delete),
      rightTextColor: context.color.primary,
      rightFunction: () {
        AppNavigator.pop(context);
        _deleteAddress(id);
      },
    );
  }

  Future<void> _deleteAddress(int id) async {
    await ApiService.api.deleteShippingAddress(
      showLoader: false,
      shippingAddressId: id,
      onSuccess: (response) {
        response.showMessage();
        refreshController.requestRefresh();
      },
    );
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
