// Project imports:
import '../controllers/link_account_controller.dart';
import '../imports.dart';
import '../models/social_account_model.dart';

class LinkAccountPage extends StatelessWidget {
  const LinkAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LinkAccountController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.linkAccount),
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<LinkAccountController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, LinkAccountController controller) {
    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          16.r,
          kHorizontalPadding.r,
          20.r + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          AppText(
            context.tr(AppStrings.linkToUrAccount),
            fontSize: kFont16,
            fontWeight: FontWeight.w700,
          ),
          4.heightSpace,
          AppText(
            context.tr(AppStrings.linkToUrAccountDesc),
            fontSize: kFont12,
            color: AppColors.loginHintColor,
          ),
          16.heightSpace,
          AppSkeletonizer(
            enabled: controller.isLoading,
            child: _accounts(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _accounts(BuildContext context, LinkAccountController controller) {
    final List<SocialAccountModel> accounts = controller.displayAccounts;
    if (accounts.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14).r,
        border: Border.all(color: AppColors.greyLight2Color),
      ),
      child: Column(
        children: [
          for (int i = 0; i < accounts.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 66.r,
                color: AppColors.greyLight2Color,
              ),
            _accountRow(context, controller, accounts[i]),
          ],
        ],
      ),
    );
  }

  Widget _accountRow(
    BuildContext context,
    LinkAccountController controller,
    SocialAccountModel account,
  ) {
    final String? subtitle = account.linked
        ? account.email
        : context.tr(AppStrings.notLinked);

    return Padding(
      padding: const EdgeInsets.all(14).r,
      child: Row(
        children: [
          _providerIcon(account.provider),
          12.widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  account.provider.label,
                  fontSize: kFont14,
                  fontWeight: FontWeight.w600,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  2.heightSpace,
                  AppText(
                    subtitle,
                    fontSize: kFont12,
                    color: AppColors.loginHintColor,
                    isOverflow: true,
                  ),
                ],
              ],
            ),
          ),
          12.widthSpace,
          if (account.linked)
            _linkedBadge(context)
          else
            AppButtonWidget(
              text: context.tr(AppStrings.link),
              radius: 10,
              textSize: kFont12,
              textColor: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ).r,
              onTap: () => controller.onLink(account.provider),
            ),
        ],
      ),
    );
  }

  Widget _providerIcon(SocialProvider provider) {
    final Color? tint = switch (provider) {
      SocialProvider.google => null,
      SocialProvider.facebook => AppColors.facebookColor,
      SocialProvider.apple => AppColors.blackColor,
    };
    final String icon = switch (provider) {
      SocialProvider.google => AppAssets.icGoogle,
      SocialProvider.facebook => AppAssets.icFacebook,
      SocialProvider.apple => AppAssets.icApple,
    };

    return Container(
      width: 40.r,
      height: 40.r,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.greyBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: AppImage(name: icon, width: 20.r, height: 20.r, color: tint),
    );
  }

  Widget _linkedBadge(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Iconsax.tick_circle,
          size: 14.r,
          color: AppColors.toastSuccessColor,
        ),
        4.widthSpace,
        AppText(
          context.tr(AppStrings.linked),
          fontSize: kFont12,
          fontWeight: FontWeight.w500,
          color: AppColors.toastSuccessColor,
        ),
      ],
    );
  }
}
