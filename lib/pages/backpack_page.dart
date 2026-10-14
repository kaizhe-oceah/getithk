// Project imports:
import '../components/backpack/backpack_stock_card.dart';
import '../components/default/bottom_nav_bar_widget.dart';
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
    with AutomaticKeepAliveClientMixin<BackpackPage> {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (context.watch<AppController>().user == null) {
      return const LoginPage(isTab: true);
    }

    return ChangeNotifierProvider(
      create: (_) => BackpackController(),
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
        _tabBar(context, controller),
        Expanded(
          child: SmartRefresherWrapper(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            // nothing to load more of: just the no data widget, no footer
            enablePullUp: !controller.isLoading && controller.stocks.isNotEmpty,
            onLoading: controller.onLoading,
            showNoDataText: true,
            child: _stocks(context, controller),
          ),
        ),
        if (controller.canSelect) _actionBar(context, controller),
      ],
    );
  }

  Widget _tabBar(BuildContext context, BackpackController controller) {
    final Color primary = context.color.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kHorizontalPadding,
        12,
        kHorizontalPadding,
        4,
      ).r,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final BackpackTab tab in BackpackTab.values)
                    _tab(context, controller, tab),
                ],
              ),
            ),
          ),
          8.widthSpace,
          AppButtonWidget(
            text: controller.filterCategory == null
                ? context.tr(AppStrings.filter)
                : '${context.tr(AppStrings.filter)} (1)',
            isMinWidth: true,
            radius: 8,
            textSize: kFont12,
            fontWeight: FontWeight.w500,
            buttonColor: AppColors.whiteColor,
            borderColor: primary,
            textColor: primary,
            icon: Icon(Iconsax.setting_4_copy, size: 15.r, color: primary),
            iconSpace: 5,
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

  Widget _tab(
    BuildContext context,
    BackpackController controller,
    BackpackTab tab,
  ) {
    final bool selected = tab == controller.tab;
    final Color primary = context.color.primary;

    return InkWellWrapper(
      onTap: () => controller.onSelectTab(tab),
      child: Padding(
        padding: const EdgeInsets.only(right: 20).r,
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                context.tr(tab.label),
                fontSize: kFont14,
                fontWeight: FontWeight.w700,
                color: selected ? primary : AppColors.loginTextColor,
                textAlign: TextAlign.center,
              ),
              5.heightSpace,
              Container(
                height: 2.r,
                decoration: BoxDecoration(
                  color: selected ? primary : AppColors.transparentColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stocks(BuildContext context, BackpackController controller) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      kHorizontalPadding.r,
      12.r,
      kHorizontalPadding.r,
      controller.canSelect
          ? 16.r
          : BottomNavigationWidget.contentBottomInset(context),
    );
    final bool placeholder = controller.isLoading && controller.stocks.isEmpty;

    // centred in the space below the tabs, still pulling down to refresh
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
    return Container(
      padding: EdgeInsets.fromLTRB(
        kHorizontalPadding.r,
        12.r,
        kHorizontalPadding.r,
        BottomNavigationWidget.contentBottomInset(context),
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
          Wrap(
            spacing: 14.r,
            runSpacing: 8.r,
            children: [
              BackpackSelectAll(
                label: AppStrings.selectAll,
                value: controller.isAllSelected,
                onTap: controller.onSelectAll,
              ),
              BackpackSelectAll(
                label: AppStrings.selectAllDeliveryOnly,
                value: controller.isAllDeliveryOnlySelected,
                onTap: controller.onSelectAllDeliveryOnly,
              ),
              BackpackSelectAll(
                label: AppStrings.selectAllNonDeliveryOnly,
                value: controller.isAllNonDeliveryOnlySelected,
                onTap: controller.onSelectAllNonDeliveryOnly,
              ),
            ],
          ),
          12.heightSpace,
          BackpackCheckoutRow(
            amount: controller.selectedAmount,
            hasSelection: controller.selectedStocks.isNotEmpty,
            canRequestShipment: controller.canRequestShipment,
            canExchange: controller.canExchange,
            onRequestShipment: controller.onRequestShipment,
            onExchange: controller.onExchange,
          ),
        ],
      ),
    );
  }
}
