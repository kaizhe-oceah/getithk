// Package imports:
import 'package:flutter_exit_app/flutter_exit_app.dart';

// Project imports:
import '../../imports.dart';

class PopScopeCloseConfirmation extends StatefulWidget {
  final Widget child;
  const PopScopeCloseConfirmation({super.key, required this.child});

  @override
  State<PopScopeCloseConfirmation> createState() =>
      _PopScopeCloseConfirmationState();
}

class _PopScopeCloseConfirmationState extends State<PopScopeCloseConfirmation> {
  DateTime? currentBackPressTime;
  bool allowPop = false;

  void popScopeOnConfirm() {
    DateTime now = DateTime.now().toLocal();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ToastHelper.showToast(
        context.tr(AppStrings.pressBackAgainToExitApplicaton),
      );
    } else {
      currentBackPressTime = null;
      if (!kIsWeb) {
        Platform.isAndroid
            ? FlutterExitApp.exitApp()
            : FlutterExitApp.exitApp(iosForceExit: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, callback) {
        printLog("didPopdidPopdidPopdidPop : $didPop");
        if (didPop) return;

        popScopeOnConfirm();
      },
      child: widget.child,
    );
  }
}
