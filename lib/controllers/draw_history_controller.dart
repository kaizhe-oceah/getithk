// Project imports:
import '../components/default/month_picker_dialog.dart';
import '../imports.dart';
import '../models/draw_record_model.dart';
import '../models/product_grade_model.dart';

class DrawHistoryController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final TickerProvider _vsync;

  /// The tabs after 全部, from the API.
  List<ProductGradeModel> grades = [];

  /// The tabs in the app bar: 全部 alone till [grades] are in, then one for
  /// each of them too.
  late TabController tabController = _newTabController();

  /// One per tab: each tab's page has its own refresher, and while swiping
  /// two are on screen at once.
  final Map<int, RefreshController> _refreshControllers = {};

  RefreshController refreshControllerAt(int index) =>
      _refreshControllers.putIfAbsent(index, RefreshController.new);

  /// The current tab's.
  RefreshController get refreshController => refreshControllerAt(tabIndex);

  int tabIndex = 0;

  /// The current tab's grade; null on 全部.
  int? get gradeId => tabIndex == 0 ? null : grades[tabIndex - 1].id;

  /// True while the first page loads (on open, on every refresh, tab and
  /// month change); the list shows a skeleton meanwhile.
  bool isLoading = true;

  List<DrawRecordModel> records = [];

  int page = 1;

  static const int _perPage = 20;

  DateTime? month;

  String? get monthTime =>
      month == null ? null : DateFormat('yyyy-MM').format(month!);

  /// Bumped by each load that starts over, so an older one's late response
  /// is dropped.
  int _load = 0;

  DrawHistoryController({required TickerProvider vsync}) : _vsync = vsync {
    _getGrades();
    onRefresh();
  }

  TabController _newTabController() =>
      TabController(length: grades.length + 1, vsync: _vsync)
        ..addListener(_onTabChanged);

  /// [record]'s grade: the tab of that name, else its numeral.
  ProductGrade? gradeOf(DrawRecordModel record) =>
      grades
          .where((element) => element.name == record.gradeName)
          .firstOrNull
          ?.grade ??
      ProductGrade.fromName(record.gradeName);

  Future<void> _getGrades() async {
    await ApiService.api.getProductGradeListing(
      onSuccess: (response) {
        final List<ProductGradeModel> listing = ProductGradeModel.listFromJson(
          response.data,
        );
        if (_isDisposed || listing.isEmpty) return;

        // still on 全部: the only tab till now
        final TabController old = tabController;
        grades = listing;
        tabController = _newTabController();
        update();
        // the tab bar lets go of it as it rebuilds
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      },
    );
  }

  /// A tab tapped or swiped to: once it settles, its records.
  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    if (tabController.index == tabIndex) return;

    tabIndex = tabController.index;
    onRefresh();
  }

  Future<void> onRefresh() async {
    final int load = ++_load;
    // the tab's own, should it change meanwhile
    final RefreshController refresher = refreshController;
    isLoading = true;
    page = 1;
    records = [];
    update();

    await _getDrawHistory();
    refresher.refreshCompleted();
    if (load != _load) return;

    isLoading = false;
    update();
  }

  Future<void> onLoading() async {
    await _getDrawHistory();
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

  Future<void> _getDrawHistory() async {
    final int load = _load;
    final RefreshController refresher = refreshController;

    await ApiService.api.getDrawHistory(
      page: page,
      perPage: _perPage,
      gradeId: gradeId,
      monthTime: monthTime,
      onSuccess: (response) {
        if (load != _load) return;

        final dynamic data = response.data;
        if (data is! Map) {
          refresher.loadNoData();
          return;
        }
        records.addAll(DrawRecordModel.listFromJson(data['data']));

        final int currentPage = parseInt(data['current_page'], page);
        final int totalPages = parseInt(data['total_pages']);
        if (currentPage < totalPages) {
          page = currentPage + 1;
          refresher.loadComplete();
        } else {
          refresher.loadNoData();
        }
      },
      onError: (_) => refresher.loadFailed(),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    tabController.dispose();
    for (final RefreshController controller in _refreshControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
