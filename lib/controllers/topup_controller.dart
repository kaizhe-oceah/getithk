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

  /// An Android phone (not the web build, where Platform isn't there).
  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

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
        onSuccess: (response) => paymentMethods =
            PaymentMethodModel.listFromJson(response.data)
                // Apple Pay doesn't work on an Android phone
                .where((element) => !(_isAndroid && element.isApplePay))
                .toList(),
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

  Future<void> onTopUp(TopupBonusModel bonus) async {
    final String? gateway = paymentMethod?.gateway;
    if (gateway == null) {
      ToastHelper.showToast(context.tr(AppStrings.selectPaymentMethod));
      return;
    }

    String? redirectUrl;
    await ApiService.api.topUpByGateway(
      showLoader: true,
      topupAmount: bonus.amount,
      gateway: gateway,
      onSuccess: (response) {
        final dynamic data = response.data;
        if (data is Map) redirectUrl = data['redirect_url']?.toString();
      },
    );

    final String? url = redirectUrl;
    if (url != null && url.isNotEmpty) await _openPaymentWebview(url);
  }

  /// The gateway's [paymentUrl]; it closes, back to this page, once the
  /// gateway sends the player back (kTopUpReturnPath) with how it went:
  /// - paid: this page reloads (pulled down to refresh): balance, packages;
  /// - pending (not confirmed yet, probably paid): the balance checked again
  ///   a little later, for when it's confirmed;
  /// - anything else, the back button too: not paid.
  Future<void> _openPaymentWebview(String paymentUrl) async {
    final Object? result = await AppNavigator.pushNamed(
      context,
      RouteName.webviewPage,
      arguments: {
        "url": paymentUrl,
        "title": context.tr(AppStrings.payment),
        "returnPath": kTopUpReturnPath,
      },
    );

    switch (PaymentStatus.fromValue(result)) {
      case PaymentStatus.paid:
        ToastHelper.showToast(context.tr(AppStrings.paymentSuccessful));
        if (!_isDisposed) refreshController.requestRefresh();
      case PaymentStatus.pending:
        ToastHelper.showToast(context.tr(AppStrings.paymentProcessing));
        Future.delayed(
          _pendingRecheck,
          context.read<AppController>().getWalletBalance,
        );
      case PaymentStatus.failed || null:
        ToastHelper.showToast(context.tr(AppStrings.paymentFailed));
    }
  }

  /// How long after a pending payment to check the balance again.
  static const Duration _pendingRecheck = Duration(seconds: 5);

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
