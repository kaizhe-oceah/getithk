// Project imports:
import '../../imports.dart';

class NoDataWidget extends StatelessWidget {
  final Widget? builder;
  final String? text;
  final String? asset;
  final EdgeInsets? padding;
  final bool iconEnabled;
  final double opacity;
  final double? size;

  const NoDataWidget({
    super.key,
    this.builder,
    this.text,
    this.asset,
    this.padding,
    this.iconEnabled = true,
    this.opacity = 0.65,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 30).r,
      child:
          builder ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconEnabled)
                Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, iconEnabled ? -(1.sh * 0.05) : 0),
                    child: SizedBox(
                      width: size ?? AppSize.width * 0.6,
                      height: size ?? AppSize.width * 0.6,
                      child: AppImage(
                        name: AppAssets.lottiesNoData,
                        repeat: false,
                      ),
                    ),
                  ),
                  // AppImage.asset(
                  //   name: asset ?? AppAssets.noData,
                  //   width: AppSize.width * 0.3,
                  // ),
                ),
              Transform.translate(
                offset: Offset(0, iconEnabled ? -(1.sh * 0.075) : 0),
                child: AppText(
                  text ?? context.tr(AppStrings.noDataFound),
                  textAlign: TextAlign.center,
                  isOverflow: false,
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ),
    );
  }
}
