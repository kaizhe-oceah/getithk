// Project imports:
import '../imports.dart';
import '../models/main_product_model.dart';
import '../models/sub_product_model.dart';
import '../utils/draw_helper.dart';

class SubProductController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  /// The product tapped in the listing, until the sub-product-listing API
  /// sends a fresh one (stock, top-up progress).
  MainProductModel product;

  /// True while the prizes load (on open and on every refresh); they show
  /// a skeleton the first time.
  bool isLoading = true;

  List<SubProductModel> subProducts = [];

  /// The product's grades (`main_product_grades`), in their sort_order.
  List<MainProductGradeModel> grades = [];

  /// A Combo product's one prize (`comb_product`); when set, the page shows
  /// only it.
  SubProductModel? combProduct;

  SubProductController({required this.product}) {
    _load();
  }

  /// [subProducts] grouped by grade, in [grades]' order (一等獎, 二等獎, …);
  /// a grade with no prizes is left out, prizes of a grade [grades] doesn't
  /// list come next, in the API's order, and 尾賞 always comes last.
  List<List<SubProductModel>> get gradeGroups {
    final Map<int?, List<SubProductModel>> byGrade = {};
    for (final SubProductModel item in subProducts) {
      byGrade.putIfAbsent(item.gradeId, () => []).add(item);
    }

    final List<SubProductModel>? last = byGrade.remove(ProductGrade.last.value);

    final List<List<SubProductModel>> groups = [];
    for (final MainProductGradeModel grade in grades) {
      final List<SubProductModel>? items = byGrade.remove(grade.productGradeId);
      if (items != null) groups.add(items);
    }
    return [...groups, ...byGrade.values, ?last];
  }

  /// The prizes and the product, with the balance for the app bar.
  Future<void> _load() async {
    final int? id = product.id;
    if (id == null) {
      isLoading = false;
      update();
      return;
    }

    isLoading = true;
    update();

    await Future.wait([
      context.read<AppController>().getWalletBalance(),
      ApiService.api.getSubProductListing(
        mainProductId: id,
        onSuccess: (response) {
          final Map data = response.data is Map ? response.data : {};
          final Object? mainProduct = data['main_product'];
          final Object? comb = data['comb_product'];

          if (mainProduct is Map) {
            product = MainProductModel.fromJson(
              Map<String, dynamic>.from(mainProduct),
            );
          }
          subProducts = SubProductModel.listFromJson(data['sub_products']);
          grades =
              List.from(data['main_product_grades'] ?? [])
                  .map((element) => MainProductGradeModel.fromJson(element))
                  .toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          combProduct = comb is Map
              ? SubProductModel.fromJson(Map<String, dynamic>.from(comb))
              : null;
        },
      ),
    ]);

    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
  }

  Future<void> onDraw(int count) async {
    await DrawHelper.drawProduct(product, count);
    update();
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
