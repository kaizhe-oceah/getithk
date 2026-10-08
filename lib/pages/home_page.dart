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
import '../controllers/home_controller.dart';
import '../imports.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const double _bannerAspectRatio = 15 / 8;
  static const double _pageBannerAspectRatio = 2.2;

  static const double _categoryLogoAspectRatio = 2.7;
  static double get _categoryLogoHeight => 30.r;

  @override
  State<HomePage> createState() => _HomePageState();

  static EdgeInsets get _filterBarPadding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r;
  static const FontWeight _filterBarWeight = FontWeight.w500;

  static const double _backgroundAspectRatio = 2560 / 1184;

  static const Color _productsBackgroundColor = Color(0xFF2B1766);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

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

        NotificationListener<ScrollNotification>(
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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ColoredBox(
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
          const MainProductCardSkeleton(),
          12.heightSpace,
          const MainProductCardSkeleton(),
        ],
      );
    }

    if (controller.products.isEmpty) {
      return SliverToBoxAdapter(
        child: MainProductEmpty(
          onClearFilter: controller.tagIds.isEmpty
              ? null
              : () => controller.onFilterTags([]),
        ),
      );
    }

    return SliverList.builder(
      itemCount: controller.products.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.products.length) {
          return _loadMoreStatus(context, controller);
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12.r),
          child: MainProductCard(
            product: controller.products[index],
            onDraw: () =>
                ToastHelper.showToast(context.tr(AppStrings.comingSoon)),
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
    return Container(
      decoration: _cardDecoration,
      child: SingleChildScrollView(
        controller: controller.categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6).r,
        child: Row(
          children: [
            for (int i = 0; i < controller.categories.length; i++)
              _categoryTab(context, controller, i),
          ],
        ),
      ),
    );
  }

  Widget _categoryTab(
    BuildContext context,
    HomeController controller,
    int index,
  ) {
    final CategoryModel category = controller.categories[index];
    final bool selected = index == controller.categoryIndex;
    final double logoWidth =
        HomePage._categoryLogoHeight * HomePage._categoryLogoAspectRatio;

    return Builder(
      builder: (tabContext) => InkWellWrapper(
        onTap: () {
          controller.onSelectCategory(index);
          _centerCategoryTab(tabContext, controller.categoryScrollController);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 0).r,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: 3.r,
                width: selected ? logoWidth * 0.8 : 0,
                decoration: BoxDecoration(
                  color: context.color.primary,
                  borderRadius: BorderRadius.circular(2).r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                ? _pointsPill(context)
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

  Widget _pointsPill(BuildContext context) {
    final Color primary = context.color.primary;
    final double points = context.watch<AppController>().points;
    final double coinSize = 22.r;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppImage(
            name: AppAssets.coins,
            width: coinSize,
            height: coinSize,
            fit: BoxFit.contain,
            cacheWidth: (coinSize * MediaQuery.devicePixelRatioOf(context))
                .round(),
          ),
          4.widthSpace,
          AppText(
            '${NumberFormat('#,##0.00').format(points)} pts',
            fontSize: kFont13,
            fontWeight: FontWeight.w700,
            color: AppColors.loginTextColor,
          ),
          6.widthSpace,

          // top up
          InkWellWrapper(
            onTap: () =>
                ToastHelper.showToast(context.tr(AppStrings.comingSoon)),
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
              child: Icon(
                Iconsax.add_copy,
                size: 14.r,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
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
