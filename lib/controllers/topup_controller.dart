// Project imports:
import '../imports.dart';
import '../models/payment_method_model.dart';
import '../models/topup_bonus_model.dart';

class TopupController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  /// True while the page loads (on open and on every refresh); it shows its
  /// skeleton meanwhile.
  bool isLoading = true;

  List<TopupBonusModel> bonuses = [];
  List<PaymentMethodModel> paymentMethods = [];

  /// The picked way to pay; the first one until another is picked.
  PaymentMethodModel? paymentMethod;

  TopupController() {
    _load();
  }

  /// The balance (into [AppController.points]), the packages and the
  /// payment methods, together.
  Future<void> _load() async {
    isLoading = true;
    update();

    await Future.wait([
      context.read<AppController>().getWalletBalance(),
      ApiService.api.getTopupBonusListing(
        onSuccess: (response) =>
            bonuses = TopupBonusModel.listFromJson(response.data),
      ),
      ApiService.api.getPaymentMethods(
        onSuccess: (response) =>
            paymentMethods = PaymentMethodModel.listFromJson(response.data),
      ),
    ]);

    // keep the picked method if it's still offered
    paymentMethod =
        paymentMethods.where((e) => e == paymentMethod).firstOrNull ??
        paymentMethods.firstOrNull;
    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  void onSelectPaymentMethod(PaymentMethodModel? method) {
    if (method == null || method == paymentMethod) return;

    paymentMethod = method;
    update();
  }

  // TODO(getithk): pay with [paymentMethod] once there's a top-up API
  void onTopUp(TopupBonusModel bonus) =>
      ToastHelper.showToast(context.tr(AppStrings.comingSoon));

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
