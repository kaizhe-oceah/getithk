// Project imports:
import '../imports.dart';

class HomeController extends ChangeNotifier {
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  // TODO(getithk): load the banners from the API.
  List<String> banners = _placeholderBanners();

  static List<String> _placeholderBanners() =>
      List.filled(20, AppAssets.banner);

  Future<void> onRefresh() async {
    await 1.delay();
    banners = _placeholderBanners();
    refreshController.refreshCompleted();
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
