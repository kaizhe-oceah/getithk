// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../components/default/bottom_sheet_category_filter.dart';
import '../components/default/bottom_sheet_confirm.dart';
import '../components/default/bottom_sheet_language.dart';
import '../components/default/bottom_sheet_logout.dart';
import '../components/default/bottom_sheet_no_internet_connection.dart';
import '../components/default/bottom_sheet_phone_country.dart';
import '../components/default/bottom_sheet_stocks.dart';
import '../components/default/bottom_sheet_tag_filter.dart';
import '../imports.dart';
import '../models/backpack_model.dart';
import '../models/category_model.dart';
import '../models/phone_code_model.dart';
import '../models/product_tag_model.dart';
import '../models/shipment_item_model.dart';

class BottomSheetHelper {
  static BuildContext context = NavigationService.context;
  static ShapeBorder roundShapeBorder = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(20.0),
      topLeft: Radius.circular(20.0),
    ),
  );

  static void customBottomSheet({
    required Widget child,
    Widget? header,
    Widget? footer,
    bool isScrollable = true,
    double? maxHeightFactor = 0.7,
    bool isDismissable = true,
    bool enableDrag = true,
  }) {
    showBarModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      topControl: const SizedBox.shrink(),
      expand: false,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      isDismissible: isDismissable,
      enableDrag: enableDrag,
      builder: (context) {
        Widget content = SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (header != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kHorizontalPadding,
                      vertical: kHorizontalPadding,
                    ).r,
                    child: header,
                  ),
                Flexible(
                  child: isScrollable
                      ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: child,
                        )
                      : child,
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: kHorizontalPadding).r,
                    child: footer,
                  ),
              ],
            ),
          ),
        );

        if (maxHeightFactor != null) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
            ),
            child: content,
          );
        }

        return content;
      },
    );
  }

  static Future<void> language({required ValueChanged<String> onSelected}) {
    return showBarModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.transparent,
      shape: roundShapeBorder,
      backgroundColor: AppColors.darkSurfaceColor,
      builder: (context) => BottomSheetLanguage(onSelected: onSelected),
      topControl: const SizedBox.shrink(),
    );
  }

  /// The home product filter: tags to pick; [onConfirm] gets the picked tags
  /// on 確定篩選 (none on 重設).
  static Future<void> tagFilter({
    required List<ProductTagModel> selected,
    required ValueChanged<List<ProductTagModel>> onConfirm,
  }) {
    return showBarModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      backgroundColor: AppColors.whiteColor,
      topControl: const SizedBox.shrink(),
      builder: (context) =>
          BottomSheetTagFilter(selected: selected, onConfirm: onConfirm),
    );
  }

  /// The backpack filter: a category to pick; [onConfirm] gets it on
  /// 確定篩選 (null, every category, on 重設).
  static Future<void> categoryFilter({
    required CategoryModel? selected,
    required ValueChanged<CategoryModel?> onConfirm,
  }) {
    return showBarModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      backgroundColor: AppColors.whiteColor,
      topControl: const SizedBox.shrink(),
      builder: (context) =>
          BottomSheetCategoryFilter(selected: selected, onConfirm: onConfirm),
    );
  }

  /// The backpack's 申請出貨: the picked [stocks] and how many of each to
  /// ship; [onConfirm] gets them on 確認出貨.
  static Future<void> requestShipment({
    required List<BackpackModel> stocks,
    required ValueChanged<List<ShipmentItemModel>> onConfirm,
  }) {
    return _stocks(
      BottomSheetStocks(
        title: AppStrings.requestShipment,
        confirmText: AppStrings.confirmShipment,
        confirmColor: AppColors.blackColor,
        stocks: stocks,
        onConfirm: onConfirm,
      ),
    );
  }

  static Future<void> _stocks(BottomSheetStocks sheet) {
    return showModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      backgroundColor: AppColors.whiteColor,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      builder: (context) => sheet,
    );
  }


  static Future<void> phoneCountry({
    required List<PhoneCodeModel> codes,
    String? selected,
    required ValueChanged<PhoneCodeModel> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      backgroundColor: AppColors.whiteColor,
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      builder: (context) => BottomSheetPhoneCountry(
        codes: codes,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  static Future<bool?> confirm({
    required String title,
    required String description,
    required String cancelText,
    required String confirmText,
    required Future<bool> Function() onConfirm,
  }) {
    return showBarModalBottomSheet<bool>(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      backgroundColor: AppColors.whiteColor,
      topControl: const SizedBox.shrink(),
      builder: (context) => BottomSheetConfirm(
        title: title,
        description: description,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }

  static void logout() {
    showBarModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      builder: (context) => const BottomSheetLogout(),
      topControl: const SizedBox.shrink(),
    );
  }

  static Future<dynamic> noInternetConnection() async {
    return await showBarModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const BottomSheetNoInternetConnection(),
      topControl: const SizedBox.shrink(),
    );
  }
}
