// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../components/default/bottom_sheet_language.dart';
import '../components/default/bottom_sheet_logout.dart';
import '../components/default/bottom_sheet_no_internet_connection.dart';
import '../components/default/bottom_sheet_phone_country.dart';
import '../components/default/bottom_sheet_tag_filter.dart';
import '../imports.dart';
import '../models/phone_code_model.dart';
import '../models/product_tag_model.dart';

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
            // ✅ pushes content above keyboard
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
                // ✅ wrap content to allow scrolling if keyboard overlaps
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

  /// The phone field's country picker; [onSelected] gets the picked one.
  static Future<void> phoneCountry({
    required List<PhoneCodeModel> codes,
    String? selected,
    required ValueChanged<PhoneCodeModel> onSelected,
  }) {
    return showBarModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.black54,
      shape: roundShapeBorder,
      backgroundColor: AppColors.whiteColor,
      topControl: const SizedBox.shrink(),
      builder: (context) => BottomSheetPhoneCountry(
        codes: codes,
        selected: selected,
        onSelected: onSelected,
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
