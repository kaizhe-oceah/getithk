// Project imports:
import '../components/default/draw_video_dialog.dart';
import '../components/main_product/main_product_parts.dart';
import '../imports.dart';
import '../models/draw_result_model.dart';
import '../models/draw_video_model.dart';
import '../models/main_product_model.dart';
import '../services/draw_video_service.dart';

class DrawHelper {
  static BuildContext get context => NavigationService.context;

  /// Draws [count] of [product] once 確認抽卡 is tapped, plays the video of
  /// the best grade drawn, then shows what was won (抽獎結果) until its back
  /// button. [product] gets its stock after the draw; null if nothing was
  /// drawn.
  static Future<DrawResultModel?> drawProduct(
    MainProductModel product,
    int count,
  ) async {
    final int? id = product.id;
    if (id == null) return null;

    final bool? confirmed = await _confirmDraw(product, count);
    if (confirmed != true) return null;

    DrawResultModel? result;
    await ApiService.api.drawProduct(
      mainProductId: id,
      drawAmount: product.drawAmount,
      drawCount: count,
      showLoader: true,
      onSuccess: (response) => result = DrawResultModel.fromJson(response.data),
    );
    final DrawResultModel? drawn = result;
    if (drawn == null) return null;

    product
      ..remainingDraws = drawn.remainingDraws
      ..totalDraws = drawn.totalDraws
      ..userRemainingDraws = drawn.userRemainingDraws
      ..isAvailable = drawn.isAvailable
      ..isSoldOut = drawn.remainingDraws <= 0;

    // the balance after paying for it
    context.read<AppController>().getWalletBalance();

    // once the video's done or skipped
    await _playVideo(product, drawn.highestGrade);
    if (drawn.drawHistories.isNotEmpty) {
      await AppNavigator.pushNamed(
        context,
        RouteName.prizeResultPage,
        arguments: drawn,
      );
    }
    return drawn;
  }

  /// A free trial draw of [count] (1 or 10) of [product], then the video of
  /// the best grade drawn, as for a real one; nothing's paid for or kept.
  /// Null if nothing was drawn.
  static Future<DrawResultModel?> trialDrawProduct(
    MainProductModel product,
    int count,
  ) async {
    final int? id = product.id;
    if (id == null) return null;

    DrawResultModel? result;
    await ApiService.api.trialDrawProduct(
      mainProductId: id,
      drawCount: count,
      showLoader: true,
      onSuccess: (response) => result = DrawResultModel.fromJson(response.data),
    );
    final DrawResultModel? drawn = result;
    if (drawn == null) return null;

    await _playVideo(product, drawn.highestGrade);
    return drawn;
  }

  /// [product]'s video for grade [gradeId]; nothing if it has none.
  static Future<void> _playVideo(MainProductModel product, int? gradeId) async {
    final DrawVideoModel? video = await DrawVideoService.videoForGrade(
      product,
      gradeId,
    );
    if (video != null) await DrawVideoDialog.show(context, video);
  }

  /// 確認抽卡: the product and how many, and the points it costs; true once
  /// confirmed.
  static Future<bool?> _confirmDraw(MainProductModel product, int count) {
    final Color primary = context.color.primary;
    final double coinSize = 22.r;

    return DialogHelper<bool>().appDialog(
      title: context.tr(AppStrings.confirmDraw),
      description: context.tr(
        AppStrings.confirmDrawMessage,
        namedArgs: {
          'name': product.name ?? product.categoryName ?? '',
          'count': '$count',
        },
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 12).r,
        decoration: BoxDecoration(
          color: primary.wOpacity(0.1),
          borderRadius: BorderRadius.circular(10).r,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(
              name: AppAssets.coins,
              width: coinSize,
              height: coinSize,
              fit: BoxFit.contain,
            ),
            6.widthSpace,
            AppText(
              formatMainProductAmount(product.drawAmount * count),
              fontSize: kFont18,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ],
        ),
      ),
      leftButtonText: context.tr(AppStrings.cancel),
      leftButtonColor: AppColors.whiteColor,
      leftButtonBorderColor: primary,
      leftTextColor: primary,
      leftFunction: () => AppNavigator.pop(context, false),
      rightButtonText: context.tr(AppStrings.confirmDraw),
      rightTextColor: AppColors.whiteColor,
      rightFunction: () => AppNavigator.pop(context, true),
    );
  }
}
