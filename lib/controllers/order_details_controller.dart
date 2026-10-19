// Project imports:
import '../imports.dart';
import '../models/shipping_order_detail_model.dart';

class OrderDetailsController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final int shippingId;

  final RefreshController refreshController = RefreshController();

  /// True while it loads (on open and on every refresh); a skeleton till it
  /// first has.
  bool isLoading = true;

  ShippingOrderDetailModel? order;

  OrderDetailsController({required this.shippingId}) {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    update();

    await ApiService.api.getShippingDetail(
      shippingId: shippingId,
      onSuccess: (response) {
        final dynamic data = response.data;
        if (data is Map) {
          order = ShippingOrderDetailModel.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
      },
    );

    isLoading = false;
    update();
  }

  Future<void> onRefresh() async {
    await _load();
    refreshController.refreshCompleted();
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
