// Package imports:
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

// Project imports:
import '../imports.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final RefreshController _refreshController = RefreshController();

  static const double _points = 0;
  static const int _cardCount = 0;

  static const List<(IconData, String)> _menuItems = [
    (Iconsax.profile_2user, AppStrings.inviteFriends),
    (Iconsax.ticket_discount, AppStrings.vouchers),
    (Iconsax.bag_2, AppStrings.backpack),
    (Iconsax.receipt_2, AppStrings.myOrders),
    (Iconsax.location, AppStrings.shippingAddress),
    (Iconsax.shop, AppStrings.salesRecord),
    (Iconsax.gift, AppStrings.drawRecord),
    (Iconsax.message_question, AppStrings.helpCenter),
    (Iconsax.document_text, AppStrings.termsOfService),
    (Iconsax.shield_tick, AppStrings.privacyPolicy),
    (Iconsax.headphone, AppStrings.onlineCustomerService),
    (Iconsax.setting_2, AppStrings.settings),
  ];

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<AppController>().getUser();
    _refreshController.refreshCompleted();
  }

  void _comingSoon() =>
      ToastHelper.showToast(context.tr(AppStrings.comingSoon));

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final UserModel? user = app.user;

    // logged out: the profile tab is the login page
    if (user == null) return const LoginPage(isTab: true);

    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.dark,
      headerWidgets: [
        AppBarWidget(
          text: context.tr(AppStrings.profile),
          textSize: kFont16,
          backgroundColor: AppColors.whiteColor,
          isDivider: true,
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
            LiquidGlassNavBar.contentBottomInset +
                MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            _header(user, app.level),
            12.heightSpace,
            _balanceCard(),
            20.heightSpace,

            AppText(
              context.tr(AppStrings.commonFunctions),
              fontSize: kFont15,
              fontWeight: FontWeight.w700,
              color: AppColors.loginTextColor,
            ),
            10.heightSpace,
            for (final item in _menuItems) ...[_menuTile(item), 8.heightSpace],

            _menuTile(
              (Iconsax.logout, AppStrings.logout),
              color: AppColors.redColor,
              onTap: BottomSheetHelper.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(UserModel user, LevelModel? level) {
    final Color white = AppColors.whiteColor;

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

          // my cards
          InkWellWrapper(
            onTap: _comingSoon,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12).r,
              decoration: BoxDecoration(
                color: white.wOpacity(0.2),
                borderRadius: BorderRadius.circular(12).r,
              ),
              child: Column(
                children: [
                  AppText(
                    '$_cardCount',
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
              onTap: _comingSoon,
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

  /// "Lv.1" badge, exp bar and "0 / 5,000 Exp".
  Widget _levelRow(LevelModel level) {
    const Color white = AppColors.whiteColor;
    final NumberFormat exp = NumberFormat('#,##0');

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1).r,
          decoration: BoxDecoration(
            color: AppColors.levelBadgeColor,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4).r,
            child: LinearProgressIndicator(
              value: level.progress,
              minHeight: 6.r,
              backgroundColor: white.wOpacity(0.3),
              color: AppColors.levelBadgeColor,
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

  // Points balance with the top-up button
  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12).r,
      decoration: _cardDecoration,
      child: Row(
        children: [
          Icon(Iconsax.coin, size: 32.r, color: AppColors.coinColor),
          10.widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${NumberFormat('#,##0.00').format(_points)} pts',
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
            onTap: _comingSoon,
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    (IconData, String) item, {
    VoidCallback? onTap,
    Color? color,
  }) {
    final (IconData icon, String label) = item;

    return InkWellWrapper(
      onTap: onTap ?? _comingSoon,
      child: Container(
        height: 50.r,
        padding: const EdgeInsets.symmetric(horizontal: 14).r,
        decoration: _cardDecoration,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.r,
              color: color ?? AppColors.profileMenuIconColor,
            ),
            12.widthSpace,
            Expanded(
              child: AppText(
                context.tr(label),
                fontSize: kFont14,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.loginTextColor,
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

  /// White card with a hairline border and a soft shadow.
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
