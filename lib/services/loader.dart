// Project imports:
import '../imports.dart';

const defaultValue = 56.0;

class Loader extends StatefulWidget {
  const Loader(this._status, {super.key});

  static OverlayEntry? _overlayEntry;
  final String? _status;
  static OverlayState? _overlayState;

  /// Whether the loader is currently *intended* to be visible. Tracking intent
  /// (rather than only the entry) lets a fast [hide] cancel a still-pending
  /// [show] so the deferred insert below is skipped instead of orphaned.
  static bool _shouldShow = false;

  /// Whether [_overlayEntry] has actually been inserted into the overlay.
  /// Guards against removing an entry that was never inserted.
  static bool _inserted = false;

  /// Live status text so a long task (e.g. video compression) can update the
  /// loader message — via [updateStatus] — without rebuilding the overlay.
  static final ValueNotifier<String?> _statusNotifier = ValueNotifier(null);

  /// Update the visible loader message while it is showing.
  static void updateStatus(String? status) => _statusNotifier.value = status;

  static Future<void> show({
    String? status,
    Color? overlayColor,
    BuildContext? context,
  }) async {
    _shouldShow = true;
    _statusNotifier.value = status;
    await 0.01.delay();

    // A hide() during the await above flips the intent — skip the insert so we
    // don't orphan a loader that was already asked to disappear.
    if (!_shouldShow) return;

    /// Create OverlayState — the root navigator's own overlay (see
    /// NavigationService.overlay; do not use Overlay.of on the nav context).
    _overlayState = NavigationService.overlay;

    if (_overlayEntry == null) {
      /// Create current Loader Entry
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Stack(
            children: <Widget>[
              Container(color: overlayColor ?? Colors.black45),
              Center(child: Loader(status)),
            ],
          );
        },
      );

      // Insert immediately rather than on a post-frame callback: when the UI
      // is idle (e.g. awaiting a native call like video compression) no new
      // frame is scheduled, so a deferred insert would never fire and the
      // loader wouldn't show. We're already past the build phase here (show()
      // awaits a timer first), so a direct insert is safe.
      try {
        _overlayState?.insert(_overlayEntry!);
        _inserted = true;
        // Ensure a frame is pumped so the overlay paints even while idle.
        WidgetsBinding.instance.scheduleFrame();
      } catch (e) {
        // Insert failed — drop the entry so a later show() can retry.
        _overlayEntry = null;
        _inserted = false;
        printLog(e.toString());
      }
    }
  }

  static Widget loaderWidget({String? status}) {
    return Stack(
      children: <Widget>[
        Container(color: Colors.black45),
        Center(child: Loader(status)),
      ],
    );
  }

  /// hide() method
  static Future<void> hide() async {
    // Clear intent first so a still-pending show() (awaiting its timer) sees
    // this and skips its insert.
    _shouldShow = false;
    _statusNotifier.value = null;
    await 0.01.delay();

    if (_overlayEntry != null) {
      try {
        // Only remove if it was actually inserted — removing a never-inserted
        // entry throws.
        if (_inserted) _overlayEntry?.remove();
      } catch (e) {
        printLog(e.toString());
      } finally {
        _overlayEntry = null;
        _inserted = false;
      }
    }
  }

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  final loaderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: loaderKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20).r,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(10).r,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live status as the indicator's text: prefers the notifier
                // (updatable mid-task), falling back to the status passed at
                // construction, then to the indicator's own "Loading...".
                ValueListenableBuilder<String?>(
                  valueListenable: Loader._statusNotifier,
                  builder: (context, liveStatus, _) =>
                      CircularProgressIndicatorWidget(
                        text: liveStatus ?? widget._status,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
