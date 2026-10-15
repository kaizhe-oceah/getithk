// Project imports:
import '../components/default/shipment_received_dialog.dart';
import '../imports.dart';
import '../models/address_model.dart';
import '../models/backpack_model.dart';
import '../models/shipment_item_model.dart';
import '../models/shipping_setting_model.dart';

class CheckoutController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  /// What the backpack's 申請出貨 sheet confirmed.
  final List<ShipmentItemModel> items;

  /// True while the shipping setting loads; the fee shows a skeleton.
  bool isLoading = true;

  /// The shipping fee and free-shipping threshold; null if they didn't load.
  ShippingSettingModel? shippingSetting;

  late final TapGestureRecognizer termsRecognizer = TapGestureRecognizer()
    ..onTap = onTerms;

  /// True while the addresses load; the address shows a skeleton.
  bool isAddressLoading = true;

  /// Where to ship: the default address to start with, then the one picked.
  AddressModel? address;

  CheckoutController({required this.items}) {
    _getShippingSetting();
    _getAddress();
  }

  /// The default address (the first, if none is) to ship to.
  Future<void> _getAddress() async {
    await ApiService.api.getShippingAddress(
      page: 1,
      perPage: 20,
      onSuccess: (response) => address = AddressModel.defaultOf(
        AddressModel.listFromData(response.data),
      ),
    );

    isAddressLoading = false;
    update();
  }

  Future<void> _getShippingSetting() async {
    await ApiService.api.getShippingSetting(
      onSuccess: (response) {
        if (response.data is Map) {
          shippingSetting = ShippingSettingModel.fromJson(
            Map<String, dynamic>.from(response.data),
          );
        }
      },
    );

    isLoading = false;
    update();
  }

  /// Whether the cards' total reaches the free-shipping threshold.
  bool get isFreeShipping {
    final double? threshold = shippingSetting?.freeShippingThreshold;
    return threshold != null && totalAmount >= threshold;
  }

  /// What shipping costs: the setting's fee, nothing past the threshold.
  double get shippingFee =>
      isFreeShipping ? 0 : (shippingSetting?.shippingFee ?? 0);

  int get totalQuantity =>
      items.fold(0, (int sum, ShipmentItemModel item) => sum + item.quantity);

  double get totalAmount => items.fold(
    0,
    (double sum, ShipmentItemModel item) => sum + item.totalAmount,
  );

  /// One card per piece shipped, so 2 of a card shows it twice.
  List<BackpackModel> get cards => [
    for (final ShipmentItemModel item in items)
      for (int i = 0; i < item.quantity; i++) item.stock,
  ];

  /// The address page, to pick where to ship (the current one ticked); the
  /// picked one comes back.
  Future<void> onAddress() async {
    if (isAddressLoading) return;

    final Object? picked = await AppNavigator.pushNamed(
      context,
      RouteName.addressPage,
      arguments: (isSelect: true, selectedId: address?.shippingAddressId),
    );
    if (picked is AddressModel) {
      address = picked;
      update();
    }
  }

  void onTerms() {
    AppNavigator.pushNamed(
      context,
      RouteName.tncPage,
      arguments: TncType.terms,
    );
  }

  /// The stocks to ship: the first [ShipmentItemModel.quantity] ids of each
  /// item's stock.
  List<int> get userStockIds => [
    for (final ShipmentItemModel item in items)
      ...item.stock.stockIds.take(item.quantity).map(int.tryParse).nonNulls,
  ];

  /// 申請出貨: ships the cards to [address]; once the dialog saying so
  /// closes, back to the backpack with true so it refreshes.
  Future<void> onSubmit() async {
    final AddressModel? address = this.address;
    if (isAddressLoading) return;
    if (address == null) {
      ToastHelper.showToast(context.tr(AppStrings.addShippingAddress));
      return;
    }

    await ApiService.api.createShipping(
      showLoader: true,
      name: address.name ?? '',
      // "852": the API takes it without the "+"
      phoneCode: (address.phoneCode ?? '').replaceFirst('+', ''),
      phoneNo: address.phoneNo ?? '',
      address: address.address ?? '',
      userStockIds: userStockIds,
      onSuccess: (_) async {
        await ShipmentReceivedDialog.show(context);
        AppNavigator.pop(context, true);
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    termsRecognizer.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
