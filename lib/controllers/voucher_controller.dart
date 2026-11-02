// Project imports:
import '../components/default/voucher_claimed_dialog.dart';
import '../imports.dart';
import '../models/page_banner_model.dart';

class VoucherController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();
  final TextEditingController codeController = TextEditingController();

  /// True while the banner loads; it shows a skeleton.
  bool isLoading = true;

  /// The page banner for vouchers; null if there's none.
  PageBannerModel? banner;

  VoucherController() {
    // 立即兌換 turns on once there's a code
    codeController.addListener(update);
    _load();
  }

  bool get canRedeem => codeController.text.trim().isNotEmpty;

  Future<void> _load() async {
    await ApiService.api.getPageBanners(
      onSuccess: (response) {
        banner = PageBannerModel.listFromJson(response.data)
            .where((element) => element.image != null && element.isVoucher)
            .firstOrNull;
      },
    );

    isLoading = false;
    update();
  }

  /// The banner again; the one showing stays till it's back, and the code
  /// typed stays too.
  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  Future<void> onRedeem() async {
    if (!canRedeem) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await ApiService.api.redeemVoucher(
      code: codeController.text.trim(),
      showLoader: true,
      onSuccess: (response) {
        context.read<AppController>().getWalletBalance();
        if (!_isDisposed) codeController.clear();
        final dynamic data = response.data;
        VoucherClaimedDialog.show(
          context,
          points: data is Map ? double.tryParse('${data['amount']}') : null,
          message: response.message,
        );
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    refreshController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
