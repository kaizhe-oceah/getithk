// Project imports:
import '../components/default/month_picker_dialog.dart';
import '../imports.dart';
import '../models/sell_history_model.dart';

class SellHistoryController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final RefreshController refreshController = RefreshController();

  bool isLoading = true;

  List<SellHistoryModel> orders = [];

  int page = 1;

  static const int _perPage = 20;

  DateTime? month;

  String? get monthTime =>
      month == null ? null : DateFormat('yyyy-MM').format(month!);

  SellHistoryController() {
    onRefresh();
  }

  Future<void> onRefresh() async {
    isLoading = true;
    page = 1;
    orders = [];
    update();
    await _getSellHistory();
    refreshController.refreshCompleted();
    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await _getSellHistory();
    update();
  }

  Future<void> onPickMonth() async {
    final ({DateTime? month})? picked = await MonthPickerDialog.show(
      context,
      initialMonth: month,
      lastDate: DateTime.now(),
      canReset: month != null,
    );
    if (picked != null) _setMonth(picked.month);
  }

  void _setMonth(DateTime? value) {
    if (value == month) return;

    month = value;
    update();
    refreshController.requestRefresh();
  }

  Future<void> _getSellHistory() async {
    final String? requested = monthTime;

    await ApiService.api.getSellHistory(
      page: page,
      perPage: _perPage,
      monthTime: requested,
      onSuccess: (response) {
        if (requested != monthTime) return;

        final dynamic data = response.data;
        if (data is! Map) {
          refreshController.loadNoData();
          return;
        }
        orders.addAll(SellHistoryModel.listFromJson(data['data']));

        final int currentPage = parseInt(data['current_page'], page);
        final int totalPages = parseInt(data['total_pages']);
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
