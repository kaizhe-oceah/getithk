// Project imports:
import '../imports.dart';
import '../models/page_banner_model.dart';

class ActivityController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  bool isLoading = true;

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
    await Future.wait([
      _load(),
      context.read<AppController>().getWalletBalance(),
    ]);
    refreshController.refreshCompleted();
  }

  void onTapBanner(PageBannerModel banner) {
    if (banner.isInvitePoint) {
      AppNavigator.pushNamed(context, RouteName.inviteFriendsPage);
    } else if (banner.isAccumulateBox) {
      AppNavigator.pushNamed(context, RouteName.topupRewardPage);
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
