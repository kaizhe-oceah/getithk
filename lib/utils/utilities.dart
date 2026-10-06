// Dart imports:
import "dart:developer";
import "dart:math" as math;

// Package imports:
import "package:calendar_date_picker2/calendar_date_picker2.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter_image_compress/flutter_image_compress.dart";
import "package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart";
import "package:image_picker/image_picker.dart";
import "package:open_file/open_file.dart";
import "package:path_provider/path_provider.dart";
import "package:video_compress/video_compress.dart";
import "package:video_player/video_player.dart";

// Project imports:
import '../imports.dart';

extension StringCasingExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

void printLog(dynamic message, {String name = ""}) {
  if (kDebugMode) {
    log("$message", name: name);
    // Also route to the platform console (Xcode / logcat / `flutter logs`)
    // so logs are visible when testing on a physical device.
    debugPrint(name.isEmpty ? "$message" : "[$name] $message");
  }
}

bool isStaging() {
  if (GlobalConfigs().get("environment") == Environment.staging.name) {
    return true;
  }
  return false;
}

Color colorAuto(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.light
      ? Colors.black
      : Colors.white;
}

Brightness colorBrightnessAuto(Color background, {bool isIos = false}) {
  if (isIos) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.light
        ? Brightness.light
        : Brightness.dark;
  }

  return ThemeData.estimateBrightnessForColor(background) == Brightness.light
      ? Brightness.dark
      : Brightness.light;
}

bool isDataEmpty(dynamic data) {
  if (data == null || data == "null" || data == "") return true;
  return false;
}

String getPrice(
  String? price, {
  bool isDecimal = true,
  bool isCurrency = true,
  bool is4Decimal = false,
  String defaultPrice = "0.00",
  String? symbol,
  bool symbolLeft = true,
  bool removeComma = false,
  bool isSpacing = true,
  bool showFree = false,
}) {
  if (isDataEmpty(price)) {
    return isCurrency
        ? '${GlobalConfigs().get('currency')} $defaultPrice'
        : defaultPrice;
  }

  final priceFormatter = NumberFormat(
    is4Decimal ? "#,##0.0000" : "#,##0.00",
    "en_US",
  );

  // Guard against non-numeric strings so `format(null)` never throws.
  final numericPrice = double.tryParse(price!.replaceAll(",", "")) ?? 0;
  price = priceFormatter.format(numericPrice);

  if (!isDecimal) {
    final priceFormatter2 = NumberFormat("#,##0", "en_US");
    price = priceFormatter2.format(
      double.parse(price.replaceAll(",", "")).toInt(),
    );
  }

  if (removeComma) {
    price = price.replaceAll(",", "");
  }

  if (showFree) {
    if (double.parse(price.replaceAll(",", "")) == 0) {
      return price = "FREE";
    }
  }

  return isCurrency
      ? (symbolLeft
            ? '${symbol ?? GlobalConfigs().get('currency')}${isSpacing ? " " : ""}$price'
            : '$price${isSpacing ? " " : ""}${symbol ?? GlobalConfigs().get('currency')}')
      : price;
}

Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll("#", "");
  return Color(int.parse("FF$hexCode", radix: 16));
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

double roundFloorNumber(double value, int places) {
  num val = math.pow(10.0, places);
  return ((value * val).floor().toDouble() / val);
}

String calculateDistance(
  dynamic lat1,
  lon1,
  lat2,
  lon2, {
  String suffix = "km",
}) {
  var p = 0.017453292519943295;
  var c = math.cos;
  var a =
      0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return "${(12742 * math.asin(math.sqrt(a))).toStringAsFixed(2)}$suffix";
}

Future<void> getMapDirection({String? name, String? address}) async {
  // double zoomInit = 16.0;
  try {
    final url =
        ('https://maps.google.com/maps?q=${Uri.encodeQueryComponent("$name $address")}'
        // "https://www.google.com/maps/@$lat,$long,${zoomInit}z?entry=ttu"
        );
    if (!await launchUrl(Uri.parse(url))) {
      throw 'cannot not launch url $url';
    }
    launchUrl(Uri.parse(url));
  } catch (e) {
    printLog(e.toString());
  }
}

Size textSize({
  required BuildContext context,
  required String text,
  required TextStyle textStyle,
  int maxLines = 1,
}) {
  assert(textStyle.fontSize != null);
  return (TextPainter(
    text: TextSpan(
      text: text,
      style: textStyle.copyWith(
        fontSize: MediaQuery.textScalerOf(context).scale(textStyle.fontSize!),
      ),
    ),
    maxLines: maxLines,
    textDirection: Directionality.of(context),
  )..layout()).size;
}

String getRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  math.Random _rnd = math.Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ),
  );
}

Future<void> launchLink({required String url}) async {
  try {
    await launchUrl(Uri.parse(url));
  } catch (e) {
    ToastHelper.showToast("Could not launch $url");
  }
}

Color getRandomColor() {
  return Color.fromRGBO(
    math.Random().nextInt(255),
    math.Random().nextInt(255),
    math.Random().nextInt(255),
    1,
  );
}

String getTimeAmPm({required String? time}) {
  DateTime dateTime = DateFormat('HH:mm:ss').parse(time!).toLocal();
  return DateFormat('hh:mm a').format(dateTime);
}

String ordinal(int number) {
  if (!(number >= 1 && number <= 100)) {
    //here you change the range
    throw Exception('Invalid number');
  }

  if (number >= 11 && number <= 13) {
    return 'th';
  }

  switch (number % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}


String dateFormat({String? pattern = "dd MMM yyyy", String? date}) {
  if (date == null) {
    return "-";
  }

  try {
    DateTime dateTime = DateTime.parse(date).toLocal();
    return DateFormat(pattern, 'en_US').format(dateTime);
  } catch (e) {
    return "-";
  }
}

Future<List<DateTime?>?> showCalendarDatePicker({
  CalendarDatePicker2Type? calendarType = CalendarDatePicker2Type.range,
  List<DateTime?>? value,
  DateTime? lastDate,
  DateTime? currentDate,
  DateTime? firstDate,
  Widget? bottomWidget,
}) async {
  return await showCalendarDatePicker2Dialog(
    context: NavigationService.context,
    value: value ?? const [],
    config: CalendarDatePicker2WithActionButtonsConfig(
      lastDate: lastDate,
      currentDate: currentDate,
      firstDate: firstDate,
      lastMonthIcon: Icon(
        Icons.keyboard_arrow_left,
        color: AppColors.blackColor,
        size: 16.r,
      ),
      nextMonthIcon: Icon(
        Icons.keyboard_arrow_right_rounded,
        color: AppColors.blackColor,
        size: 16.r,
      ),
      calendarType: calendarType,
      okButtonTextStyle: NavigationService.context.text.bodyMedium!.copyWith(
        color: AppColors.blackColor,
        fontWeight: FontWeight.w500,
      ),
      cancelButtonTextStyle: NavigationService.context.text.bodyMedium!
          .copyWith(color: AppColors.blackColor, fontWeight: FontWeight.w500),
      selectedDayTextStyle: NavigationService.context.text.bodyMedium!.copyWith(
        color: AppColors.whiteColor,
      ),
      selectedDayHighlightColor: Theme.of(
        NavigationService.context,
      ).colorScheme.primary,
      dayTextStyle: NavigationService.context.text.bodyMedium!.copyWith(
        color: AppColors.blackColor,
      ),
      yearTextStyle: NavigationService.context.text.bodyMedium!.copyWith(
        color: AppColors.blackColor,
      ),
      todayTextStyle: NavigationService.context.text.bodyMedium!.copyWith(
        color: AppColors.blackColor,
      ),
      controlsTextStyle: NavigationService.context.text.bodyMedium!.copyWith(
        color: AppColors.blackColor,
      ),
      weekdayLabelTextStyle: NavigationService.context.text.bodyMedium!
          .copyWith(color: AppColors.blackColor),
      disabledDayTextStyle: NavigationService.context.text.bodyMedium!.copyWith(
        color: AppColors.greyColor,
      ),
      selectedYearTextStyle: NavigationService.context.text.bodyMedium!
          .copyWith(color: AppColors.whiteColor),
      selectedRangeDayTextStyle: NavigationService.context.text.bodyMedium!
          .copyWith(color: AppColors.blackColor),
    ),
    dialogSize: Size(0.85.sw, 0.3.sh),
    borderRadius: BorderRadius.circular(15).r,
    dialogBackgroundColor: AppColors.whiteColor,
    builder: bottomWidget != null
        ? (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [child ?? const SizedBox.shrink(), bottomWidget],
            );
          }
        : null,
  );
}

String ensureHttps(String url) {
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    return "https://$url";
  }
  return url;
}

Future<void> launchGoogleMaps({
  required double latitude,
  required double longitude,
}) async {
  final Uri url = Uri.parse(
    'https://www.google.com/maps?q=$latitude,$longitude',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

/// Resolves a plugin-returned file path to the variant that actually exists.
///
/// Sources with spaces in the filename (e.g. iPhone screen recordings,
/// "ScreenRecording 07-09-2026 …") can make the thumbnail plugin return a
/// percent-encoded path (`%20`) while the file is written at the literal
/// path — reading the encoded one throws PathNotFoundException.
String resolveExistingPath(String path) {
  if (File(path).existsSync()) return path;
  try {
    final decoded = Uri.decodeFull(path);
    if (File(decoded).existsSync()) return decoded;
  } catch (_) {}
  return path;
}

/// Milliseconds into [source] at half its duration. Falls back to 0 (the
/// first frame) when the duration can't be read.
Future<int> _videoHalfDurationMs(String source) async {
  printLog("***** _videoHalfDurationMs");

  VideoPlayerController? controller;
  try {
    controller = isNetworkUrl(source)
        ? VideoPlayerController.networkUrl(Uri.parse(source))
        : VideoPlayerController.file(File(source));
    await controller.initialize();
    return controller.value.duration.inMilliseconds ~/ 2;
  } catch (e) {
    printLog("Error reading video duration: $e");
    return 0;
  } finally {
    await controller?.dispose();
  }
}

Future<String?> getThumbnail(String source) async {
  printLog("source => $source");
  try {
    // Generate the thumbnail from the middle of the video — the first frame
    // is often black / not representative.
    final thumbnailPath = await FlutterVideoThumbnailPlus.thumbnailFile(
      video: source,
      thumbnailPath: (await getTemporaryDirectory()).path,
      quality: 75,
      timeMs: await _videoHalfDurationMs(source),
    );

    printLog("thumbnailPath => $thumbnailPath");

    if (thumbnailPath == null || thumbnailPath.isEmpty) return null;
    return resolveExistingPath(thumbnailPath);
  } catch (e) {
    printLog("Error generating thumbnail: $e");
    return null;
  }
}

/// Compress an image file so that it is under [maxBytes] (default 4 MB).
/// Returns the original file if it's already small enough or compression fails.
Future<File> compressImageIfNeeded(
  File file, {
  int maxBytes = 4 * 1024 * 1024,
}) async {
  try {
    if (await file.length() <= maxBytes) return file;

    final dir = await getTemporaryDirectory();
    int quality = 90;

    for (int i = 0; i < 5; i++) {
      final target =
          "${dir.path}/compressed_${DateTime.now().microsecondsSinceEpoch}_$i.jpg";
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        target,
        quality: quality,
        minWidth: 1920,
        minHeight: 1920,
      );
      if (result == null) break;
      final compressed = File(result.path);
      if (await compressed.length() <= maxBytes) return compressed;
      quality -= 15;
      if (quality < 20) return compressed;
    }
  } catch (e) {
    printLog("compressImageIfNeeded error: $e");
  }
  return file;
}

/// **1. Take a photo from the camera**
Future<File?> takePhoto() async {
  final ImagePicker _picker = ImagePicker();
  try {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      return compressImageIfNeeded(File(photo.path));
    }
  } catch (e) {
    ToastHelper.showToast("Error taking photo: $e");
  }
  return null;
}

/// **2. Record a video using the camera**
Future<File?> takeVideo() async {
  final ImagePicker _picker = ImagePicker();
  try {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      // ToastHelper.showToast("Video recorded successfully!");
      return File(video.path);
    }
  } catch (e) {
    ToastHelper.showToast("Error recording video: $e");
  }
  return null;
}

/// Pick a video from the gallery
Future<File?> uploadVideo() async {
  final ImagePicker _picker = ImagePicker();
  try {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      return File(video.path);
    }
  } catch (e) {
    ToastHelper.showToast("Error picking video: $e");
  }
  return null;
}

/// Transcode any picked/recorded video to a real `.mp4` file and compress it
/// down to [maxBytes] (default 50 MB).
///
/// iOS records videos as `.mov` (QuickTime). Even when the server accepts
/// QuickTime, the upload layer can mangle the extension, so we normalise
/// everything to mp4 to keep the API happy.
///
/// Single-pass: the quality preset is chosen up-front from the bitrate budget
/// (target size ÷ duration) — no trial-and-error ladder. Returns the original
/// file when it already fits, or if compression fails.
///
/// [onProgress] is called with the compression progress (0–100).
Future<File> convertVideoToMp4(
  File input, {
  int maxBytes = 50 * 1024 * 1024,
  void Function(double percent)? onProgress,
}) async {
  // Fast path: already an mp4 within the size cap → nothing to do.
  if (input.path.toLowerCase().endsWith('.mp4') &&
      input.lengthSync() <= maxBytes) {
    onProgress?.call(100);
    return input;
  }

  // Pick the quality preset from the bitrate budget. Approximate output
  // bitrates: 1080p ≈ 8 Mbps, 720p ≈ 4 Mbps, medium ≈ 2 Mbps, low ≈ 1 Mbps.
  var quality = VideoQuality.Res1920x1080Quality;
  try {
    final mediaInfo = await VideoCompress.getMediaInfo(input.path);
    final durationMs = mediaInfo.duration;
    if (durationMs != null && durationMs > 0) {
      final budgetKbps = (maxBytes * 8 / (durationMs / 1000)) / 1000;
      if (budgetKbps >= 8000) {
        quality = VideoQuality.Res1920x1080Quality;
      } else if (budgetKbps >= 4000) {
        quality = VideoQuality.Res1280x720Quality;
      } else if (budgetKbps >= 2000) {
        quality = VideoQuality.MediumQuality;
      } else if (budgetKbps >= 1000) {
        quality = VideoQuality.LowQuality;
      } else {
        quality = VideoQuality.Res640x480Quality;
      }
    }
  } catch (e) {
    printLog("getMediaInfo failed: $e", name: "convertVideoToMp4");
  }

  Subscription? progressSub;
  if (onProgress != null) {
    progressSub = VideoCompress.compressProgress$.subscribe(
      (progress) => onProgress(progress.clamp(0, 100)),
    );
  }

  try {
    final info = await VideoCompress.compressVideo(
      input.path,
      quality: quality,
      deleteOrigin: false,
      includeAudio: true,
    );
    final out = info?.file;
    if (out != null && out.existsSync()) return out;
  } catch (e) {
    printLog("Video conversion failed: $e", name: "convertVideoToMp4");
  } finally {
    progressSub?.unsubscribe();
  }
  return input;
}

/// **3. Pick a photo from the gallery**
Future<File?> uploadPhoto() async {
  final ImagePicker _picker = ImagePicker();
  try {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      return compressImageIfNeeded(File(photo.path));
    }
  } catch (e) {
    ToastHelper.showToast("Error picking photo: $e");
  }
  return null;
}

/// Pick multiple photos from the gallery. [limit] caps the selection where the
/// platform supports it (iOS 14+/Android 13+). Returns compressed image files.
Future<List<File>> uploadPhotos({int? limit}) async {
  final ImagePicker _picker = ImagePicker();
  try {
    // image_picker handles limit == 1 (single pick) and rejects limit < 1.
    final photos = await _picker.pickMultiImage(limit: limit);
    final files = <File>[];
    for (final photo in photos) {
      files.add(await compressImageIfNeeded(File(photo.path)));
    }
    return files;
  } catch (e) {
    ToastHelper.showToast("Error picking photos: $e");
  }
  return [];
}

/// **4. Upload any file from storage**
Future<File?> uploadFromFiles() async {
  try {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
    );

    if (result != null && result.files.single.path != null) {
      // ToastHelper.showToast("File selected successfully!");
      return File(result.files.single.path!);
    }
  } catch (e) {
    ToastHelper.showToast("Error selecting file: $e");
  }
  return null;
}

String formatNumToCurrency(double price, {bool hasCurrency = true}) {
  String value = NumberFormat("#,##0.00", "en_US").format(price);

  String currency = "RM";

  if (hasCurrency) {
    value = '$currency $value';
  }

  return value;
}

Future<File> uint8ListToFile(Uint8List uint8List, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(uint8List);
  return file;
}

Future<Uint8List> fileToUint8List(File file) async {
  return await file.readAsBytes();
}

Future<void> saveFileCrossPlatform({
  required String base64String,
  required String fileName,
}) async {
  try {
    // final String baseName = fileName;
    // final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // final String fileNameWithTimestamp = baseName.replaceFirstMapped(
    //   RegExp(r'\.(\w+)$'),
    //   (match) => '_$timestamp.${match[1]}',
    // );

    Directory? directory;

    if (Platform.isAndroid) {
      // AndroidDeviceInfo android = await DeviceInfoPlugin().androidInfo;
      // final status = android.version.sdkInt < 33
      //     ? await Permission.storage.request()
      //     : await Permission.manageExternalStorage.request();
      // if (!status.isGranted) {
      //   throw Exception("Storage permission not granted");
      // }

      directory = await getExternalStorageDirectory(); // App-specific
      if (directory == null) {
        throw Exception("Could not get external storage directory");
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }

    // Decode and write file
    final bytes = base64Decode(base64String);
    final filePath = "${directory.path}/$fileName";
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    log("File saved: $filePath");

    // 🔓 Open the file
    final result = await OpenFile.open(filePath);
    log("Open result: ${result.message}");
    if (result.message != "done") {
      ToastHelper.showToast(result.message);
    }
  } catch (e, _) {
    log("Error saving or opening file: $e");
  }
}

Future<void> handleWebviewConsoleMessage({
  required String consoleMessage,
}) async {
  printLog("consoleMessage : $consoleMessage");

  if (consoleMessage.contains("account_page")) {
    // AppNavigator.push(NavigationService.context, const MainAccountPage());
  } else if (consoleMessage.contains("notification_clicked")) {
    // AppNavigator.push(NavigationService.context, const MainNotificationPage());
  } else if (consoleMessage.contains("filename")) {
    printLog("consoleMessage contain filename");
    ApiResponseModel response = ApiResponseModel.fromJson(
      jsonDecode(consoleMessage),
    );
    await saveFileCrossPlatform(
      base64String: response.mapResponse["file"],
      fileName: response.mapResponse["filename"],
    );
  }
}

bool isExternalAppUrl(Uri uri, String url) {
  return uri.scheme == 'whatsapp' ||
      url.contains('wa.me') ||
      url.contains('api.whatsapp.com') ||
      uri.scheme == 'mailto' ||
      uri.scheme == 'tel' ||
      uri.scheme == 'sms' ||
      uri.scheme == 'intent' ||
      uri.scheme == 'tg' ||
      url.contains('t.me') ||
      uri.scheme == 'fb' ||
      uri.scheme == 'twitter' ||
      url.contains('twitter.com') ||
      uri.scheme == 'instagram' ||
      url.contains('instagram.com') ||
      url.contains('play.google.com') ||
      url.contains('apps.apple.com') ||
      url.contains('maps.app.goo.gl') ||
      uri.scheme == 'geo' ||
      uri.scheme == 'market' ||
      url.contains('linkedin.com') ||
      url.contains('zoom.us') ||
      url.contains('meet.google.com') ||
      url.contains('skype:') ||
      uri.scheme == 'viber';
}

String formatTimeSlot(String? dateString) {
  if (dateString == null || dateString.isEmpty) return "";

  final date = DateTime.parse(dateString);
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

  // If hour is 10, 11, or 12 → show 2 digits
  final format = (hour >= 10) ? DateFormat("hh:mm a") : DateFormat("h:mm a");
  return format.format(date);
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

  printLog("uri: ${uri.toString()}");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

Future<void> openWhatsApp({required String phone, String? message}) async {
  final uri = Uri.parse(
    'https://wa.me/$phone${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
  );

  printLog("whatsapp uri: ${uri.toString()}");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch WhatsApp';
  }
}

String maskPhone(String phone) {
  if (phone.length <= 4) return phone;
  final visible = phone.substring(0, 3);
  final last = phone.substring(phone.length - 4);
  return '$visible****$last';
}
