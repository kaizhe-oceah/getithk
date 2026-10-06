// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

// Project imports:
import '../../imports.dart';

class AppImage extends StatefulWidget {
  /// Can be asset, network URL, SVG, Lottie JSON, or local file, video, file video
  final String? name;
  final double? width;
  final double? height;
  final double? scale;
  final Color? color;
  final BoxFit? fit;
  final double radius;
  final BorderRadius? borderRadius;
  final bool clearMemoryCacheWhenDispose;
  final VoidCallback? onTap;

  /// Whether to loop Lottie animation
  final bool repeat;

  /// Whether tapping the image opens viewer
  final bool viewEnabled;

  /// Whether to show fallback image on error
  final bool fallbackEnabled;

  /// Whether to show video thumbnail (true) or black placeholder (false)
  final bool isThumbnail;

  const AppImage({
    super.key,
    this.name,
    this.width,
    this.height,
    this.scale,
    this.color,
    this.fit,
    this.radius = 0.0,
    this.borderRadius,
    this.clearMemoryCacheWhenDispose = false,
    this.onTap,
    this.repeat = true,
    this.viewEnabled = false,
    this.fallbackEnabled = true,
    this.isThumbnail = true,
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  late Future<String?> thumbnailFuture;

  String get _safeName => (widget.name?.trim().isEmpty ?? true)
      ? AppAssets.logo
      : widget.name!.trim();

  /// Common video container extensions across Android & iOS. HEVC (H.265)
  /// footage ships inside `.mov`/`.mp4` containers — the codec doesn't change
  /// the extension — so covering the containers is what matters here.
  static const _videoExtensions = {
    ".mp4",
    ".mov",
    ".m4v",
    ".hevc",
    ".h265",
    ".3gp",
    ".3g2",
    ".mkv",
    ".webm",
    ".avi",
    ".ts",
    ".m2ts",
    ".mts",
    ".mpeg",
    ".mpg",
    ".wmv",
    ".flv",
    ".f4v",
    ".ogv",
    ".qt",
    ".mxf",
  };

  /// Lower-cased path with any URL query/fragment stripped, so extension
  /// checks still work for URLs like `.../clip.mov?token=abc`.
  String get _extPath {
    var name = _safeName;
    final cut = name.indexOf(RegExp(r'[?#]'));
    if (cut != -1) name = name.substring(0, cut);
    return name.toLowerCase();
  }

  bool get isVideo => _videoExtensions.any(_extPath.endsWith);
  bool get isSvg => _extPath.endsWith(".svg");
  bool get isLottie => _extPath.endsWith(".json");
  bool get isNetwork =>
      _safeName.startsWith("http://") || _safeName.startsWith("https://");

  BorderRadius get _radius =>
      widget.borderRadius ?? BorderRadius.circular(widget.radius).r;

  /// Path with any `file://` scheme stripped, for local-file access.
  String get _filePath => _safeName.startsWith('file://')
      ? _safeName.replaceFirst('file://', '')
      : _safeName;

  void _initThumbnail() {
    // Created once per source (not per build) so rebuilds — e.g. progress
    // setState ticks in a parent — never regenerate the thumbnail.
    thumbnailFuture = isVideo ? getThumbnail(_filePath) : Future.value(null);
  }

  @override
  void initState() {
    super.initState();
    _initThumbnail();
  }

  @override
  void didUpdateWidget(covariant AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Source changed (e.g. compressed file swapped in) → new thumbnail.
    if (oldWidget.name != widget.name) _initThumbnail();
  }

  @override
  void dispose() {
    if (widget.clearMemoryCacheWhenDispose && isNetwork) {
      clearMemoryImageCache(_safeName);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _buildImage();

    if (isVideo) {
      return RepaintBoundary(
        child: Stack(
          children: [
            // content
            Positioned.fill(
              child: _wrapWithView(context, imageWidget, widget.name),
            ),

            // video play icon
            if (isVideo)
              LayoutBuilder(
                builder: (context, constraint) {
                  double height = constraint.maxHeight;

                  return IgnorePointer(
                    child: Center(
                      child: Container(
                        width: height * 0.35,
                        height: height * 0.35,
                        decoration: BoxDecoration(
                          color: AppColors.blackColor.wOpacity(0.75),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          MdiIcons.play,
                          color: AppColors.whiteColor,
                          size: height * 0.25,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    }

    return _wrapWithView(context, imageWidget, widget.name);
  }

  Widget _buildImage() {
    // 🎞️ Lottie JSON animation
    if (isLottie) {
      printLog("🎞️ Lottie JSON animation");
      return ClipRRect(
        borderRadius: _radius,
        child: isNetwork
            ? Lottie.network(
                _safeName,
                width: widget.width,
                height: widget.height,
                fit: widget.fit ?? BoxFit.contain,
                repeat: widget.repeat,
              )
            : Lottie.asset(
                _safeName,
                width: widget.width,
                height: widget.height,
                fit: widget.fit ?? BoxFit.contain,
                repeat: widget.repeat,
              ),
      );
    }

    // 🖼️ SVG
    if (isSvg) {
      printLog("🖼️ SVG");
      if (isNetwork) {
        return SvgPicture.network(
          _safeName,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.contain,
          colorFilter: widget.color != null
              ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
              : null,
          placeholderBuilder: (_) => _skeletonPlaceholder(),
        );
      }
      return SvgPicture.asset(
        _safeName,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.contain,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
      );
    }

    // 📁 Local file path
    if (_safeName.startsWith('/') || _safeName.startsWith('file://')) {
      final filePath = _safeName.startsWith('file://')
          ? _safeName.replaceFirst('file://', '')
          : _safeName;

      printLog("Local file path : ${File(filePath).path}");

      if (isVideo) {
        if (!widget.isThumbnail) return _blackPlaceholder();

        return FutureBuilder<String?>(
          future: thumbnailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _skeletonPlaceholder();
            }

            final thumb = snapshot.data;

            // Thumbnail failed (e.g. container/codec the platform can't
            // decode) → black tile; the play icon overlay still shows.
            if (thumb == null || thumb.isEmpty) {
              return _blackPlaceholder();
            }

            return AppImage(
              name: thumb, // <-- this IS an image file (jpg/png)
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              radius: widget.radius,
            );
          },
        );
      }

      return ClipRRect(
        borderRadius: _radius,
        child: ExtendedImage.file(
          File(filePath),
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.cover,
          color: widget.color,
          gaplessPlayback: true,
        ),
      );
    }

    // VIDEO → Generate thumbnail
    if (isVideo) {
      printLog("VIDEO → Generate thumbnail");

      if (!widget.isThumbnail) return _blackPlaceholder();

      return FutureBuilder<String?>(
        future: thumbnailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _skeletonPlaceholder();
          }

          final thumb = snapshot.data;

          // Thumbnail failed (undecodable container/codec or fetch error) →
          // black tile; the play icon overlay still shows on top.
          if (thumb == null || thumb.isEmpty) {
            return _blackPlaceholder();
          }

          // Render thumbnail using AppImage for consistency
          return AppImage(
            name: thumb,
            width: widget.width,
            height: widget.height,
            fit: widget.fit ?? BoxFit.cover,
            radius: widget.radius,
            borderRadius: widget.borderRadius,
            clearMemoryCacheWhenDispose: widget.clearMemoryCacheWhenDispose,
            fallbackEnabled: widget.fallbackEnabled,
          );
        },
      );
    }

    // 🌐 Network image
    if (isNetwork) {
      printLog("🌐 Network image");

      return ExtendedImage.network(
        _safeName,
        width: widget.width,
        height: widget.height,
        color: widget.color,
        fit: widget.fit ?? BoxFit.cover,
        cache: true,
        borderRadius: _radius,
        shape: BoxShape.rectangle,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return _skeletonPlaceholder();
            case LoadState.completed:
              return null; // use default rendering
            case LoadState.failed:
              return widget.fallbackEnabled
                  ? _fallbackWidget()
                  : const SizedBox();
          }
        },
      );
    }

    // 📦 Local asset fallback
    return ClipRRect(
      borderRadius: _radius,
      child: ExtendedImage.asset(
        _safeName,
        width: widget.width,
        height: widget.height,
        scale: widget.scale ?? 1.0,
        color: widget.color,
        fit: widget.fit ?? BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }

  /// Tap-to-view (always uses original name, not thumbnail)
  Widget _wrapWithView(BuildContext context, Widget child, String? source) {
    final hasTapAction = widget.onTap != null || widget.viewEnabled;

    if (!hasTapAction) return child;

    return InkWellWrapper(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
          return;
        }

        // fallback: open viewer if enabled
        if (widget.viewEnabled && (source?.isNotEmpty ?? false)) {
          printLog("📸 Viewing source: $source");
          _showFullScreenViewer(context, source!);
        }
      },
      child: child,
    );
  }

  /// Full-screen, pinch-to-zoom preview of the tapped image.
  void _showFullScreenViewer(BuildContext context, String source) {
    showDialog(
      context: context,
      barrierColor: AppColors.blackColor,
      builder: (dialogContext) => Stack(
        children: [
          PhotoView(
            imageProvider: isNetworkUrl(source)
                ? ExtendedNetworkImageProvider(source)
                : (source.startsWith("assets/")
                          ? AssetImage(source)
                          : FileImage(File(source)))
                      as ImageProvider,
            backgroundDecoration: const BoxDecoration(
              color: AppColors.blackColor,
            ),
            minScale: PhotoViewComputedScale.contained,
          ),
          Positioned(
            top: MediaQuery.of(dialogContext).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.whiteColor),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonPlaceholder() {
    return AppSkeletonizer(
      child: Bone(
        width: widget.width,
        height: widget.height,
        borderRadius: _radius,
      ),
    );
  }

  Widget _blackPlaceholder() {
    return ClipRRect(
      borderRadius: _radius,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.blackColor,
      ),
    );
  }

  Widget _fallbackWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.greyLightColor,
        borderRadius: _radius,
      ),
      child: widget.fallbackEnabled
          ? AppImage(
              name: AppAssets.logo,
              fit: BoxFit.contain,
              color: AppColors.blackColor.wOpacity(0.2),
            )
          : null,
    );
  }
}
