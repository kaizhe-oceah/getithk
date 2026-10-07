// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../imports.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/page_banner_model.dart';

class HomeController extends ChangeNotifier {
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  /// True while the home data loads (on open and on every refresh); the page
  /// shows its skeleton meanwhile.
  bool isLoading = true;

  List<BannerModel> banners = [];
  List<PageBannerModel> pageBanners = [];
  List<CategoryModel> categories = [];

  /// The carousel's current banner; only its dots listen to this.
  final ValueNotifier<int> bannerIndex = ValueNotifier(0);

  /// The highlighted category tab.
  int categoryIndex = 0;

  /// The category strip, scrolled to keep the tapped tab in the middle.
  final ScrollController categoryScrollController = ScrollController();

  /// The sort dropdown's choice.
  // TODO(getithk): sort the product list by it once there's a product API.
  final ValueNotifier<ProductSort> sort = ValueNotifier(
    ProductSort.recommended,
  );

  HomeController() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    update();

    await Future.wait([
      ApiService.api.getBanners(
        onSuccess: (response) => banners = BannerModel.listFromJson(
          response.data,
        ).where((e) => e.image != null).toList(),
      ),
      ApiService.api.getPageBanners(
        onSuccess: (response) => pageBanners = PageBannerModel.listFromJson(
          response.data,
        ).where((e) => e.image != null).toList(),
      ),
      ApiService.api.getProductCategories(
        onSuccess: (response) =>
            categories = CategoryModel.listFromJson(response.data),
      ),
    ]);

    bannerIndex.value = 0;
    categoryIndex = math.min(categoryIndex, math.max(0, categories.length - 1));
    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  void onSelectCategory(int index) {
    categoryIndex = index;
    update();
  }

  @override
  void dispose() {
    _isDisposed = true;
    refreshController.dispose();
    bannerIndex.dispose();
    categoryScrollController.dispose();
    sort.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
