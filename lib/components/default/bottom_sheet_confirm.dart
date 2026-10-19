// Project imports:
import '../../imports.dart';

/// A yes-or-no question: [title] and [description] centred, then
/// [cancelText] in grey, which closes it, and [confirmText] in red, which
/// runs [onConfirm] and, once that's true, closes it with true.
class BottomSheetConfirm extends StatelessWidget {
  /// Translation keys.
  final String title;
  final String description;
  final String cancelText;
  final String confirmText;

  /// True once done; false keeps the sheet open (e.g. the API failed).
  final Future<bool> Function() onConfirm;

  const BottomSheetConfirm({
    required this.title,
    required this.description,
    required this.cancelText,
    required this.confirmText,
    required this.onConfirm,
    super.key,
  });

  Future<void> _onConfirm(BuildContext context) async {
    final bool isDone = await onConfirm();
    if (isDone && context.mounted) AppNavigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 16).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              context.tr(title),
              fontSize: kFont16,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            10.heightSpace,
            AppText(
              context.tr(description),
              fontSize: kFont13,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
            22.heightSpace,
            Row(
              children: [
                Expanded(
                  child: AppButtonWidget(
                    text: context.tr(cancelText),
                    radius: 10,
                    fontWeight: FontWeight.w600,
                    buttonColor: AppColors.greyBackgroundColor,
                    textColor: AppColors.loginTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 12).r,
                    onTap: () => AppNavigator.pop(context),
                  ),
                ),
                12.widthSpace,
                Expanded(
                  child: AppButtonWidget(
                    text: context.tr(confirmText),
                    radius: 10,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.whiteColor,
                    gradient: AppColors.brandGradientColor,
                    padding: const EdgeInsets.symmetric(vertical: 12).r,
                    onTap: () => _onConfirm(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
