// Project imports:
import '../components/default/draw_video_dialog.dart';
import '../components/main_product/draw_confirm_dialog.dart';
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

    // short of points: 點數不夠 and the way to top up, not the draw
    if (context.read<AppController>().points < product.drawAmount * count) {
      await _notEnoughPoints();
      return null;
    }

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
  /// the best grade drawn and what was won, as for a real one; nothing's
  /// paid for or kept, so the result page only offers 會員註冊. Null if
  /// nothing was drawn.
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
    // whatever the API says: nothing from a trial is kept
    drawn.isTrial = true;

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

  /// [product]'s video for grade [gradeId]; nothing if it has none.
  static Future<void> _playVideo(MainProductModel product, int? gradeId) async {
    final DrawVideoModel? video = await DrawVideoService.videoForGrade(
      product,
      gradeId,
    );
    if (video != null) await DrawVideoDialog.show(context, video);
  }

  static Future<void> _notEnoughPoints() {
    return DialogHelper<void>().appDialog(
      title: context.tr(AppStrings.insufficientPoints),
      description: context.tr(AppStrings.notEnoughPointsMessage),
      leftButtonText: context.tr(AppStrings.cancel),
      leftButtonColor: AppColors.greyBackgroundColor,
      leftTextColor: AppColors.loginTextColor,
      leftFunction: () => AppNavigator.pop(context),
      rightButtonText: context.tr(AppStrings.buyDrawPoints),
      rightButtonColor: context.color.primary,
      rightTextColor: AppColors.whiteColor,
      rightFunction: () {
        AppNavigator.pop(context);
        AppNavigator.pushNamed(context, RouteName.topupPage);
      },
    );
  }

  /// 確認抽卡: the product's banner, how many, and the balance before ＞
  /// after; true once confirmed.
  static Future<bool?> _confirmDraw(MainProductModel product, int count) =>
      DrawConfirmDialog.show(context, product: product, count: count);
}
