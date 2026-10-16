// Project imports:
import '../controllers/voucher_controller.dart';
import '../imports.dart';
import '../models/page_banner_model.dart';

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  static const double _bannerAspectRatio = 1120 / 496;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoucherController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.vouchers),
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<VoucherController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, VoucherController controller) {
    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          12.r,
          kHorizontalPadding.r,
          20.r + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (controller.isLoading || controller.banner != null) ...[
            _banner(context, controller),
            14.heightSpace,
          ],
          _redeemCard(context, controller),
        ],
      ),
    );
  }

  Widget _banner(BuildContext context, VoucherController controller) {
    final PageBannerModel? banner = controller.banner;

    return AspectRatio(
      aspectRatio: _bannerAspectRatio,
      child: banner == null
          ? AppSkeletonizer(
              enabled: true,
              child: Bone(borderRadius: BorderRadius.circular(12).r),
            )
          : AppImage(
              name: banner.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              radius: 10,
            ),
    );
  }

  Widget _redeemCard(BuildContext context, VoucherController controller) {
    final Color primary = context.color.primary;

    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14).r,
        border: Border.all(color: AppColors.greyLight2Color),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.wOpacity(0.06),
            blurRadius: 8.r,
            offset: Offset(0, 2.r),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextFormField(
            controller: controller.codeController,
            labelText: context.tr(AppStrings.enterVoucherCode),
            labelTextSize: kFont13,
            labelFontWeight: FontWeight.w600,
            labelColor: AppColors.loginTextColor,
            hintText: context.tr(AppStrings.voucherCodeHint),
            hintTextColor: AppColors.loginHintColor,
            textColor: AppColors.loginTextColor,
            radius: 12,
            borderColor: AppColors.greyLightColor,
            textInputAction: TextInputAction.done,
            onEditingComplete: controller.onRedeem,
            prefixIcon: SizedBox(
              height: 48.r,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12).r,
                child: Icon(
                  Iconsax.ticket_copy,
                  size: 18.r,
                  color: AppColors.loginHintColor,
                ),
              ),
            ),
          ),
          14.heightSpace,
          AppButtonWidget(
            text: context.tr(AppStrings.redeemNow),
            radius: 12,
            textSize: kFont12,
            fontWeight: FontWeight.w500,
            textColor: AppColors.whiteColor,
            disabledColor: primary.wOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 12).r,
            onTap: controller.canRedeem ? controller.onRedeem : null,
          ),
        ],
      ),
    );
  }
}
