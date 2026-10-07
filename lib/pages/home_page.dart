// Package imports:
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

// Project imports:
import '../controllers/home_controller.dart';
import '../imports.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [_appBar(context)],
        child: Consumer<HomeController>(
          builder: (context, controller, _) => _banners(context, controller),
        ),
      ),
    );
  }

  // Banner list; pull down to refresh
  Widget _banners(BuildContext context, HomeController controller) {
    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          10.r,
          kHorizontalPadding.r,
          LiquidGlassNavBar.contentBottomInset +
              MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: controller.banners.length,
        separatorBuilder: (_, _) => 12.heightSpace,
        itemBuilder: (context, index) => AppImage(
          name: controller.banners[index],
          radius: 12,
          fit: BoxFit.cover,
        ),
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
