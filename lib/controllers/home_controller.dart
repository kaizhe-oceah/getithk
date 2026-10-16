// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../imports.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/main_product_model.dart';
import '../models/page_banner_model.dart';
import '../models/product_tag_model.dart';
import '../services/draw_video_service.dart';
import '../utils/draw_helper.dart';

class HomeController extends ChangeNotifier {
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  bool isLoading = true;

  List<BannerModel> banners = [];
  List<PageBannerModel> pageBanners = [];
  List<CategoryModel> categories = [];

  final ValueNotifier<int> bannerIndex = ValueNotifier(0);

  int categoryIndex = 0;

  final ScrollController categoryScrollController = ScrollController();

  final ValueNotifier<ProductSort> sort = ValueNotifier(
    ProductSort.recommended,
  );

  List<ProductTagModel> filterTags = [];

  List<int> get tagIds => [
    for (final ProductTagModel tag in filterTags) tag.id!,
  ];

  List<MainProductModel> products = [];

  bool isLoadingProducts = false;

  int page = 1;

  final Map<int, List<MainProductModel>> _cachedProducts = {};

  static const int _perPage = 10;

  static const int _drawAmountType = 1;

  late final Future<void> ready;

  HomeController() {
    sort.addListener(onSortChanged);
    ready = setInit();
  }

  static HomeController? _preloaded;

  static Future<void> preload() => (_preloaded = HomeController()).ready;

  static HomeController? takePreloaded() {
    final HomeController? controller = _preloaded;
    _preloaded = null;
    return controller;
  }

  int? get selectedCategoryId => _categoryIdAt(categoryIndex);

  int? _categoryIdAt(int index) =>
      index >= 0 && index < categories.length ? categories[index].id : null;

  List<MainProductModel>? cachedProducts(int index) =>
      _cachedProducts[_categoryIdAt(index)];

  Future<void> setInit() async {
    await onRefresh();
    DrawVideoService.preload();
  }

  Future<void> onRefresh() async {
    isLoading = true;
    page = 1;
    products = [];
    _cachedProducts.clear();

    await Future.wait([
      getBanners(),
      getPageBanners(),
      getCategories(),
      NavigationService.context.read<AppController>().getWalletBalance(),
    ]);
    await getProductListing();

    refreshController.refreshCompleted();
    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await getProductListing();
    update();
  }

  Future<void> getBanners() async {
    await ApiService.api.getBanners(
      onSuccess: (response) {
        banners = List.from(response.data)
            .map((element) => BannerModel.fromJson(element))
            .where((element) => element.image != null)
            .toList();
        bannerIndex.value = 0;
      },
    );
  }

  Future<void> getPageBanners() async {
    await ApiService.api.getPageBanners(
      onSuccess: (response) {
        pageBanners = List.from(response.data)
            .map((element) => PageBannerModel.fromJson(element))
            .where((element) => element.image != null)
            .toList();
      },
    );
  }

  Future<void> getCategories() async {
    await ApiService.api.getProductCategories(
      onSuccess: (response) {
        categories = List.from(
          response.data,
        ).map((element) => CategoryModel.fromJson(element)).toList();
        categoryIndex = math.min(
          categoryIndex,
          math.max(0, categories.length - 1),
        );
      },
    );
  }

  Future<void> getProductListing() async {
    final int? categoryId = selectedCategoryId;
    if (categoryId == null) {
      refreshController.loadNoData();
      return;
    }

    await ApiService.api.getProductMainProductListing(
      page: page,
      perPage: _perPage,
      productCategoryId: categoryId,
      drawAmountType: _drawAmountType,
      sort: sort.value,
      tags: tagIds,
      onSuccess: (response) {
        if (categoryId != selectedCategoryId) return;

        final List<MainProductModel> listing = List.from(
          response.data['data'],
        ).map((element) => MainProductModel.fromJson(element)).toList();

        if (page == 1) {
          products = listing;
          _cachedProducts[categoryId] = [...listing];
        } else {
          products.addAll(listing);
        }

        int totalPages = response.data['total_pages'];
        if (page < totalPages) {
          page += 1;
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }

        update();
      },
      onError: (_) => refreshController.loadFailed(),
    );
  }

  Future<void> onRefreshProducts() async {
    isLoadingProducts = true;
    page = 1;
    products = [...?_cachedProducts[selectedCategoryId]];
    update();

    await getProductListing();

    isLoadingProducts = false;
    update();
  }

  Future<void> prefetchCategory(int index) async {
    final int? categoryId = _categoryIdAt(index);
    if (categoryId == null || _cachedProducts.containsKey(categoryId)) return;

    await ApiService.api.getProductMainProductListing(
      page: 1,
      perPage: _perPage,
      productCategoryId: categoryId,
      drawAmountType: _drawAmountType,
      sort: sort.value,
      tags: tagIds,
      onSuccess: (response) {
        _cachedProducts[categoryId] = List.from(
          response.data['data'],
        ).map((element) => MainProductModel.fromJson(element)).toList();
        update();
      },
    );
  }

  Future<void> onDraw(MainProductModel product, int count) async {
    await DrawHelper.drawProduct(product, count);
    update();
  }

  void onSelectCategory(int index) {
    if (index == categoryIndex) return;

    categoryIndex = index;
    onRefreshProducts();
  }

  void onFilterTags(List<ProductTagModel> tags) {
    if (setEquals({for (final tag in tags) tag.id}, tagIds.toSet())) return;

    filterTags = tags;
    _cachedProducts.clear();
    onRefreshProducts();
  }

  void onSortChanged() {
    _cachedProducts.clear();
    onRefreshProducts();
  }

  void onRemoveFilterTag(ProductTagModel tag) => onFilterTags([
    for (final ProductTagModel t in filterTags)
      if (t.id != tag.id) t,
  ]);

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
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
