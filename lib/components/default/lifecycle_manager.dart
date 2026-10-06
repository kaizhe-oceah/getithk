// Package imports:
import "package:universal_html/html.dart" as html;

// Project imports:
import '../../imports.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  const LifeCycleManager({super.key, required this.child});
  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // html.window.addEventListener('focus', onFocus);
      // html.window.addEventListener('blur', onBlur);
      html.window.onBeforeUnload.listen((event) async {
        printLog("====== closed web page");
      });
    } else {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // void onFocus(html.Event e) {
  //   didChangeAppLifecycleState(AppLifecycleState.resumed);
  // }

  // void onBlur(html.Event e) {
  //   didChangeAppLifecycleState(AppLifecycleState.detached);
  // }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      printLog("************** RESUMED");
    } else if (state == AppLifecycleState.paused) {
      printLog("************** PAUSED");
    } else if (state == AppLifecycleState.detached) {
      printLog("************** DETACHED");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width <= 600 ? size.width : AppSize.mobileWebWidth;
    final height = AppSize.height;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(width, height),
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Container(
        color: AppColors.whiteColor,
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
