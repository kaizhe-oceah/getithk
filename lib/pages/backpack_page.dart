// Project imports:
import '../components/backpack/backpack_stock_card.dart';
import '../components/default/bottom_nav_bar_widget.dart';
import '../components/default/tab_bar_widget.dart';
import '../components/points_pill.dart';
import '../controllers/backpack_controller.dart';
import '../imports.dart';
import '../models/backpack_model.dart';
import 'login_page.dart';

class BackpackPage extends StatefulWidget {
  bool get wantKeepAlive => true;

  const BackpackPage({super.key});

  static const int _columns = 2;
  static double get _spacing => 10.r;

  static EdgeInsets get _filterPadding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r;

  @override
  State<BackpackPage> createState() => _BackpackPageState();
}

class _BackpackPageState extends State<BackpackPage>
    with AutomaticKeepAliveClientMixin<BackpackPage>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (context.watch<AppController>().user == null) {
      return const LoginPage(isTab: true);
    }

    return ChangeNotifierProvider(
      create: (_) => BackpackController(vsync: this),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            centerTitle: false,
            backgroundColor: AppColors.whiteColor,
            title: AppLogo(height: 28.r),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8).r,
                child: const Center(child: PointsPill()),
              ),
            ],
            bottomWidget: Consumer<BackpackController>(
              builder: (context, controller, _) => _tabBar(context, controller),
            ),
          ),
        ],
        child: Consumer<BackpackController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, BackpackController controller) {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: controller.tabController,
            children: [
              for (final BackpackTab tab in BackpackTab.values)
                _page(context, controller, tab),
            ],
          ),
        ),
        if (controller.canSelect) _actionBar(context, controller),
      ],
    );
  }

  /// A tab's page: its stocks once it's the current tab, a skeleton till
  /// then (while swiping over to it).
  Widget _page(
    BuildContext context,
    BackpackController controller,
    BackpackTab tab,
  ) {
    final bool isCurrent = tab == controller.tab;

    return SmartRefresherWrapper(
      controller: controller.refreshControllers[tab]!,
      onRefresh: controller.onPullRefresh,
      // nothing to load more of: just the no data widget, no footer
      enablePullUp:
          isCurrent && !controller.isLoading && controller.stocks.isNotEmpty,
      onLoading: controller.onLoading,
      showNoDataText: true,
      child: _stocks(context, controller, tab),
    );
  }

  Widget _tabBar(BuildContext context, BackpackController controller) {
    final Color primary = context.color.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8).r,
      child: Row(
        children: [
          Expanded(
            child: TabBarWidget(
              tabController: controller.tabController,
              labels: [
                for (final BackpackTab tab in BackpackTab.values)
                  context.tr(tab.label),
              ],
              tabAlignment: TabAlignment.start,
            ),
          ),
          8.widthSpace,
          AppButtonWidget(
            text: controller.filterCategory == null
                ? context.tr(AppStrings.filter)
                : '${context.tr(AppStrings.filter)} (1)',
            isMinWidth: true,
            radius: 10,
            textSize: kFont12,
            fontWeight: FontWeight.w500,
            buttonColor: AppColors.whiteColor,
            borderColor: primary,
            textColor: primary,
            icon: Icon(Iconsax.setting_4_copy, size: 15.r, color: primary),
            padding: BackpackPage._filterPadding,
            onTap: () => BottomSheetHelper.categoryFilter(
              selected: controller.filterCategory,
              onConfirm: controller.onFilterCategory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stocks(
    BuildContext context,
    BackpackController controller,
    BackpackTab tab,
  ) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      kHorizontalPadding.r,
      12.r,
      kHorizontalPadding.r,
      // 卡牌 has the action bar under it
      tab == BackpackTab.cards
          ? 16.r
          : BottomNavigationWidget.contentBottomInset(context),
    );
    final bool placeholder =
        tab != controller.tab ||
        (controller.isLoading && controller.stocks.isEmpty);
    if (!placeholder && controller.stocks.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: NoDataWidget()),
            ),
          ),
        ],
      );
    }

    final List<BackpackModel> stocks = placeholder
        ? List.generate(4, (_) => BackpackModel.placeholder())
        : controller.stocks;

    return ListView.builder(
      padding: padding,
      itemCount: (stocks.length / BackpackPage._columns).ceil(),
      itemBuilder: (context, row) => Padding(
        padding: EdgeInsets.only(bottom: BackpackPage._spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int column = 0; column < BackpackPage._columns; column++) ...[
              if (column > 0) SizedBox(width: BackpackPage._spacing),
              Expanded(
                child: _stockCard(
                  controller,
                  stocks.elementAtOrNull(row * BackpackPage._columns + column),
                  isLoading: placeholder,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stockCard(
    BackpackController controller,
    BackpackModel? stock, {
    bool isLoading = false,
  }) {
    if (stock == null) return const SizedBox.shrink();

    return BackpackStockCard(
      stock: stock,
      selected: controller.isSelected(stock),
      isLoading: isLoading,
      onSelect: controller.canSelect ? () => controller.onToggle(stock) : null,
    );
  }

  Widget _actionBar(BuildContext context, BackpackController controller) {
    final EdgeInsets sides = EdgeInsets.symmetric(
      horizontal: kHorizontalPadding.r,
    );

    return Container(
      padding: EdgeInsets.only(
        top: 12.r,
        bottom: BottomNavigationWidget.contentBottomInset(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.wOpacity(0.08),
            blurRadius: 8.r,
            offset: Offset(0, -2.r),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // one line that scrolls, rather than wrap onto a second
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: sides,
            child: Row(
              children: [
                BackpackSelectAll(
                  label: AppStrings.selectAll,
                  value: controller.isAllSelected,
                  enabled: controller.stocks.isNotEmpty,
                  onTap: controller.onSelectAll,
                ),
                16.widthSpace,
                BackpackSelectAll(
                  label: AppStrings.selectAllDeliveryOnly,
                  value: controller.isAllDeliveryOnlySelected,
                  enabled: controller.deliveryOnly.isNotEmpty,
                  onTap: controller.onSelectAllDeliveryOnly,
                ),
                16.widthSpace,
                BackpackSelectAll(
                  label: AppStrings.selectAllNonDeliveryOnly,
                  value: controller.isAllNonDeliveryOnlySelected,
                  enabled: controller.nonDeliveryOnly.isNotEmpty,
                  onTap: controller.onSelectAllNonDeliveryOnly,
                ),
              ],
            ),
          ),
          8.heightSpace,
          Padding(
            padding: sides,
            child: BackpackCheckoutRow(
              amount: controller.selectedAmount,
              selectedCount: controller.selectedStocks.length,
              canRequestShipment: controller.canRequestShipment,
              canExchange: controller.canExchange,
              onRequestShipment: controller.onRequestShipment,
              onExchange: controller.onExchange,
            ),
          ),
        ],
      ),
    );
  }
}
