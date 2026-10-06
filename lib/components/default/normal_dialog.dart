// Project imports:
import '../../imports.dart';

class NormalDialog extends StatelessWidget {
  final String title;
  final String? description;

  /// Optional image (auto-detect: asset / network / svg)
  final String? image;

  // Left button
  final String? leftButtonText;
  final VoidCallback? leftFunction;
  final Color? leftTextColor;
  final Color? leftButtonColor;

  // Right button
  final String? rightButtonText;
  final VoidCallback? rightFunction;
  final Color? rightTextColor;
  final Color? rightButtonColor;

  // Custom builder (for flexible content)
  final Widget? builder;

  const NormalDialog({
    super.key,
    required this.title,
    this.description,
    this.image,
    this.leftButtonText,
    this.leftFunction,
    this.leftTextColor,
    this.leftButtonColor,
    this.rightButtonText,
    this.rightFunction,
    this.rightTextColor,
    this.rightButtonColor,
    this.builder,
  });

  bool get hasLeft => leftButtonText != null;
  bool get hasRight => rightButtonText != null;

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = 1.sw - kDialogPadding * 2;
    final double imageSize = dialogWidth * 0.3;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(kDialogPadding).r,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10).r,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, imageSize),
            if (hasLeft || hasRight)
              Container(height: 1, color: AppColors.greyLightColor),
            if (hasLeft || hasRight) _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // 🔹 Header Section (with optional AppImage)
  Widget _buildHeader(BuildContext context, double imageSize) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        kDialogPadding / 3,
        kDialogPadding / 3,
        kDialogPadding / 3,
        builder == null ? kDialogPadding / 3 : 0,
      ).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🖼️ Optional auto-detect image
          if (image != null && image!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10).r,
              child: AppImage(
                name: image!,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
            ),

          // 🧾 Title
          AppText(
            title,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w600,
          ),

          // 📝 Description or custom builder
          if (builder != null || description?.isNotEmpty == true) ...[
            0.heightSpace,
            Padding(
              padding: const EdgeInsets.only(top: 10).r,
              child:
                  builder ??
                  AppText(
                    description!,
                    textAlign: TextAlign.center,
                    isOverflow: false,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  // 🔹 Footer Section (Buttons)
  Widget _buildFooter(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          if (hasLeft)
            Expanded(
              child: _buildButton(
                leftButtonText!,
                leftFunction,
                leftTextColor,
                leftButtonColor,
              ),
            ),
          if (hasLeft && hasRight)
            Container(width: 1, color: AppColors.greyLightColor),
          if (hasRight)
            Expanded(
              child: _buildButton(
                rightButtonText!,
                rightFunction,
                rightTextColor,
                rightButtonColor,
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 Reusable Button Builder
  Widget _buildButton(
    String text,
    VoidCallback? onTap,
    Color? textColor,
    Color? backgroundColor,
  ) {
    return InkWellWrapper(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10).r,
        color: backgroundColor,
        alignment: Alignment.center,
        child: AppText(
          text,
          color: textColor ?? AppColors.blackColor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
