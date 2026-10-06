// Project imports:
import '../../imports.dart';

class DialogWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final String? iconPath;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final Function()? onPrimaryTap;
  final Function()? onSecondaryTap;
  final String? imageAsset;
  final double? imageSize;

  const DialogWidget(
      {super.key,
      this.title,
      this.message,
      this.iconPath,
      this.primaryButtonText,
      this.secondaryButtonText,
      this.onPrimaryTap,
      this.onSecondaryTap,
      this.imageAsset,
      this.imageSize = 250});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.fw),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: LayoutBuilder(
            builder: (context, constraint) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imageAsset != null) (imageSize! / 3).heightSpace,
                      if (iconPath != null)
                        Align(
                          heightFactor: 0,
                          child: Container(
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: AppImage(
                              name: iconPath,
                              width: 150.fw,
                            ),
                          ),
                        ),
                      if (iconPath != null) 90.heightSpace,
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AppText(title!),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: title != null ? 2.fw : 12.fw,
                            bottom: 16.fw,
                            left: 12.fw,
                            right: 12.fw),
                        child: Text(
                          message ?? context.tr(AppStrings.internalServerError),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 6.fw),
                              child: AppButtonWidget(
                                onTap: onPrimaryTap ?? () {},
                                text: primaryButtonText!,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.fw,
                                    vertical: 8.fw),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 6.fw),
                              child: AppButtonWidget(
                                onTap: onSecondaryTap ?? () {},
                                text: secondaryButtonText!,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.fw,
                                    vertical: 8.fw),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Wrap(
                      //   children: [
                      //     Expanded(
                      //       child: Padding(
                      //         padding: const EdgeInsets.symmetric(vertical: 6),
                      //         child: PrimaryTextButton(
                      //           onTap: onPrimaryTap,
                      //           text: primaryButtonText!,
                      //           width: double.infinity,
                      //           padding:
                      //               EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Padding(
                      //         padding: const EdgeInsets.symmetric(vertical: 6),
                      //         child: PrimaryTextButton(
                      //           onTap: onSecondaryTap,
                      //           isOutline: true,
                      //           text: secondaryButtonText!,
                      //           width: double.infinity,
                      //           padding:
                      //               EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      20.heightSpace,
                      // const Divider(
                      //   height: 1.5,
                      //   thickness: 1.5,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     Expanded(
                      //       child: SizedBox(
                      //         height: 42,
                      //         child: Material(
                      //           color: Colors.transparent,
                      //           child: InkWell(
                      //             onTap: () {
                      //               Get.back();
                      //             },
                      //             splashColor: AppColors.primaryAccent,
                      //             child: Center(
                      //                 child: Text(
                      //                navigator!.context.tr(Texts.  close,
                      //               style: TextStyles.titleMedium.copyWith(
                      //                   color: AppColors.primary,
                      //                   letterSpacing: 1,
                      //                   fontWeight: FontWeight.w700),
                      //             )),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),

                  // image asset
                  if (imageAsset != null)
                    Positioned(
                      top: -(imageSize!.fw / 1.7),
                      left: constraint.maxWidth / 2 - imageSize!.fw / 1.7,
                      child: AppImage(
                        name: imageAsset,
                        width: imageSize!.fw,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
