// Package imports:
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

// Project imports:
import '../controllers/home_controller.dart';
import '../imports.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color backgroundColor = AppColors.whiteColor;

  /// banner.png's own width / height.
  static const double _bannerAspectRatio = 6250 / 3334;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: AppScaffold.basic(
        backgroundColor: backgroundColor,
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
    // decode at screen width instead of the asset's full 6250px
    final int cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();

    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          kHorizontalPadding.r,
          kHorizontalPadding.r,
          // the last banner can scroll clear of the floating nav bar
          LiquidGlassNavBar.contentBottomInset +
              MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: controller.banners.length,
        separatorBuilder: (_, _) => 12.heightSpace,
        itemBuilder: (context, index) => AspectRatio(
          aspectRatio: _bannerAspectRatio,
          child: AppImage(
            name: controller.banners[index],
            radius: 12,
            cacheWidth: cacheWidth,
          ),
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
        if (!isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 16).r,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _authButton(
                    context,
                    text: context.tr(AppStrings.login),
                    outlined: true,
                    onTap: () =>
                        AppNavigator.pushNamed(context, RouteName.loginPage),
                  ),
                  8.widthSpace,
                  _authButton(
                    context,
                    text: context.tr(AppStrings.register),
                    onTap: () =>
                        AppNavigator.pushNamed(context, RouteName.registerPage),
                  ),
                ],
              ),
            ),
          ),
      ],
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
