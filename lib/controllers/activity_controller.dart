// Project imports:
import '../imports.dart';
import '../models/page_banner_model.dart';

class ActivityController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  /// True while the banners load (on open and on every refresh); they show
  /// a skeleton the first time.
  bool isLoading = true;

  /// The page banners, all but the voucher one.
  List<PageBannerModel> banners = [];

  ActivityController() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    update();

    await ApiService.api.getPageBanners(
      onSuccess: (response) {
        banners = PageBannerModel.listFromJson(response.data)
            .where((element) => element.image != null && !element.isVoucher)
            .toList();
      },
    );

    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  // TODO(getithk): open the other promos once they have pages
  void onTapBanner(PageBannerModel banner) {
    if (banner.isInvitePoint) {
      AppNavigator.pushNamed(context, RouteName.inviteFriendsPage);
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
    if (!_isDisposed) notifyListeners();
  }
}
