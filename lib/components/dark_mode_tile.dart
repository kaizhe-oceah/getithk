// Package imports:
import 'package:haptic_feedback/haptic_feedback.dart';

// Project imports:
import '../imports.dart';

/// 深色模式: turns dark mode on and off for the whole app.
class DarkModeTile extends StatelessWidget {
  final BoxDecoration decoration;

  const DarkModeTile({required this.decoration, super.key});

  static const Duration _duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final ThemeController theme = context.watch<ThemeController>();
    final bool dark = theme.isDark;

    return InkWellWrapper(
      onTap: () {
        Haptics.vibrate(HapticsType.soft);
        theme.setDarkMode(!dark);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11).r,
        decoration: decoration,
        child: Row(
          children: [
            _badge(context, dark),
            12.widthSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    context.tr(AppStrings.darkMode),
                    fontSize: kFont14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.loginTextColor,
                  ),
                  2.heightSpace,
                  AnimatedSwitcher(
                    duration: _duration,
                    child: AppText(
                      context.tr(
                        dark ? AppStrings.darkModeOn : AppStrings.darkModeOff,
                      ),
                      key: ValueKey(dark),
                      fontSize: kFont11,
                      color: AppColors.loginHintColor,
                      maxLines: 1,
                      isOverflow: true,
                    ),
                  ),
                ],
              ),
            ),
            10.widthSpace,
            _switch(context, dark),
          ],
        ),
      ),
    );
  }

  // the sun, or the moon, turning in as it changes
  Widget _badge(BuildContext context, bool dark) {
    final Color color = dark ? context.color.primary : AppColors.coinColor;
    final double size = 38.r;

    return AnimatedContainer(
      duration: _duration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.wOpacity(dark ? 0.18 : 0.14),
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: AnimatedSwitcher(
        duration: _duration,
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.5, end: 1).animate(animation),
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: Icon(
          dark ? Iconsax.moon : Iconsax.sun_1,
          key: ValueKey(dark),
          size: 20.r,
          color: color,
        ),
      ),
    );
  }

  Widget _switch(BuildContext context, bool dark) {
    final double width = 50.r;
    final double height = 30.r;
    final double inset = 3.r;
    final double thumb = height - inset * 2;

    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOutCubic,
      width: width,
      height: height,
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: dark ? context.color.primary : AppColors.greyLightColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedAlign(
        duration: _duration,
        curve: Curves.easeOutBack,
        alignment: dark ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: thumb,
          height: thumb,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.wOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: _duration,
            child: Icon(
              dark ? Iconsax.moon : Iconsax.sun_1,
              key: ValueKey(dark),
              size: 13.r,
              color: dark ? context.color.primary : AppColors.coinColor,
            ),
          ),
        ),
      ),
    );
  }
}
