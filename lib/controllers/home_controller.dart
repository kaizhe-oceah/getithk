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

  /// Each category's products so far, by category id: a swipe shows the next
  /// category's cards from here while dragging, and a category seen already
  /// shows at once. A refresh, filter or sort clears it.
  final Map<int, _CategoryProducts> _cache = {};
  final Set<int> _prefetching = {};
  int _cacheGeneration = 0;

  /// While a cached category shows and its first page reloads under it.
  bool _reloadingCached = false;

  HomeController() {
    sort.addListener(_onSort);
    _load();
  }

  Future<void> _load() async {
    _clearCache();
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
    _clearCache();
    _loadProducts();
  }

  void _onSort() {
    _clearCache();
    _loadProducts();
  }

  void _clearCache() {
    _cache.clear();
    _prefetching.clear();
    _cacheGeneration++;
  }

  /// The category at [index]'s cached products: null until they've loaded.
  List<MainProductModel>? cachedProducts(int index) =>
      _cache[_categoryIdAt(index)]?.items;

  /// The category at [index]'s id; null past either end (elementAtOrNull
  /// throws below 0).
  int? _categoryIdAt(int index) =>
      index >= 0 && index < categories.length ? categories[index].id : null;

  /// The category at [index]'s first page into the cache, so a swipe toward
  /// it shows its cards; nothing if it's cached or on its way.
  Future<void> prefetchCategory(int index) async {
    final int? categoryId = _categoryIdAt(index);
    if (categoryId == null ||
        _cache.containsKey(categoryId) ||
        !_prefetching.add(categoryId)) {
      return;
    }

    final int generation = _cacheGeneration;
    await ApiService.api.getProductMainProductListing(
      page: 1,
      perPage: _productsPerPage,
      productCategoryId: categoryId,
      drawAmountType: _drawAmountType,
      sort: sort.value,
      tags: tagIds,
      onSuccess: (response) {
        if (generation != _cacheGeneration) return;
        _cache[categoryId] = _CategoryProducts.fromPage(response.data, page: 1);
      },
    );
    if (generation != _cacheGeneration) return;

    _prefetching.remove(categoryId);
    update();
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

    // a category seen already shows at once while its first page reloads;
    // any other gets the skeleton
    final _CategoryProducts? cached = _cache[categoryId];
    if (cached != null) {
      products = cached.items;
      _productsPage = cached.page;
      hasMoreProducts = cached.hasMore;
    }
    isLoadingProducts = cached == null;
    _reloadingCached = cached != null;
    update();

    await _fetchProducts(categoryId: categoryId, page: 1, request: request);
    if (request != _productsRequest) return;

    isLoadingProducts = false;
    _reloadingCached = false;
    update();
  }

  Future<void> onLoadMore({bool retry = false}) async {
    final int? categoryId = categories.elementAtOrNull(categoryIndex)?.id;
    if (isLoadingProducts ||
        _reloadingCached ||
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

        final _CategoryProducts next = _CategoryProducts.fromPage(
          response.data,
          page: page,
          before: page == 1 ? const [] : products,
        );
        products = next.items;
        _productsPage = next.page;
        hasMoreProducts = next.hasMore;
        _cache[categoryId] = next;
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

/// A category's products so far: [items] up to [page], and whether there are
/// more.
class _CategoryProducts {
  final List<MainProductModel> items;
  final int page;
  final bool hasMore;

  const _CategoryProducts(this.items, this.page, this.hasMore);

  /// [before] plus the listing API's [page] in [data].
  factory _CategoryProducts.fromPage(
    dynamic data, {
    required int page,
    List<MainProductModel> before = const [],
  }) {
    final Map map = data is Map ? data : {};
    final int current = parseInt(map['current_page'], page);

    return _CategoryProducts(
      [...before, ...MainProductModel.listFromJson(map['data'])],
      current,
      current < parseInt(map['total_pages']),
    );
  }
}
