// Project imports:
import '../imports.dart';
import '../models/user_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? user = context.watch<AppController>().user;

    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.dark,
      headerWidgets: [
        AppBarWidget(
          text: context.tr(AppStrings.settings),
          centerTitle: true,
          backgroundColor: AppColors.whiteColor,
          leading: const AppBarBackButton(),
        ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          kHorizontalPadding.r,
          kHorizontalPadding.r,
          20.r + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _row(context, label: AppStrings.email, value: _orDash(user?.email)),
          8.heightSpace,
          _row(context, label: AppStrings.phoneNumber, value: _phone(user)),
          8.heightSpace,
          _row(
            context,
            label: AppStrings.resetPassword,
            onTap: () => ToastHelper.showToast(
              context.tr(AppStrings.passwordResetUnavailable),
            ),
          ),
          8.heightSpace,
          InkWellWrapper(
            onTap: BottomSheetHelper.logout,
            child: Container(
              height: 50.r,
              alignment: Alignment.center,
              decoration: _cardDecoration,
              child: AppText(
                context.tr(AppStrings.logout),
                fontSize: kFont14,
                fontWeight: FontWeight.w600,
                color: AppColors.redColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    String? value,
    VoidCallback? onTap,
  }) {
    return InkWellWrapper(
      onTap: onTap,
      child: Container(
        height: 50.r,
        padding: const EdgeInsets.symmetric(horizontal: 14).r,
        decoration: _cardDecoration,
        child: Row(
          children: [
            AppText(
              context.tr(label),
              fontSize: kFont14,
              fontWeight: FontWeight.w500,
              color: AppColors.loginTextColor,
            ),
            12.widthSpace,
            Expanded(
              child: value == null
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Iconsax.arrow_right_3_copy,
                        size: 16.r,
                        color: AppColors.hintColor,
                      ),
                    )
                  : AppText(
                      value,
                      fontSize: kFont13,
                      color: AppColors.loginHintColor,
                      textAlign: TextAlign.end,
                      isOverflow: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _phone(UserModel? user) {
    final String number = user?.phoneNo ?? '';
    if (number.isEmpty) return '-';

    final String code = user?.phoneCode ?? '';
    return code.isEmpty || code.startsWith('+')
        ? '$code$number'
        : '+$code$number';
  }

  String _orDash(String? value) =>
      (value == null || value.isEmpty) ? '-' : value;

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
