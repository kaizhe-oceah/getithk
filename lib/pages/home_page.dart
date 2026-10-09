// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/rendering.dart'
    show RenderAbstractViewport, RenderProxySliver, RenderSliver;

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import '../components/main_product/main_product_card.dart';
import '../components/main_product/main_product_empty.dart';
import '../components/main_product/product_tag_chip.dart';
import '../components/points_pill.dart';
import '../controllers/home_controller.dart';
import '../imports.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/main_product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const double _bannerAspectRatio = 15 / 8;
  static const double _pageBannerAspectRatio = 2.2;

  static const double _categoryLogoAspectRatio = 2.7;
  static double get _categoryLogoHeight => 30.r;
  static double get _categoryLogoWidth =>
      _categoryLogoHeight * _categoryLogoAspectRatio;
  static EdgeInsets get _categoryTabPadding =>
      const EdgeInsets.fromLTRB(8, 14, 8, 0).r;

  @override
  State<HomePage> createState() => _HomePageState();

  static EdgeInsets get _filterBarPadding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r;
  static const FontWeight _filterBarWeight = FontWeight.w500;

  static const double _backgroundAspectRatio = 2560 / 1184;

  static const Color _productsBackgroundColor = Color(0xFF2B1766);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late final AnimationController _swipe = AnimationController.unbounded(
    vsync: this,
  );
  double _dragDx = 0;
  bool _swiping = false;

  double _productsTop = 0;

  final ScrollController _scroll = ScrollController();
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  final Map<int, GlobalKey> _tabKeys = {};

  late final AnimationController _tabLine = AnimationController.unbounded(
    vsync: this,
  );
  double _tabLineFrom = 0;
  double _tabLineTo = 0;

  static const Duration _swipeDuration = Duration(milliseconds: 280);

  @override
  void dispose() {
    _swipe.dispose();
    _tabLine.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [_appBar(context)],
        child: Consumer<HomeController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, HomeController controller) {
    final EdgeInsets sidePadding = EdgeInsets.symmetric(
      horizontal: kHorizontalPadding.r,
    );

    return Stack(
      key: _stackKey,
      children: [
        const Positioned.fill(
          child: Column(
            children: [
              Expanded(child: ColoredBox(color: AppColors.whiteColor)),
              Expanded(
                child: ColoredBox(color: HomePage._productsBackgroundColor),
              ),
            ],
          ),
        ),

        RawGestureDetector(
          gestures: {
            _ProductsSwipeRecognizer:
                GestureRecognizerFactoryWithHandlers<_ProductsSwipeRecognizer>(
                  () => _ProductsSwipeRecognizer(allows: _startsOnProducts),
                  (recognizer) => recognizer
                    ..onStart = ((_) => _onSwipeStart(controller))
                    ..onUpdate = ((details) =>
                        _onSwipeUpdate(controller, details.primaryDelta ?? 0))
                    ..onEnd = ((details) =>
                        _onSwipeEnd(controller, details.primaryVelocity ?? 0))
                    ..onCancel = (() => _onSwipeEnd(controller, 0)),
                ),
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final ScrollMetrics metrics = notification.metrics;
              if (metrics.axis == Axis.vertical &&
                  metrics.extentAfter < metrics.viewportDimension) {
                controller.onLoadMore();
              }
              return false;
            },
            child: SmartRefresherWrapper(
              controller: controller.refreshController,
              onRefresh: controller.onRefresh,
              scrollController: _scroll,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ColoredBox(
                      key: _headerKey,
                      color: AppColors.whiteColor,
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: sidePadding,
                              child: controller.isLoading
                                  ? _skeleton()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (controller.banners.isNotEmpty) ...[
                                          _bannerCarousel(context, controller),
                                          10.heightSpace,
                                        ],
                                        if (controller
                                            .pageBanners
                                            .isNotEmpty) ...[
                                          _pageBanners(context, controller),
                                          12.heightSpace,
                                        ],
                                        if (controller.categories.isNotEmpty)
                                          _categoryTabs(context, controller),
                                      ],
                                    ),
                            ),
                            12.heightSpace,

                            Padding(
                              padding: sidePadding,
                              child: _filterBar(context, controller),
                            ),
                            if (controller.filterTags.isNotEmpty) ...[
                              6.heightSpace,
                              _activeFilters(context, controller),
                            ],
                            12.heightSpace,
                          ],
                        ),
                      ),
                    ),
                  ),

                  _products(context, controller),
                ],
              ),
            ),
          ),
        ),

        _swipeNeighbor(context, controller),
      ],
    );
  }

  Widget _products(BuildContext context, HomeController controller) {
    final double width = MediaQuery.sizeOf(context).width;

    return _FixedBackgroundSliver(
      image: DecorationImage(
        image: ResizeImage.resizeIfNeeded(
          _cacheWidth(context, width),
          null,
          AssetImage(AppAssets.homeBackground),
        ),
        fit: BoxFit.fill,
      ),
      imageAspectRatio: HomePage._backgroundAspectRatio,
      color: HomePage._productsBackgroundColor,
      sliver: SliverPadding(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          kHorizontalPadding.r,
          kHorizontalPadding.r,
          16.r +
              LiquidGlassNavBar.contentBottomInset +
              MediaQuery.paddingOf(context).bottom,
        ),
        sliver: _productList(context, controller),
      ),
    );
  }

  Widget _productList(BuildContext context, HomeController controller) {
    if (controller.isLoading || controller.isLoadingProducts) {
      return SliverList.list(
        children: [
          for (final Widget child in _productsSkeleton())
            _movesWithSwipe(child),
        ],
      );
    }

    if (controller.products.isEmpty) {
      return SliverToBoxAdapter(
        child: _movesWithSwipe(_productsEmpty(controller)),
      );
    }

    return SliverList.builder(
      itemCount: controller.products.length + 1,
      itemBuilder: (context, index) => _movesWithSwipe(
        index == controller.products.length
            ? _loadMoreStatus(context, controller)
            : _productCard(context, controller.products[index]),
      ),
    );
  }

  Widget _productCard(BuildContext context, MainProductModel product) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.r),
      child: MainProductCard(
        product: product,
        onDraw: (_) => ToastHelper.showToast(context.tr(AppStrings.comingSoon)),
        onTap: () => AppNavigator.pushNamed(
          context,
          RouteName.subProductPage,
          arguments: product,
        ),
      ),
    );
  }

  List<Widget> _productsSkeleton() => [
    const MainProductCardSkeleton(),
    12.heightSpace,
    const MainProductCardSkeleton(),
  ];

  Widget _productsEmpty(HomeController controller) => MainProductEmpty(
    onClearFilter: controller.tagIds.isEmpty
        ? null
        : () => controller.onFilterTags([]),
  );

  /// [child], one of the product list's items, moved sideways by the swipe.
  Widget _movesWithSwipe(Widget child) {
    return AnimatedBuilder(
      animation: _swipe,
      child: child,
      builder: (context, child) =>
          Transform.translate(offset: Offset(_swipe.value, 0), child: child),
    );
  }

  /// Whether a drag from [position] (global) is on the products, below the
  /// header: the banners and the category tabs keep their own swipes.
  bool _startsOnProducts(Offset position) {
    final RenderObject? header = _headerKey.currentContext?.findRenderObject();
    if (header is! RenderBox || !header.attached) return false;

    return position.dy >=
        header.localToGlobal(Offset(0, header.size.height)).dy;
  }

  /// The category a swipe of [dx] heads for: the next one for a swipe left,
  /// the one before for a swipe right; null past either end.
  int? _swipeTarget(HomeController controller, double dx) {
    if (dx == 0) return null;
    final int index = controller.categoryIndex + (dx < 0 ? 1 : -1);
    return index >= 0 && index < controller.categories.length ? index : null;
  }

  void _onSwipeStart(HomeController controller) {
    _swiping = !controller.isLoading && controller.categories.length > 1;
    if (!_swiping) return;

    _swipe.stop();
    _tabLine.stop();
    _dragDx = _swipe.value;
    _productsTop = _measureProductsTop();
    // the cards on either side, so they're there to slide in
    controller.prefetchCategory(controller.categoryIndex - 1);
    controller.prefetchCategory(controller.categoryIndex + 1);
  }

  void _onSwipeUpdate(HomeController controller, double delta) {
    if (!_swiping) return;

    final double width = MediaQuery.sizeOf(context).width;
    _dragDx = (_dragDx + delta).clamp(-width, width);
    // past the first or last category it only gives a little
    _swipe.value = _swipeTarget(controller, _dragDx) == null
        ? _dragDx * 0.2
        : _dragDx;
  }

  /// Past a third of the width, or flung that way, it lands on the next
  /// category; otherwise the cards spring back.
  Future<void> _onSwipeEnd(HomeController controller, double velocity) async {
    if (!_swiping) return;
    _swiping = false;

    final double width = MediaQuery.sizeOf(context).width;
    final double dx = _swipe.value;
    final int? target = _swipeTarget(controller, dx);
    final bool flung = velocity.abs() > 600 && velocity.sign == dx.sign;

    if (target == null || (dx.abs() < width / 3 && !flung)) {
      await _swipe.animateTo(
        0,
        duration: _swipeDuration,
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _swipe.animateTo(
      dx.sign * width,
      duration: _swipeDuration,
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;

    // the new category's list takes the place of its cards, which were
    // drawn from its top: scrolled past the header, back to where it ends
    if (_productsTop < 0 && _scroll.hasClients) {
      _scroll.jumpTo(_scroll.offset + _productsTop);
    }
    controller.onSelectCategory(target);
    _swipe.value = 0;
    _centerCategoryTabAt(target, controller);
  }

  /// Where the products start in the stack: the header's bottom.
  double _measureProductsTop() {
    final RenderObject? header = _headerKey.currentContext?.findRenderObject();
    final RenderObject? stack = _stackKey.currentContext?.findRenderObject();
    if (header is! RenderBox || stack is! RenderBox || !header.attached) {
      return 0;
    }

    return header
        .localToGlobal(Offset(0, header.size.height), ancestor: stack)
        .dy;
  }

  /// The category being swiped to: its cards, drawn from the list's top,
  /// sliding in beside the swiped ones.
  Widget _swipeNeighbor(BuildContext context, HomeController controller) {
    return AnimatedBuilder(
      animation: _swipe,
      builder: (context, _) {
        final double dx = _swipe.value;
        final int? target = _swipeTarget(controller, dx);
        if (target == null) return const SizedBox.shrink();

        final double width = MediaQuery.sizeOf(context).width;
        final List<MainProductModel>? products = controller.cachedProducts(
          target,
        );

        return Positioned(
          left: 0,
          right: 0,
          top: math.max(0, _productsTop),
          bottom: 0,
          child: IgnorePointer(
            child: ClipRect(
              child: Transform.translate(
                offset: Offset(dx - dx.sign * width, 0),
                child: ListView(
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    kHorizontalPadding.r,
                    kHorizontalPadding.r,
                    kHorizontalPadding.r,
                    0,
                  ),
                  children: products == null
                      ? _productsSkeleton()
                      : products.isEmpty
                      ? [_productsEmpty(controller)]
                      : [
                          for (final MainProductModel product in products)
                            _productCard(context, product),
                        ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _loadMoreStatus(BuildContext context, HomeController controller) {
    if (controller.isLoadingMoreProducts) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8).r,
        child: const Center(child: CircularProgressIndicatorWidget(size: 36)),
      );
    }

    if (controller.loadMoreFailed) {
      return InkWellWrapper(
        onTap: () => controller.onLoadMore(retry: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12).r,
          child: AppText(
            context.tr(AppStrings.loadFailTryAgain),
            color: AppColors.whiteColor,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _filterBar(BuildContext context, HomeController controller) {
    final Color primary = context.color.primary;

    return Row(
      children: [
        AppButtonWidget(
          text: controller.tagIds.isEmpty
              ? context.tr(AppStrings.filter)
              : '${context.tr(AppStrings.filter)} (${controller.tagIds.length})',
          isMinWidth: true,
          radius: 8,
          textSize: kFont12,
          fontWeight: HomePage._filterBarWeight,
          buttonColor: AppColors.whiteColor,
          borderColor: primary,
          textColor: primary,
          icon: Icon(Iconsax.setting_4_copy, size: 15.r, color: primary),
          iconSpace: 5,
          padding: HomePage._filterBarPadding,
          onTap: () => BottomSheetHelper.tagFilter(
            selected: controller.filterTags,
            onConfirm: controller.onFilterTags,
          ),
        ),
        const Spacer(),
        _sortDropdown(context, controller),
      ],
    );
  }

  Widget _activeFilters(BuildContext context, HomeController controller) {
    final double fade = 12.r;

    return Row(
      children: [
        Expanded(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: const [Colors.white, Colors.white, Colors.transparent],
              stops: [0, 1 - fade / bounds.width, 1],
            ).createShader(bounds),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(
                kHorizontalPadding.r,
                4.r,
                fade,
                4.r,
              ),
              child: Row(
                children: [
                  for (final tag in controller.filterTags)
                    Padding(
                      padding: EdgeInsets.only(right: 8.r),
                      child: ProductTagChip(
                        tag: tag,
                        selected: true,
                        fontSize: kFont10,
                        onRemove: () => controller.onRemoveFilterTag(tag),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        InkWellWrapper(
          onTap: () => controller.onFilterTags([]),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4.r, 6.r, kHorizontalPadding.r, 6.r),
            child: AppText(
              context.tr(AppStrings.clearFilter),
              fontSize: kFont12,
              fontWeight: FontWeight.w500,
              color: context.color.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _sortLabel(BuildContext context, ProductSort sort) =>
      context.tr(switch (sort) {
        ProductSort.recommended => AppStrings.sortRecommended,
        ProductSort.lowStock => AppStrings.sortLowStock,
        ProductSort.newest => AppStrings.sortNewest,
        ProductSort.priceLowToHigh => AppStrings.sortPriceLowToHigh,
        ProductSort.priceHighToLow => AppStrings.sortPriceHighToLow,
      });

  Size _sortButtonSize(BuildContext context) {
    final TextStyle style = DefaultTextStyle.of(context).style.merge(
      TextStyle(fontSize: kFont12.sp, fontWeight: HomePage._filterBarWeight),
    );
    double textWidth = 0;
    double textHeight = 0;

    for (final ProductSort sort in ProductSort.values) {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: _sortLabel(context, sort), style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      if (painter.width > textWidth) textWidth = painter.width;
      if (painter.height > textHeight) textHeight = painter.height;
      painter.dispose();
    }

    final EdgeInsets padding = HomePage._filterBarPadding;
    const double border = 1;

    return Size(
      // the label, the gap and the ▾
      padding.horizontal + textWidth + 4.r + 12.r + border * 2,
      padding.vertical + textHeight + border * 2,
    );
  }

  Widget _sortDropdown(BuildContext context, HomeController controller) {
    final Color primary = context.color.primary;
    final BorderRadius radius = BorderRadius.circular(8).r;
    // the menu is exactly as wide as the button, each option as tall
    final Size size = _sortButtonSize(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<ProductSort>(
        valueListenable: controller.sort,
        onChanged: (value) {
          if (value != null) controller.sort.value = value;
        },
        items: [
          for (final ProductSort sort in ProductSort.values)
            DropdownItem(
              value: sort,
              height: size.height,
              child: ValueListenableBuilder<ProductSort>(
                valueListenable: controller.sort,
                builder: (context, current, _) => AppText(
                  _sortLabel(context, sort),
                  fontSize: kFont12,
                  fontWeight: HomePage._filterBarWeight,
                  color: current == sort ? primary : AppColors.loginTextColor,
                ),
              ),
            ),
        ],
        customButton: ValueListenableBuilder<ProductSort>(
          valueListenable: controller.sort,
          builder: (context, sort, _) => Container(
            width: size.width,
            padding: HomePage._filterBarPadding,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              border: Border.all(color: primary),
              borderRadius: radius,
            ),
            // the label where the menu's options start, the ▾ at the end
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    _sortLabel(context, sort),
                    fontSize: kFont12,
                    fontWeight: HomePage._filterBarWeight,
                    color: primary,
                    isOverflow: true,
                  ),
                ),
                4.widthSpace,
                Icon(Iconsax.arrow_down, size: 12.r, color: primary),
              ],
            ),
          ),
        ),
        buttonStyleData: const ButtonStyleData(
          overlayColor: WidgetStateColor.transparent,
        ),
        dropdownStyleData: DropdownStyleData(
          width: size.width,
          offset: Offset(0, -4.r),
          elevation: 0,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: radius,
            border: Border.all(color: AppColors.greyLight2Color),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.wOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          // inset like the button's label, so the text lines up
          padding: EdgeInsets.symmetric(
            horizontal: HomePage._filterBarPadding.left,
          ),
          selectedMenuItemBuilder: (context, child) =>
              ColoredBox(color: primary.wOpacity(0.06), child: child),
        ),
      ),
    );
  }

  int _cacheWidth(BuildContext context, double logicalWidth) =>
      (logicalWidth * MediaQuery.devicePixelRatioOf(context)).round();

  double _contentWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width - kHorizontalPadding.r * 2;

  Widget _bannerCarousel(BuildContext context, HomeController controller) {
    final List<BannerModel> banners = controller.banners;
    final bool multiple = banners.length > 1;
    final int cacheWidth = _cacheWidth(context, _contentWidth(context));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12).r,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            items: [
              for (final BannerModel banner in banners)
                InkWellWrapper(
                  onTap: banner.link == null
                      ? null
                      : () => launchLink(url: banner.link!),
                  child: AppImage(
                    name: banner.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: cacheWidth,
                  ),
                ),
            ],
            options: CarouselOptions(
              aspectRatio: HomePage._bannerAspectRatio,
              viewportFraction: 1,
              autoPlay: multiple,
              enableInfiniteScroll: multiple,
              onPageChanged: (index, _) => controller.bannerIndex.value = index,
            ),
          ),
          if (multiple)
            Positioned(
              bottom: 8.r,
              child: ValueListenableBuilder<int>(
                valueListenable: controller.bannerIndex,
                builder: (context, index, _) => AnimatedSmoothIndicator(
                  activeIndex: index,
                  count: banners.length,
                  effect: WormEffect(
                    dotWidth: 6.r,
                    dotHeight: 6.r,
                    spacing: 6.r,
                    activeDotColor: AppColors.whiteColor,
                    dotColor: AppColors.whiteColor.wOpacity(0.45),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pageBanners(BuildContext context, HomeController controller) {
    final items = controller.pageBanners.take(2).toList();
    final double gap = 10.r;
    final int cacheWidth = _cacheWidth(
      context,
      (_contentWidth(context) - gap) / 2,
    );

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: InkWellWrapper(
              onTap: () =>
                  ToastHelper.showToast(context.tr(AppStrings.comingSoon)),
              child: AspectRatio(
                aspectRatio: HomePage._pageBannerAspectRatio,
                child: AppImage(
                  name: items[i].image,
                  radius: 12,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: cacheWidth,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _categoryTabs(BuildContext context, HomeController controller) {
    // every tab is as wide, so the line's spot comes from its position
    final double tabWidth =
        HomePage._categoryLogoWidth + HomePage._categoryTabPadding.horizontal;
    final double lineWidth = HomePage._categoryLogoWidth * 0.8;

    return Container(
      decoration: _cardDecoration,
      child: SingleChildScrollView(
        controller: controller.categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6).r,
        child: Stack(
          children: [
            Row(
              children: [
                for (int i = 0; i < controller.categories.length; i++)
                  _categoryTab(context, controller, i),
              ],
            ),

            // the selected tab's line, one for all of them, so it can slide
            AnimatedBuilder(
              animation: Listenable.merge([_swipe, _tabLine]),
              builder: (context, _) {
                final ({double position, double progress}) line = _tabLineState(
                  controller,
                );
                // narrow mid-way, full on a tab
                final double travel = math.sin(math.pi * line.progress);
                final double width = lineWidth * (1 - 0.6 * travel);

                return Positioned(
                  left: line.position * tabWidth + (tabWidth - width) / 2,
                  bottom: 0,
                  child: Container(
                    width: width,
                    height: 3.r,
                    decoration: BoxDecoration(
                      color: context.color.primary,
                      borderRadius: BorderRadius.circular(2).r,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Where the tabs' line sits, in tabs from the first, and how far along
  /// its trip it is (0 leaving a tab, 1 there): under the selected tab; part
  /// of the way to the next while a swipe heads there, as far as the cards
  /// have moved; or sliding over to a tapped tab.
  ({double position, double progress}) _tabLineState(
    HomeController controller,
  ) {
    final double dx = _swipe.value;
    final int? target = _swipeTarget(controller, dx);
    if (target != null) {
      final double progress = (dx.abs() / MediaQuery.sizeOf(context).width)
          .clamp(0.0, 1.0);
      return (
        position:
            controller.categoryIndex +
            (target - controller.categoryIndex) * progress,
        progress: progress,
      );
    }

    if (_tabLine.isAnimating && _tabLineTo != _tabLineFrom) {
      return (
        position: _tabLine.value,
        progress:
            ((_tabLine.value - _tabLineFrom) / (_tabLineTo - _tabLineFrom))
                .clamp(0.0, 1.0),
      );
    }

    return (position: controller.categoryIndex.toDouble(), progress: 0);
  }

  Widget _categoryTab(
    BuildContext context,
    HomeController controller,
    int index,
  ) {
    final CategoryModel category = controller.categories[index];
    final double logoWidth = HomePage._categoryLogoWidth;

    return Builder(
      key: _tabKeys.putIfAbsent(index, GlobalKey.new),
      builder: (tabContext) => InkWellWrapper(
        onTap: () {
          if (index != controller.categoryIndex) {
            _tabLineFrom = controller.categoryIndex.toDouble();
            _tabLineTo = index.toDouble();
            _tabLine
              ..value = _tabLineFrom
              ..animateTo(
                _tabLineTo,
                duration: _swipeDuration,
                curve: Curves.easeOutCubic,
              );
          }
          controller.onSelectCategory(index);
          _centerCategoryTab(tabContext, controller.categoryScrollController);
        },
        child: Padding(
          padding: HomePage._categoryTabPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppImage(
                name: category.image,
                width: logoWidth,
                height: HomePage._categoryLogoHeight,
                fit: BoxFit.contain,
                cacheWidth: _cacheWidth(context, logoWidth),
              ),
              10.heightSpace,
              // room for the line, drawn over all the tabs
              SizedBox(height: 3.r),
            ],
          ),
        ),
      ),
    );
  }

  void _centerCategoryTabAt(int index, HomeController controller) {
    final BuildContext? tabContext = _tabKeys[index]?.currentContext;
    if (tabContext == null) return;
    _centerCategoryTab(tabContext, controller.categoryScrollController);
  }

  void _centerCategoryTab(BuildContext tabContext, ScrollController scroll) {
    final RenderObject? tab = tabContext.findRenderObject();
    if (tab == null || !scroll.hasClients) return;

    final ScrollPosition position = scroll.position;
    final double target = RenderAbstractViewport.of(
      tab,
    ).getOffsetToReveal(tab, 0.5).offset;

    scroll.animateTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: AppColors.whiteColor,
    borderRadius: BorderRadius.circular(12).r,
    border: Border.all(color: AppColors.greyLight2Color),
    boxShadow: [
      BoxShadow(
        color: AppColors.blackColor.wOpacity(0.12),
        blurRadius: 20,
        spreadRadius: -2,
        offset: const Offset(0, 8),
      ),
    ],
  );

  Widget _skeleton() {
    final BorderRadius radius = BorderRadius.circular(12).r;

    return AppSkeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: HomePage._bannerAspectRatio,
            child: Bone(borderRadius: radius),
          ),
          10.heightSpace,
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: HomePage._pageBannerAspectRatio,
                  child: Bone(borderRadius: radius),
                ),
              ),
              10.widthSpace,
              Expanded(
                child: AspectRatio(
                  aspectRatio: HomePage._pageBannerAspectRatio,
                  child: Bone(borderRadius: radius),
                ),
              ),
            ],
          ),
          12.heightSpace,
          Bone(
            height: HomePage._categoryLogoHeight + 27.r,
            borderRadius: radius,
          ),
        ],
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    final bool isLoggedIn = context.watch<AppController>().user != null;

    return AppBarWidget(
      centerTitle: false,
      backgroundColor: AppColors.whiteColor,
      title: AppLogo(height: 28.r),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8).r,
          child: Center(
            child: isLoggedIn
                ? const PointsPill()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _authButton(
                        context,
                        text: context.tr(AppStrings.login),
                        outlined: true,
                        onTap: () => AppNavigator.pushNamed(
                          context,
                          RouteName.loginPage,
                        ),
                      ),
                      8.widthSpace,
                      _authButton(
                        context,
                        text: context.tr(AppStrings.register),
                        onTap: () => AppNavigator.pushNamed(
                          context,
                          RouteName.registerPage,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _authButton(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    final Color primary = context.color.primary;

    return AppButtonWidget(
      text: text,
      isMinWidth: true,
      radius: 10,
      textSize: kFont13,
      buttonColor: outlined ? AppColors.whiteColor : primary,
      borderColor: primary,
      textColor: outlined ? primary : AppColors.whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6).r,
      onTap: onTap,
    );
  }
}

class _FixedBackgroundSliver extends SingleChildRenderObjectWidget {
  final DecorationImage image;
  final double imageAspectRatio;
  final Color color;

  const _FixedBackgroundSliver({
    required this.image,
    required this.imageAspectRatio,
    required this.color,
    required Widget sliver,
  }) : super(child: sliver);

  @override
  _RenderFixedBackgroundSliver createRenderObject(BuildContext context) =>
      _RenderFixedBackgroundSliver(
        image: image,
        imageAspectRatio: imageAspectRatio,
        color: color,
        configuration: createLocalImageConfiguration(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFixedBackgroundSliver renderObject,
  ) {
    renderObject
      ..image = image
      ..imageAspectRatio = imageAspectRatio
      ..color = color
      ..configuration = createLocalImageConfiguration(context);
  }
}

class _RenderFixedBackgroundSliver extends RenderProxySliver {
  _RenderFixedBackgroundSliver({
    required DecorationImage image,
    required double imageAspectRatio,
    required Color color,
    required ImageConfiguration configuration,
  }) : _image = image,
       _imageAspectRatio = imageAspectRatio,
       _color = color,
       _configuration = configuration;

  DecorationImage _image;
  set image(DecorationImage value) {
    if (value == _image) return;
    _image = value;
    _imagePainter?.dispose();
    _imagePainter = null;
    markNeedsPaint();
  }

  double _imageAspectRatio;
  set imageAspectRatio(double value) {
    if (value == _imageAspectRatio) return;
    _imageAspectRatio = value;
    markNeedsPaint();
  }

  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  DecorationImagePainter? _imagePainter;

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderSliver? child = this.child;
    if (child == null || !child.geometry!.visible) return;

    final double width = constraints.crossAxisExtent;
    final Rect visible = offset & Size(width, geometry!.paintExtent);
    final Rect imageRect = offset & Size(width, width * _imageAspectRatio);
    final Rect fadeRect = Rect.fromLTRB(
      imageRect.left,
      imageRect.bottom - imageRect.height / 5,
      imageRect.right,
      imageRect.bottom,
    );

    final Canvas canvas = context.canvas
      ..save()
      ..clipRect(visible)
      ..drawRect(visible, Paint()..color = _color);
    (_imagePainter ??= _image.createPainter(markNeedsPaint)).paint(
      canvas,
      imageRect,
      null,
      _configuration.copyWith(size: imageRect.size),
    );
    canvas
      ..drawRect(
        fadeRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_color.wOpacity(0), _color],
          ).createShader(fadeRect),
      )
      ..restore();

    super.paint(context, offset);
  }

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }
}

/// A horizontal drag that only starts where [allows] says.
class _ProductsSwipeRecognizer extends HorizontalDragGestureRecognizer {
  final bool Function(Offset position) allows;

  _ProductsSwipeRecognizer({required this.allows});

  @override
  bool isPointerAllowed(PointerEvent event) =>
      allows(event.position) && super.isPointerAllowed(event);
}
