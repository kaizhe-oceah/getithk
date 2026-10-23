// Project imports:
import '../components/default/bottom_nav_bar_widget.dart';
import '../components/points_pill.dart';
import '../imports.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';
import 'login_page.dart';
import 'tnc_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final RefreshController _refreshController = RefreshController();

  List<_MenuItem> _menuItems(UserModel user) => [
    _MenuItem(
      AppStrings.inviteFriends,
      image: AppAssets.menuInviteFriends,
      route: RouteName.inviteFriendsPage,
    ),
    // only for a player with a commission rate (an agent)
    _MenuItem(
      AppStrings.vouchers,
      image: AppAssets.menuVouchers,
      route: RouteName.vouhcerPage,
    ),
    if (parseDouble(user.topupCommissionRate) != 0)
      _MenuItem(
        AppStrings.agentCommission,
        image: AppAssets.menuAgentCommission,
        route: RouteName.agentCommissionPage,
      ),
    // _MenuItem(AppStrings.backpack, image: AppAssets.menuBackpack),
    _MenuItem(
      AppStrings.myOrders,
      image: AppAssets.menuMyOrders,
      route: RouteName.myOrdersPage,
    ),
    _MenuItem(
      AppStrings.shippingAddress,
      image: AppAssets.menuShippingAddress,
      route: RouteName.addressPage,
    ),
    _MenuItem(
      AppStrings.salesRecord,
      image: AppAssets.menuSalesRecord,
      route: RouteName.sellHistoryPage,
    ),
    _MenuItem(
      AppStrings.drawRecord,
      image: AppAssets.menuDrawRecord,
      route: RouteName.drawHistoryPage,
    ),
    _MenuItem(AppStrings.helpCenter, image: AppAssets.menuHelpCenter),
    _MenuItem(
      AppStrings.termsOfService,
      image: AppAssets.menuTerms,
      onTap: () => TncPage.open(context, TncType.terms),
    ),
    _MenuItem(
      AppStrings.privacyPolicy,
      image: AppAssets.menuPrivacy,
      onTap: () => TncPage.open(context, TncType.privacy),
    ),
    _MenuItem(
      AppStrings.onlineCustomerService,
      image: AppAssets.menuCustomerService,
    ),
    _MenuItem(
      AppStrings.settings,
      image: AppAssets.menuSettings,
      route: RouteName.settingsPage,
    ),
  ];

  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  void initState() {
    super.initState();
    context.read<AppController>().getStockSummary();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final AppController app = context.read<AppController>();
    await Future.wait([
      app.getUser(),
      app.getWalletBalance(),
      app.getStockSummary(),
    ]);
    _refreshController.refreshCompleted();
  }

  void _comingSoon() =>
      ToastHelper.showToast(context.tr(AppStrings.comingSoon));

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final UserModel? user = app.user;

    if (user == null) return const LoginPage(isTab: true);

    return AppScaffold.basic(
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
      child: SmartRefresherWrapper(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            kHorizontalPadding.r,
            kHorizontalPadding.r,
            kHorizontalPadding.r,
            BottomNavigationWidget.contentBottomInset(context),
          ),
          children: [
            _header(user, app.level, app.cardCount),
            kHorizontalPadding.heightSpace,

            AppText(
              context.tr(AppStrings.commonFunctions),
              fontSize: kFont15,
              fontWeight: FontWeight.w700,
              color: AppColors.loginTextColor,
            ),
            10.heightSpace,
            for (final (int i, _MenuItem item) in _menuItems(user).indexed) ...[
              if (i > 0) 8.heightSpace,
              _menuTile(item, onTap: _menuAction(item)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(UserModel user, LevelModel? level, int cardCount) {
    const Color white = AppColors.whiteColor;

    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: BoxDecoration(
        gradient: AppColors.profileHeaderGradientColor,
        borderRadius: BorderRadius.circular(16).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _avatar(user),
              12.widthSpace,
              Expanded(child: _userInfo(user, level)),
            ],
          ),
          14.heightSpace,

          InkWellWrapper(
            onTap: _comingSoon,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8).r,
              decoration: BoxDecoration(
                color: white.wOpacity(0.2),
                borderRadius: BorderRadius.circular(12).r,
              ),
              child: Column(
                children: [
                  AppText(
                    '$cardCount',
                    fontSize: kFont18,
                    fontWeight: FontWeight.w700,
                    color: white,
                  ),
                  2.heightSpace,
                  AppText(
                    context.tr(AppStrings.myCards),
                    fontSize: kFont11,
                    color: white.wOpacity(0.9),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(UserModel? user) {
    final double size = 56.r;
    final String? avatar = user?.avatarImage;
    final String? frame = user?.frameImage;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteColor.wOpacity(0.2),
              border: Border.all(color: AppColors.whiteColor, width: 2),
            ),
            child: ClipOval(
              child: avatar == null
                  ? Center(
                      child: Icon(
                        Iconsax.user,
                        size: size * 0.5,
                        color: AppColors.whiteColor,
                      ),
                    )
                  : AppImage(name: avatar, width: size, height: size),
            ),
          ),
          if (frame != null)
            Positioned.fill(
              child: AppImage(name: frame, fit: BoxFit.contain),
            ),
        ],
      ),
    );
  }

  Widget _userInfo(UserModel user, LevelModel? level) {
    final Color white = AppColors.whiteColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: AppText(
                user.name ?? '',
                fontSize: kFont15,
                fontWeight: FontWeight.w700,
                color: white,
                isOverflow: true,
              ),
            ),
            6.widthSpace,
            InkWellWrapper(
              onTap: () =>
                  AppNavigator.pushNamed(context, RouteName.edtiProfilePage),
              child: Icon(Iconsax.edit_2_copy, size: 14.r, color: white),
            ),
          ],
        ),
        6.heightSpace,

        if (level != null) ...[_levelRow(level), 6.heightSpace],

        // member ID; tap to copy
        InkWellWrapper(
          onTap: user.idNumber == null
              ? null
              : () => copyToClipboard(contentToCopy: user.idNumber!),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                context.tr(AppStrings.memberId, args: [user.idNumber ?? '-']),
                fontSize: kFont11,
                color: white.wOpacity(0.9),
              ),
              4.widthSpace,
              Icon(Iconsax.copy_copy, size: 12.r, color: white.wOpacity(0.9)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _levelRow(LevelModel level) {
    const Color white = AppColors.whiteColor;
    final NumberFormat exp = NumberFormat('#,##0');
    final BorderRadius barRadius = BorderRadius.circular(4).r;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1).r,
          decoration: BoxDecoration(
            gradient: AppColors.levelBadgeGradientColor,
            borderRadius: BorderRadius.circular(4).r,
          ),
          child: AppText(
            'Lv.${level.levelId ?? '-'}',
            fontSize: kFont10,
            fontWeight: FontWeight.w700,
            color: white,
          ),
        ),
        8.widthSpace,
        Expanded(
          child: Container(
            height: 6.r,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: white.wOpacity(0.25),
              borderRadius: barRadius,
            ),
            // the gradient runs the filled part's length
            child: FractionallySizedBox(
              widthFactor: level.progress,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.levelBarGradientColor,
                  borderRadius: barRadius,
                ),
              ),
            ),
          ),
        ),
        8.widthSpace,
        AppText(
          level.isMaxLevel
              ? 'MAX'
              : '${exp.format(level.currentExp ?? 0)} / '
                    '${exp.format(level.nextLevelRequiredExp ?? 0)} Exp',
          fontSize: kFont10,
          color: white.wOpacity(0.9),
        ),
      ],
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12).r,
      decoration: _cardDecoration,
      child: Row(
        children: [
          Image.asset(
            AppAssets.coins,
            width: 32.r,
            height: 32.r,
            cacheWidth: (32.r * MediaQuery.devicePixelRatioOf(context)).round(),
          ),
          10.widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${NumberFormat('#,##0.00').format(context.watch<AppController>().points)} pt',
                  fontSize: kFont16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.loginTextColor,
                ),
                AppText(
                  context.tr(AppStrings.balance),
                  fontSize: kFont11,
                  color: AppColors.textLightColor,
                ),
              ],
            ),
          ),
          AppButtonWidget(
            text: context.tr(AppStrings.topUp),
            isMinWidth: true,
            radius: 8,
            textSize: kFont13,
            textColor: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8).r,
            onTap: () => AppNavigator.pushNamed(context, RouteName.topupPage),
          ),
        ],
      ),
    );
  }

  /// [item]'s own tap, else opening its route; null ("coming soon") if it
  /// has neither yet.
  VoidCallback? _menuAction(_MenuItem item) {
    if (item.onTap != null) return item.onTap;

    final String? route = item.route;
    if (route == null) return null;

    return () => AppNavigator.pushNamed(context, route);
  }

  Widget _menuTile(_MenuItem item, {VoidCallback? onTap}) {
    return InkWellWrapper(
      onTap: onTap ?? _comingSoon,
      child: Container(
        height: 50.r,
        padding: const EdgeInsets.symmetric(horizontal: 14).r,
        decoration: _cardDecoration,
        child: Row(
          children: [
            _menuLeading(item),
            13.widthSpace,
            Expanded(
              child: AppText(
                context.tr(item.label),
                fontSize: kFont14,
                fontWeight: FontWeight.w500,
                color: AppColors.loginTextColor,
              ),
            ),
            Icon(
              Iconsax.arrow_right_3_copy,
              size: 16.r,
              color: AppColors.hintColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuLeading(_MenuItem item) {
    final double imageSize = 24.r;

    return ColorFiltered(
      colorFilter: _grayscale,
      child: Image.asset(
        item.image,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
        cacheWidth: (imageSize * MediaQuery.devicePixelRatioOf(context))
            .round(),
      ),
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
}

/// A row of 常用功能: its label (a translation key), its picture, and the
/// page it opens.
class _MenuItem {
  final String label;
  final String image;

  /// The page it opens (a [RouteName]); null: "coming soon".
  final String? route;

  /// What tapping it does, in place of opening [route].
  final VoidCallback? onTap;

  const _MenuItem(this.label, {required this.image, this.route, this.onTap});
}
