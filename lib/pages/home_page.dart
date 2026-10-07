// Flutter imports:
import 'package:flutter/rendering.dart' show RenderAbstractViewport;

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Project imports:
import '../controllers/home_controller.dart';
import '../imports.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _bannerAspectRatio = 15 / 8;
  static const double _pageBannerAspectRatio = 2.2;

  static const double _categoryLogoAspectRatio = 2.7;
  static double get _categoryLogoHeight => 30.r;

  @override
  Widget build(BuildContext context) {
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

    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: ListView(
        // no side padding here, so the background can run edge to edge;
        // the other sections pad themselves
        padding: EdgeInsets.only(
          top: 10.r,
          bottom:
              LiquidGlassNavBar.contentBottomInset +
              MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          // from the API: a skeleton while loading
          Padding(
            padding: sidePadding,
            child: controller.isLoading
                ? _skeleton()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (controller.banners.isNotEmpty) ...[
                        _bannerCarousel(context, controller),
                        10.heightSpace,
                      ],
                      if (controller.pageBanners.isNotEmpty) ...[
                        _pageBanners(context, controller),
                        12.heightSpace,
                      ],
                      if (controller.categories.isNotEmpty)
                        _categoryTabs(context, controller),
                    ],
                  ),
          ),
          12.heightSpace,

          Padding(padding: sidePadding, child: _filterBar(context, controller)),
          12.heightSpace,

          _background(context),
        ],
      ),
    );
  }

  /// 篩選 on the left, the sort dropdown on the right.
  Widget _filterBar(BuildContext context, HomeController controller) {
    final Color primary = context.color.primary;

    return Row(
      children: [
        SizedBox(
          height: _filterBarHeight,
          child: AppButtonWidget(
            text: context.tr(AppStrings.filter),
            isMinWidth: true,
            radius: 8,
            textSize: kFont12,
            buttonColor: AppColors.whiteColor,
            borderColor: primary,
            textColor: primary,
            icon: Icon(Iconsax.setting_4_copy, size: 15.r, color: primary),
            iconSpace: 5,
            padding: const EdgeInsets.symmetric(horizontal: 12).r,
            // TODO(getithk): open the filter options
            onTap: () =>
                ToastHelper.showToast(context.tr(AppStrings.comingSoon)),
          ),
        ),
        const Spacer(),
        _sortDropdown(context, controller),
      ],
    );
  }

  static double get _filterBarHeight => 36.r;

  String _sortLabel(BuildContext context, ProductSort sort) =>
      context.tr(switch (sort) {
        ProductSort.recommended => AppStrings.sortRecommended,
        ProductSort.newest => AppStrings.sortNewest,
        ProductSort.priceLowToHigh => AppStrings.sortPriceLowToHigh,
        ProductSort.priceHighToLow => AppStrings.sortPriceHighToLow,
      });

  /// Red-outlined sort picker: the choice with a ▼ right after it, both in
  /// red; the open menu highlights the current choice.
  Widget _sortDropdown(BuildContext context, HomeController controller) {
    final Color primary = context.color.primary;
    final BorderRadius radius = BorderRadius.circular(8).r;

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
              height: 40.r,
              child: AppText(
                _sortLabel(context, sort),
                fontSize: kFont12,
                color: AppColors.loginTextColor,
              ),
            ),
        ],
        // Own button, sized to its content, so the ▼ sits right after the
        // text (the default one pins the icon to a fixed width's far end).
        customButton: ValueListenableBuilder<ProductSort>(
          valueListenable: controller.sort,
          builder: (context, sort, _) => Container(
            height: _filterBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12).r,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              border: Border.all(color: primary),
              borderRadius: radius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  _sortLabel(context, sort),
                  fontSize: kFont12,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
                2.widthSpace,
                Icon(Iconsax.arrow_down, size: 12.r, color: primary),
              ],
            ),
          ),
        ),
        buttonStyleData: const ButtonStyleData(
          overlayColor: WidgetStateColor.transparent,
        ),
        dropdownStyleData: DropdownStyleData(
          // wider than the button for the longer options; it's at the
          // screen's right edge, so the menu grows leftwards
          width: 150.r,
          direction: DropdownDirection.left,
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
          padding: const EdgeInsets.symmetric(horizontal: 14).r,
          selectedMenuItemBuilder: (context, child) =>
              ColoredBox(color: primary.wOpacity(0.06), child: child),
        ),
      ),
    );
  }

  /// bg.jpg, full width with no padding, at its own proportions.
  Widget _background(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return Image.asset(
      AppAssets.homeBackground,
      width: width,
      fit: BoxFit.contain,
      // decode no larger than the screen needs (never above its own 1184px)
      cacheWidth: _cacheWidth(context, width),
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
              aspectRatio: _bannerAspectRatio,
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
                aspectRatio: _pageBannerAspectRatio,
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
    final double logoWidth = _categoryLogoHeight * _categoryLogoAspectRatio;

    return Builder(
      builder: (tabContext) => InkWellWrapper(
        onTap: () {
          controller.onSelectCategory(index);
          _centerCategoryTab(tabContext, controller.categoryScrollController);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 0).r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppImage(
                name: category.image,
                width: logoWidth,
                height: _categoryLogoHeight,
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
        color: AppColors.blackColor.wOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
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
            aspectRatio: _bannerAspectRatio,
            child: Bone(borderRadius: radius),
          ),
          10.heightSpace,
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: _pageBannerAspectRatio,
                  child: Bone(borderRadius: radius),
                ),
              ),
              10.widthSpace,
              Expanded(
                child: AspectRatio(
                  aspectRatio: _pageBannerAspectRatio,
                  child: Bone(borderRadius: radius),
                ),
              ),
            ],
          ),
          12.heightSpace,
          Bone(height: _categoryLogoHeight + 27.r, borderRadius: radius),
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
          padding: const EdgeInsets.only(right: 12).r,
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

  /// Small pill button: filled, or white with a primary outline.
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
