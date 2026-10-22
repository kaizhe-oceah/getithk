// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../../imports.dart';
import '../gift_shake.dart';

BoxDecoration get inviteCardDecoration => BoxDecoration(
  color: AppColors.whiteColor,
  borderRadius: BorderRadius.circular(14).r,
  border: Border.all(color: AppColors.greyLight2Color),
  boxShadow: [
    BoxShadow(
      color: AppColors.blackColor.wOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

class InviteHeader extends StatelessWidget {
  final String title;
  final String chip;
  final String description;
  final List<(IconData, String)> steps;

  const InviteHeader({
    required this.title,
    required this.chip,
    required this.description,
    required this.steps,
    super.key,
  });

  static const Color _topColor = Color(0xFFFFE3E7);
  static const Color _bottomColor = Color(0xFFFFF6F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 10, 12).r,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_topColor, _bottomColor],
        ),
        borderRadius: BorderRadius.circular(16).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      context.tr(title),
                      fontSize: kFont18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.loginTextColor,
                    ),
                    8.heightSpace,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ).r,
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: AppText(
                        context.tr(chip),
                        fontSize: kFont11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    8.heightSpace,
                    AppText(
                      context.tr(description),
                      fontSize: kFont11,
                      color: AppColors.textLightColor,
                      height: 1.5,
                    ),
                  ],
                ),
              ),
              GiftShake(
                child: Image.asset(
                  AppAssets.prize,
                  width: 98.r,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          12.heightSpace,
          _steps(context),
        ],
      ),
    );
  }

  Widget _steps(BuildContext context) {
    final Color primary = context.color.primary;
    final double circleSize = 36.r;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              SizedBox(
                height: circleSize,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18.r,
                  color: primary,
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: primary.wOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(steps[i].$1, size: 18.r, color: primary),
                  ),
                  6.heightSpace,
                  AppText(
                    context.tr(steps[i].$2),
                    fontSize: kFont11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackColor,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InviteStats extends StatelessWidget {
  final List<(String, String)> stats;
  final bool loading;

  const InviteStats({required this.stats, required this.loading, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16).r,
      decoration: BoxDecoration(
        color: context.color.primary,
        borderRadius: BorderRadius.circular(14).r,
      ),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 40.r,
                color: AppColors.whiteColor.wOpacity(0.8),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6).r,
                child: Column(
                  children: [
                    AppText(
                      stats[i].$1,
                      fontSize: kFont12,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w500,
                    ),
                    3.heightSpace,
                    AppSkeletonizer(
                      enabled: loading,
                      // a long total shrinks to fit, on one line
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AppText(
                          stats[i].$2,
                          fontSize: kFont18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 專屬邀請碼: the player's referral code, to copy, and 立即邀請好友 to
/// share it.
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;
    final String code =
        context.watch<AppController>().user?.referralCode ?? '';

    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: inviteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            context.tr(AppStrings.myInviteCode),
            fontSize: kFont14,
            fontWeight: FontWeight.w500,
            color: AppColors.loginTextColor,
          ),
          10.heightSpace,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 12, right: 8).r,
                    decoration: BoxDecoration(
                      color: primary.wOpacity(0.06),
                      borderRadius: BorderRadius.circular(10).r,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            code.isEmpty ? '-' : code,
                            fontSize: kFont16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.loginTextColor,
                            isOverflow: true,
                          ),
                        ),
                        if (code.isNotEmpty)
                          InkWellWrapper(
                            onTap: () => copyToClipboard(contentToCopy: code),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ).r,
                              decoration: BoxDecoration(
                                border: Border.all(color: primary),
                                borderRadius: BorderRadius.circular(6).r,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.copy_copy,
                                    size: 12.r,
                                    color: primary,
                                  ),
                                  3.widthSpace,
                                  AppText(
                                    context.tr(AppStrings.copy),
                                    fontSize: kFont11,
                                    fontWeight: FontWeight.w500,
                                    color: primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                10.widthSpace,
                AppButtonWidget(
                  text: context.tr(AppStrings.inviteNow),
                  isMinWidth: true,
                  textSize: kFont12,
                  buttonColor: AppColors.blackColor,
                  textColor: AppColors.whiteColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ).r,
                  onTap: code.isEmpty ? null : () => _share(context, code),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context, String code) async {
    await SharePlus.instance.share(
      ShareParams(text: context.tr(AppStrings.inviteShareText, args: [code])),
    );
  }
}
