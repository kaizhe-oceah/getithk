// Project imports:
import '../imports.dart';
import '../models/topup_commission_model.dart';

class AgentCommissionController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  /// True while the totals and the first page load (on open and on every
  /// refresh); they show a skeleton meanwhile.
  bool isLoading = true;

  TopupCommissionSummaryModel? summary;

  List<TopupCommissionModel> commissions = [];

  int page = 1;

  static const int _perPage = 20;

  /// Bumped by each refresh, so an older one's late response is dropped.
  int _load = 0;

  AgentCommissionController() {
    onRefresh();
  }

  Future<void> onRefresh() async {
    final int load = ++_load;
    isLoading = true;
    page = 1;
    commissions = [];
    update();

    await _getCommissions(load);
    refreshController.refreshCompleted();
    if (load != _load) return;

    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await _getCommissions(_load);
    update();
  }

  Future<void> _getCommissions(int load) async {
    await ApiService.api.getTopupCommissionListing(
      page: page,
      perPage: _perPage,
      onSuccess: (response) {
        if (load != _load) return;

        final dynamic data = response.data;
        if (data is! Map) {
          refreshController.loadNoData();
          return;
        }
        final Map<String, dynamic> json = Map.from(data);
        summary = TopupCommissionSummaryModel.fromJson(json);
        commissions.addAll(TopupCommissionModel.listFromJson(json['data']));

        final int currentPage = parseInt(json['current_page'], page);
        final int totalPages = parseInt(json['total_pages']);
        if (currentPage < totalPages) {
          page = currentPage + 1;
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
      },
      onError: (_) => refreshController.loadFailed(),
    );
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
