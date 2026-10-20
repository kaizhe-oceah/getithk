// Package imports:
import 'package:video_player/video_player.dart';

// Project imports:
import '../../imports.dart';
import '../../models/draw_video_model.dart';
import '../../services/draw_video_service.dart';

class DrawVideoDialog extends StatefulWidget {
  final DrawVideoModel? video;
  final String? asset;

  const DrawVideoDialog({required DrawVideoModel this.video, super.key})
    : asset = null;

  const DrawVideoDialog.asset(String this.asset, {super.key}) : video = null;

  static Future<void> show(BuildContext context, DrawVideoModel video) =>
      _show(context, DrawVideoDialog(video: video));

  static Future<void> showAsset(BuildContext context, String asset) =>
      _show(context, DrawVideoDialog.asset(asset));

  static Future<void> _show(BuildContext context, DrawVideoDialog dialog) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      barrierDismissible: false,
      barrierColor: AppColors.blackColor,
      useSafeArea: false,
      child: dialog,
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
    final VideoPlayerController? controller = await _newController();
    if (controller == null) return;
    _controller = controller;

    try {
      await controller.initialize();
    } catch (e) {
      printLog('Video ${widget.asset ?? widget.video?.id} not played: $e');
      _close();
      return;
    }
    if (!mounted) return;

    controller.addListener(_onVideoChanged);
    await controller.play();
    setState(() {});
  }

  Future<VideoPlayerController?> _newController() async {
    final String? asset = widget.asset;
    if (asset != null) return VideoPlayerController.asset(asset);

    final DrawVideoModel video = widget.video!;
    final File? file = await DrawVideoService.cachedFile(video);
    if (!mounted) return null;

    return file != null
        ? VideoPlayerController.file(file)
        : VideoPlayerController.networkUrl(Uri.parse(video.file ?? ''));
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: AppColors.blackColor,
        child: SafeArea(
          child: isReady
              ? Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: _withSkip(VideoPlayer(controller)),
                  ),
                )
              : _withSkip(const SizedBox.shrink()),
        ),
      ),
    );
  }

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
