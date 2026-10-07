// Package imports:
import "package:device_info_plus/device_info_plus.dart";
import "package:device_marketing_names/device_marketing_names.dart";
import "package:dio/dio.dart";
import "package:permission_handler/permission_handler.dart";

// Project imports:
import '../imports.dart';

// import "package:firebase_messaging/firebase_messaging.dart";

/// Copy
void copyToClipboard({String? message, required String contentToCopy}) {
  HapticFeedback.lightImpact();
  ToastHelper.showToast(
    message ?? NavigationService.context.tr(AppStrings.copied),
    icon: Iconsax.tick_circle,
    align: const Alignment(0, 0.85),
  );
  Clipboard.setData(ClipboardData(text: contentToCopy));
}

Future<String?> getDeviceInfoId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (kIsWeb) {
    WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
    return "${webInfo.vendor ?? '-'}|${webInfo.userAgent ?? '-'}|${webInfo.hardwareConcurrency}";
  } else if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor!;
  }

  return null;
}

Future<bool> requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}

String getResponseMessage(String message) {
  if (message.contains("_")) return NavigationService.context.tr(message);
  return message;
}

String formatNotificationTime(DateTime dateTime) {
  final now = DateTime.now().toLocal();
  final difference = now.difference(dateTime.toLocal());

  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? "min" : "mins"} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? "hour" : "hours"} ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
  } else {
    return DateFormat('MMM d, y').format(dateTime);
  }
}

bool isVideo(String filePath) {
  final mimeType = lookupMimeType(filePath);
  return mimeType != null && mimeType.startsWith("video/");
}

bool isNetworkUrl(String url) {
  return url.startsWith("http://") || url.startsWith("https://");
}

Future<MultipartFile?> videoMultipart(File? video, String fieldName) async {
  if (video == null) return null;
  final ext = video.path.contains('.') ? video.path.split('.').last : 'mp4';
  return MultipartFile.fromFile(video.path, filename: "$fieldName.$ext");
}

/// Builds the multipart part for a lone image field, named after the field so
/// the upload carries a real image extension and an `image/*` content type —
/// a server checking for a jpeg / png / webp won't accept the picker's own
/// cache path on its own.
///
/// Pass the result through a request's `params` rather than its `files` — Dio
/// emits a [MultipartFile] found in the map under the bare field name
/// (`identity_card_front`), where `files` would index it as
/// `identity_card_front[0]` and the server would see an array, not a file.
MultipartFile? imageMultipart(File? image, String fieldName) {
  if (image == null) return null;

  final rawExt = image.path.contains('.')
      ? image.path.split('.').last.toLowerCase()
      : '';
  // Anything the server won't accept is labelled jpeg — the picker hands back
  // JPEGs, having already transcoded HEIC on the way out.
  final ext = const {'jpeg', 'jpg', 'png', 'webp'}.contains(rawExt)
      ? rawExt
      : 'jpg';

  return MultipartFile.fromFileSync(
    image.path,
    filename: "$fieldName.$ext",
    contentType: DioMediaType('image', ext == 'jpg' ? 'jpeg' : ext),
  );
}

String getMonthAbbreviation(int month) {
  const monthMap = {
    1: "JAN",
    2: "FEB",
    3: "MAR",
    4: "APR",
    5: "MAY",
    6: "JUN",
    7: "JUL",
    8: "AUG",
    9: "SEP",
    10: "OCT",
    11: "NOV",
    12: "DEC",
  };

  return monthMap[month] ?? "-";
}

Future<Map<String, dynamic>> getDeviceInfoParams() async {
  final deviceInfo = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
  final deviceName = await DeviceMarketingNames().getSingleName();

  String platform = "android";
  String? deviceId;
  String? osVersion;

  if (kIsWeb) {
    platform = "web";
    final webInfo = await deviceInfo.webBrowserInfo;
    deviceId = "${webInfo.vendor ?? '-'}|${webInfo.userAgent ?? '-'}";
    osVersion = webInfo.platform;
  } else if (Platform.isAndroid) {
    platform = "android";
    final android = await deviceInfo.androidInfo;
    deviceId = android.id;
    osVersion =
        "Android ${android.version.release} (SDK ${android.version.sdkInt})";
  } else if (Platform.isIOS) {
    platform = "ios";
    final ios = await deviceInfo.iosInfo;
    deviceId = ios.identifierForVendor;
    osVersion = "${ios.systemName} ${ios.systemVersion}";
  }

  return {
    "platform": platform,
    "device_id": deviceId,
    "device_model": deviceName,
    "app_version": appVersion,
    "os_version": osVersion,
  };
}

Future<String> getAppVersionAndBuild() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String version = packageInfo.version; // e.g. "1.0.0"
  String buildNumber = packageInfo.buildNumber; // e.g. "1"

  return "$version ($buildNumber)";
}

void unfocusKeyboard() {
  if (FocusManager.instance.primaryFocus != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
