// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import '../../imports.dart';
import '../../models/draw_video_model.dart';
import '../../services/draw_video_service.dart';

class DrawVideoDialog extends StatefulWidget {
  final DrawVideoModel video;

  const DrawVideoDialog({required this.video, super.key});

  static Future<void> show(BuildContext context, DrawVideoModel video) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      barrierDismissible: false,
      barrierColor: AppColors.blackColor,
      useSafeArea: false,
      child: DrawVideoDialog(video: video),
    );
  }

  @override
  State<DrawVideoDialog> createState() => _DrawVideoDialogState();
}

class _DrawVideoDialogState extends State<DrawVideoDialog> {
  VideoPlayerController? _controller;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final File? file = await DrawVideoService.cachedFile(widget.video);
    if (!mounted) return;

    final VideoPlayerController controller = file != null
        ? VideoPlayerController.file(file)
        : VideoPlayerController.networkUrl(Uri.parse(widget.video.file ?? ''));
    _controller = controller;

    try {
      await controller.initialize();
    } catch (e) {
      printLog('Draw video ${widget.video.id} not played: $e');
      _close();
      return;
    }
    if (!mounted) return;

    controller.addListener(_onVideoChanged);
    await controller.play();
    setState(() {});
  }

  void _onVideoChanged() {
    final VideoPlayerValue value = _controller!.value;
    if (value.isCompleted || value.hasError) _close();
  }

  void _close() {
    if (_isClosed || !mounted) return;

    _isClosed = true;
    AppNavigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    final bool isReady = controller != null && controller.value.isInitialized;

    // white status bar icons on the black
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: AppColors.blackColor,
        // inside the safe area, so the video and its 跳過 stay clear of the
        // notch and the home indicator
        child: SafeArea(
          child: isReady
              // the whole video at its own aspect ratio (contain)
              ? Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: _withSkip(VideoPlayer(controller)),
                  ),
                )
              : _withSkip(
                  const Center(child: CircularProgressIndicatorWidget()),
                ),
        ),
      ),
    );
  }

  /// [child] with 跳過 in its bottom right corner.
  Widget _withSkip(Widget child) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.r, bottom: 16.r),
            child: AppButtonWidget(
              text: context.tr(AppStrings.skip),
              isMinWidth: true,
              radius: 100,
              textSize: kFont13,
              buttonColor: AppColors.blackColor.wOpacity(0.4),
              borderColor: AppColors.whiteColor.wOpacity(0.6),
              textColor: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 6,
              ).r,
              onTap: _close,
            ),
          ),
        ),
      ],
    );
  }
}
