// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../components/default/bottom_sheet_language.dart';
import '../components/default/bottom_sheet_logout.dart';
import '../components/default/bottom_sheet_no_internet_connection.dart';
import '../imports.dart';

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
