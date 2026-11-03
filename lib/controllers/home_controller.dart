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
import '../services/socket_service.dart';
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

  /// Bumped by each products load that starts over (another category, sort,
  /// filter, a refresh), so an older one's late response is dropped.
  int _productsLoad = 0;

  int page = 1;

  final Map<int, List<MainProductModel>> _cachedProducts = {};

  static const int _perPage = 10;

  static const int _drawAmountType = 1;

  late final Future<void> ready;

  late final StreamSubscription<Map<String, dynamic>> _liveUpdates;

  /// live.{id}.product-remaining, for each product of the category on show.
  final Map<int, StreamSubscription<Map<String, dynamic>>> _remainingUpdates =
      {};

  /// The products being fetched again, back in stock.
  final Set<int> _refetching = {};

  HomeController() {
    sort.addListener(onSortChanged);
    _liveUpdates = SocketService.mainProductUpdates.listen(_onLiveUpdate);
    ready = setInit();
  }

  /// main-product.update: {"products": [the changed ones, in full]}; their
  /// cards, on show or cached for a swipe, catch up.
  void _onLiveUpdate(Map<String, dynamic> data) {
    final dynamic list = data['products'];
    if (list is! List) return;

    final Map<int, Map<String, dynamic>> updates = {
      for (final dynamic item in list)
        if (item is Map && int.tryParse('${item['id']}') != null)
          int.parse('${item['id']}'): Map<String, dynamic>.from(item),
    };
    if (updates.isEmpty) return;

    bool changed = false;
    for (final MainProductModel product in _allProducts) {
      final Map<String, dynamic>? live = updates[product.id];
      if (live == null) continue;
      product.applyLiveUpdate(live);
      changed = true;
    }
    if (changed) update();
  }

  /// product-remaining.update for [id]'s channel; many channels share the
  /// event, so one without [id] in it isn't applied.
  void _onRemainingUpdate(int id, Map<String, dynamic> data) {
    if ('${data['main_product_id']}' != '$id') return;

    bool changed = false;
    bool restocked = false;
    for (final MainProductModel product in _allProducts) {
      if (product.id != id) continue;
      if (product.applyRemainingUpdate(data)) restocked = true;
      changed = true;
    }
    if (changed) update();
    if (restocked) _refetchProduct(id);
  }

  /// Back in stock: [id] fetched again for the player's own values, which
  /// the public update can't carry.
  Future<void> _refetchProduct(int id) async {
    if (!_refetching.add(id)) return;

    await ApiService.api.getSubProductListing(
      mainProductId: id,
      onSuccess: (response) {
        final dynamic data = response.data;
        final dynamic json = data is Map ? data['main_product'] : null;
        if (json is! Map) return;

        final Map<String, dynamic> fetched = Map<String, dynamic>.from(json);
        for (final MainProductModel product in _allProducts) {
          if (product.id == id) product.applyFetched(fetched);
        }
      },
    );

    _refetching.remove(id);
    update();
  }

  /// On the channels of the products on show, and off the rest.
  void _syncRemainingUpdates() {
    final Set<int> ids = {
      for (final MainProductModel product in products) ?product.id,
    };

    _remainingUpdates.removeWhere((id, subscription) {
      if (ids.contains(id)) return false;
      subscription.cancel();
      return true;
    });
    for (final int id in ids) {
      _remainingUpdates[id] ??= SocketService.productRemainingUpdates(
        id,
      ).listen((data) => _onRemainingUpdate(id, data));
    }
  }

  Iterable<MainProductModel> get _allProducts => [
    ...products,
    for (final List<MainProductModel> cached in _cachedProducts.values)
      ...cached,
  ];

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
    final int load = ++_productsLoad;

    await Future.wait([
      getBanners(),
      getPageBanners(),
      // the products need only the categories, not the rest
      getCategories().then((_) => getProductListing()),
      NavigationService.context.read<AppController>().getWalletBalance(),
    ]);

    refreshController.refreshCompleted();
    isLoading = false;
    if (load == _productsLoad) isLoadingProducts = false;
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
    final int load = _productsLoad;

    await ApiService.api.getProductMainProductListing(
      page: page,
      perPage: _perPage,
      productCategoryId: categoryId,
      drawAmountType: _drawAmountType,
      sort: sort.value,
      tags: tagIds,
      onSuccess: (response) {
        if (load != _productsLoad) return;

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
      },
      onError: (_) => refreshController.loadFailed(),
    );
  }

  Future<void> onRefreshProducts() async {
    final int load = ++_productsLoad;
    isLoadingProducts = true;
    page = 1;
    products = [...?_cachedProducts[selectedCategoryId]];
    update();

    await getProductListing();
    // a newer load (swiped on again) took over: it ends the loading, else
    // this one would show the empty text before that one's products are in
    if (load != _productsLoad) return;

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
    _liveUpdates.cancel();
    for (final subscription in _remainingUpdates.values) {
      subscription.cancel();
    }
    _remainingUpdates.clear();
    refreshController.dispose();
    bannerIndex.dispose();
    categoryScrollController.dispose();
    sort.dispose();
    super.dispose();
  }

  // every change to the products comes through here
  void update() {
    if (_isDisposed) return;

    _syncRemainingUpdates();
    notifyListeners();
  }
}
