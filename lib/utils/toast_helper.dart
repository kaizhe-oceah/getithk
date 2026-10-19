// Package imports:
import "package:bot_toast/bot_toast.dart";

// Project imports:
import '../imports.dart';

/// Toasts near the bottom: a white card, its icon and outline in the
/// status's colour (a tick for success, a cross for an error, a warning sign;
/// none, or [showToast]'s icon, for a plain one), rising and fading in.
class ToastHelper {
  static void showComingSoon(BuildContext context) {
    showToast(context.tr(AppStrings.comingSoon));
  }

  static void success(String message) =>
      showToast(message, type: ToastType.success);

  /// For a failed call: the API's message, or the network's.
  static void error(String message) =>
      showToast(message, type: ToastType.error);

  static void warning(String message) =>
      showToast(message, type: ToastType.warning);

  static void showToast(
    String message, {
    ToastType type = ToastType.normal,
    IconData? icon,
    Alignment? align,
  }) {
    final Color color = _color(type);
    final IconData? leading = icon ?? _icon(type);
    // errors and warnings stay a beat longer, to be read
    final bool isProblem = type == ToastType.error || type == ToastType.warning;

    BotToast.showCustomNotification(
      onlyOne: true,
      align: align ?? const Alignment(0, 0.85),
      useSafeArea: true,
      duration: Duration(seconds: isProblem ? 3 : 2),
      animationDuration: const Duration(milliseconds: 260),
      animationReverseDuration: const Duration(milliseconds: 200),
      wrapToastAnimation: (controller, _, child) => _rise(controller, child),
      toastBuilder: (_) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 24).r,
        padding: EdgeInsets.fromLTRB(
          leading == null ? 16.r : 10.r,
          10.r,
          16.r,
          10.r,
        ),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12).r,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 18.r, color: color),
              10.widthSpace,
            ],
            Flexible(
              child: AppText(
                message,
                fontSize: kFont13,
                fontWeight: FontWeight.w500,
                maxLines: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Up from a little below, fading in and settling to size; back out the
  /// same way.
  static Widget _rise(AnimationController controller, Widget child) {
    final Animation<double> curved = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }

  static IconData? _icon(ToastType type) => switch (type) {
    ToastType.normal => null,
    ToastType.success => Iconsax.tick_circle,
    ToastType.error => Iconsax.close_circle,
    ToastType.warning => Iconsax.warning_2,
  };

  static Color _color(ToastType type) => switch (type) {
    ToastType.normal => AppColors.toastNormalColor,
    ToastType.success => AppColors.toastSuccessColor,
    ToastType.error => AppColors.toastErrorColor,
    ToastType.warning => AppColors.toastWarningColor,
  };
}
