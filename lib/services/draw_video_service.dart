// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import '../imports.dart';
import '../models/draw_video_model.dart';
import '../models/main_product_model.dart';

/// The draw videos, downloaded ahead in the background so they're on the
/// device when a draw plays one. Nothing waits on it: a video that isn't
/// downloaded yet can still play from its URL.
///
/// Each file is saved exactly as the server has it, never compressed or
/// re-encoded.
class DrawVideoService {
  static List<DrawVideoModel> videos = [];

  static Directory? _directory;
  static bool _isPreloading = false;
  static final Dio _dio = Dio();

  /// The listing, then each video not on the device yet, one at a time and
  /// smallest first, so the most are ready soonest. Safe to call again: it
  /// skips what's downloaded, and does nothing while it's still running.
  static Future<void> preload() async {
    if (_isPreloading) return;
    _isPreloading = true;

    try {
      await getAllDrawVideoListing();
      if (videos.isEmpty) return;

      final Directory directory = await _videoDirectory();
      await _deleteOldVideos(directory);

      final List<DrawVideoModel> queue = [...videos]
        ..sort((a, b) => a.fileSize.compareTo(b.fileSize));
      for (final DrawVideoModel video in queue) {
        await _download(video, directory);
      }
    } catch (e) {
      printLog('Draw videos preload stopped: $e');
    } finally {
      _isPreloading = false;
    }
  }

  static Future<void> getAllDrawVideoListing() async {
    await ApiService.api.getAllDrawVideoListing(
      onSuccess: (response) {
        videos = List.from(
          response.data['videos'],
        ).map((element) => DrawVideoModel.fromJson(element)).toList();
      },
    );
  }

  /// [video]'s downloaded file; null until it's fully downloaded.
  static Future<File?> cachedFile(DrawVideoModel video) async {
    final String? fileName = video.fileName;
    if (fileName == null) return null;

    final File file = File('${(await _videoDirectory()).path}/$fileName');
    return await file.exists() ? file : null;
  }

  /// The video for a draw of [product] whose best prize was grade [gradeId]:
  /// one of that grade's `grade_videos` (at random if it has more than one);
  /// null if it has none.
  static Future<DrawVideoModel?> videoForGrade(
    MainProductModel product,
    int? gradeId,
  ) async {
    final List<int> videoIds = product.gradeVideos
        .where((element) => element.gradeId == gradeId)
        .expand((element) => element.videoIds)
        .toList();
    if (videoIds.isEmpty) return null;

    // the preload may not have fetched the listing yet
    if (videos.isEmpty) await getAllDrawVideoListing();

    final List<DrawVideoModel> found = videos
        .where((element) => videoIds.contains(element.id))
        .toList();
    if (found.isEmpty) return null;

    return found[math.Random().nextInt(found.length)];
  }

  static Future<Directory> _videoDirectory() async {
    return _directory ??= await Directory(
      '${(await getApplicationCacheDirectory()).path}/draw_videos',
    ).create(recursive: true);
  }

  static Future<void> _download(
    DrawVideoModel video,
    Directory directory,
  ) async {
    final String? url = video.file;
    final String? fileName = video.fileName;
    if (url == null || fileName == null) return;

    final File file = File('${directory.path}/$fileName');
    if (await file.exists()) return;

    // into a .part file first, so a cut-off download is never taken for a
    // whole one
    final File part = File('${file.path}.part');
    try {
      await _dio.download(
        url,
        part.path,
        // the file's own bytes: no gzip or other compression on the way
        options: Options(headers: {'accept-encoding': 'identity'}),
      );

      // the same size as the server's file, or it's not the original
      final int size = await part.length();
      if (video.fileSize > 0 && size != video.fileSize) {
        throw 'got $size bytes, expected ${video.fileSize}';
      }

      await part.rename(file.path);
    } catch (e) {
      printLog('Draw video ${video.id} not downloaded: $e');
      if (await part.exists()) await part.delete();
    }
  }

  /// Deletes what the listing no longer has (a replaced video, or a .part
  /// left by a cut-off download).
  static Future<void> _deleteOldVideos(Directory directory) async {
    final Set<String?> keep = {
      for (final DrawVideoModel video in videos) video.fileName,
    };

    await for (final FileSystemEntity entity in directory.list()) {
      if (!keep.contains(entity.uri.pathSegments.last)) {
        await entity.delete();
      }
    }
  }
}
