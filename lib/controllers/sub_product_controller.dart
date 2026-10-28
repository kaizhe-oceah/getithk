// Project imports:
import '../imports.dart';
import '../models/main_product_model.dart';
import '../models/sub_product_model.dart';
import '../services/socket_service.dart';
import '../utils/draw_helper.dart';

class SubProductController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  MainProductModel product;

  bool isLoading = true;

  List<SubProductModel> subProducts = [];

  List<MainProductGradeModel> grades = [];
  SubProductModel? combProduct;

  final List<StreamSubscription<Map<String, dynamic>>> _liveUpdates = [];

  SubProductController({required this.product}) {
    final int? id = product.id;
    if (id != null) {
      _liveUpdates.addAll([
        SocketService.productRemainingUpdates(id).listen(_onRemainingUpdate),
        SocketService.playerProductRemainingUpdates(
          id,
        ).listen(_onPlayerRemainingUpdate),
      ]);
    }
    _load();
  }

  /// product-remaining.update: the draws left, as anyone draws.
  void _onRemainingUpdate(Map<String, dynamic> data) {
    _applyRemaining(data);
    update();
  }

  /// player-product-remaining.update: this player's own draws left.
  void _onPlayerRemainingUpdate(Map<String, dynamic> data) {
    _applyRemaining(data);
    product.applyPlayerUpdate(data);
    update();
  }

  void _applyRemaining(Map<String, dynamic> data) {
    product.applyLiveUpdate(data);
    // as after a draw of our own
    if (data.containsKey('remaining_draws') &&
        !data.containsKey('is_sold_out')) {
      product.isSoldOut = product.remainingDraws <= 0;
    }
  }

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
    for (final StreamSubscription<Map<String, dynamic>> updates
        in _liveUpdates) {
      updates.cancel();
    }
    refreshController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
