// Project imports:
import '../controllers/edit_profile_controller.dart';
import '../imports.dart';
import '../models/avatar_setting_model.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  static const int _columns = 5;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.editProfile),
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<EditProfileController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, EditProfileController controller) {
    final bool loading = controller.isLoading;
    final AvatarSettingModel setting =
        controller.setting ??
        (loading
            ? AvatarSettingModel.placeholder()
            : AvatarSettingModel.fromJson({}));
    final double side = kHorizontalPadding.r;

    return Column(
      children: [
        Expanded(
          child: AppSkeletonizer(
            enabled: loading,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(side, 14.r, side, 20.r),
                  sliver: SliverToBoxAdapter(
                    child: _header(context, controller, setting),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(side, 0, side, 20.r),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _columns,
                      mainAxisSpacing: 10.r,
                      crossAxisSpacing: 10.r,
                    ),
                    itemCount: setting.avatars.length,
                    itemBuilder: (context, index) => _avatarItem(
                      context,
                      controller,
                      setting.avatars[index],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _saveBar(context, controller),
      ],
    );
  }

  Widget _header(
    BuildContext context,
    EditProfileController controller,
    AvatarSettingModel setting,
  ) {
    final Color primary = context.color.primary;

    return Row(
      children: [
        _preview(context, controller.avatarImage, setting.frameImage),
        14.widthSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                context.tr(AppStrings.nickname),
                fontSize: kFont11,
                color: AppColors.loginHintColor,
              ),
              TextField(
                controller: controller.nameController,
                style: TextStyle(
                  fontSize: kFont15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.loginTextColor,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8).r,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyLight2Color),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primary),
                  ),
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 24.r,
                    minHeight: 24.r,
                  ),
                  suffixIcon: InkWellWrapper(
                    onTap: controller.onResetName,
                    child: Icon(
                      Iconsax.refresh_copy,
                      size: 16.r,
                      color: AppColors.loginHintColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _preview(BuildContext context, String? image, String? frame) {
    final Color primary = context.color.primary;
    final double size = 72.r;
    final double badgeSize = 22.r;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primary, width: 2),
              ),
              child: _circleImage(image),
            ),
          ),
          if (frame != null)
            Positioned.fill(
              child: AppImage(name: frame, fit: BoxFit.contain),
            ),
          Positioned(
            right: -2.r,
            bottom: -2.r,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.whiteColor, width: 2),
              ),
              child: Icon(
                Iconsax.camera,
                size: 11.r,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [avatar] in a circle, ringed in red if it's the one picked.
  Widget _avatarItem(
    BuildContext context,
    EditProfileController controller,
    AvatarModel avatar,
  ) {
    final bool selected =
        avatar.id != null && avatar.id == controller.avatar?.id;

    return InkWellWrapper(
      onTap: () => controller.onSelectAvatar(avatar),
      child: Container(
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? context.color.primary
                : AppColors.transparentColor,
            width: 2,
          ),
        ),
        child: _circleImage(avatar.image),
      ),
    );
  }

  Widget _circleImage(String? image) {
    return ClipOval(
      child: image == null
          ? const ColoredBox(
              color: AppColors.greyBackgroundColor,
              child: SizedBox.expand(),
            )
          : AppImage(
              name: image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _saveBar(BuildContext context, EditProfileController controller) {
    final double side = kHorizontalPadding.r;

    return Container(
      padding: EdgeInsets.fromLTRB(
        side,
        10.r,
        side,
        10.r + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        border: Border(top: BorderSide(color: AppColors.greyLight2Color)),
      ),
      child: AppButtonWidget(
        text: context.tr(AppStrings.save),
        radius: 12,
        fontWeight: FontWeight.w600,
        textColor: AppColors.whiteColor,
        gradient: AppColors.brandGradientColor,
        padding: const EdgeInsets.symmetric(vertical: 8).r,
        onTap: controller.isLoading ? null : controller.onSave,
      ),
    );
  }
}
