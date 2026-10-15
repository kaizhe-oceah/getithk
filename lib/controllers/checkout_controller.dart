// Project imports:
import '../imports.dart';
import '../models/backpack_model.dart';
import '../models/shipment_item_model.dart';

class CheckoutController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  /// What the backpack's 申請出貨 sheet confirmed.
  final List<ShipmentItemModel> items;

  // no shipping-fee API yet
  double shippingFee = 0;

  late final TapGestureRecognizer termsRecognizer = TapGestureRecognizer()
    ..onTap = onTerms;

  CheckoutController({required this.items});

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

  // no shipping-address API yet
  void onAddress() {
    ToastHelper.showToast(context.tr(AppStrings.comingSoon));
  }

  void onTerms() {
    AppNavigator.pushNamed(
      context,
      RouteName.tncPage,
      arguments: TncType.terms,
    );
  }

  // no request-shipment API yet
  void onSubmit() {
    ToastHelper.showToast(context.tr(AppStrings.comingSoon));
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
