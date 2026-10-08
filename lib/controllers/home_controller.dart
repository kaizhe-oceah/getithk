// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../imports.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/main_product_model.dart';
import '../models/page_banner_model.dart';
import '../models/product_tag_model.dart';

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

  /// The filter sheet's tags: only products with any of them. Empty: all.
  List<ProductTagModel> filterTags = [];

  List<int> get tagIds => [
    for (final ProductTagModel tag in filterTags) tag.id!,
  ];

  static const int _productsPerPage = 10;

  static const int _drawAmountType = 1;

  List<MainProductModel> products = [];

  bool isLoadingProducts = false;

  bool isLoadingMoreProducts = false;

  bool loadMoreFailed = false;
  bool hasMoreProducts = false;
  int _productsPage = 0;

  int _productsRequest = 0;

  HomeController() {
    sort.addListener(_loadProducts);
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
      // logged in only (it checks)
      NavigationService.context.read<AppController>().getWalletBalance(),
      ApiService.api.getProductCategories(
        onSuccess: (response) =>
            categories = CategoryModel.listFromJson(response.data),
      ),
    ]);

    bannerIndex.value = 0;
    categoryIndex = math.min(categoryIndex, math.max(0, categories.length - 1));

    // the products' first page too (it needs the selected category), so the
    // whole page leaves its skeleton at once
    await _loadProducts();

    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  void onSelectCategory(int index) {
    if (index == categoryIndex) return;

    categoryIndex = index;
    update();
    _loadProducts();
  }

  /// The products again, filtered by [tags] (none: all), unless that's the
  /// filter already.
  void onFilterTags(List<ProductTagModel> tags) {
    if (setEquals({for (final tag in tags) tag.id}, tagIds.toSet())) return;

    filterTags = tags;
    _loadProducts();
  }

  /// A filter chip's ✕: the products again without [tag].
  void onRemoveFilterTag(ProductTagModel tag) => onFilterTags([
    for (final ProductTagModel t in filterTags)
      if (t.id != tag.id) t,
  ]);

  Future<void> _loadProducts() async {
    final int request = ++_productsRequest;
    final int? categoryId = categories.elementAtOrNull(categoryIndex)?.id;

    isLoadingMoreProducts = false;
    loadMoreFailed = false;

    if (categoryId == null) {
      products = [];
      hasMoreProducts = false;
      isLoadingProducts = false;
      update();
      return;
    }

    isLoadingProducts = true;
    update();

    await _fetchProducts(categoryId: categoryId, page: 1, request: request);
    if (request != _productsRequest) return;

    isLoadingProducts = false;
    update();
  }

  Future<void> onLoadMore({bool retry = false}) async {
    final int? categoryId = categories.elementAtOrNull(categoryIndex)?.id;
    if (isLoadingProducts ||
        isLoadingMoreProducts ||
        !hasMoreProducts ||
        categoryId == null ||
        (loadMoreFailed && !retry)) {
      return;
    }

    final int request = _productsRequest;
    isLoadingMoreProducts = true;
    loadMoreFailed = false;
    update();

    final bool loaded = await _fetchProducts(
      categoryId: categoryId,
      page: _productsPage + 1,
      request: request,
    );
    if (request != _productsRequest) return;

    isLoadingMoreProducts = false;
    loadMoreFailed = !loaded;
    update();
  }

  Future<bool> _fetchProducts({
    required int categoryId,
    required int page,
    required int request,
  }) async {
    bool loaded = false;

    await ApiService.api.getProductMainProductListing(
      page: page,
      perPage: _productsPerPage,
      productCategoryId: categoryId,
      drawAmountType: _drawAmountType,
      sort: sort.value,
      tags: tagIds,
      onSuccess: (response) {
        if (request != _productsRequest) return;

        final Map data = response.data is Map ? response.data : {};
        final List<MainProductModel> items = MainProductModel.listFromJson(
          data['data'],
        );

        products = page == 1 ? items : [...products, ...items];
        _productsPage = parseInt(data['current_page'], page);
        hasMoreProducts = _productsPage < parseInt(data['total_pages']);
        loaded = true;
      },
    );

    return loaded;
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
