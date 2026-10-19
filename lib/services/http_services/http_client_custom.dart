// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../imports.dart';
import 'http_logger_custom.dart';
import 'http_service_custom.dart';

class HttpClientCustom {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: "application/json; charset=UTF-8",
      responseType: ResponseType.json,
    ),
  )..interceptors.add(HttpLoggerCustom());

  /// The app's current language as the API expects it: the full locale tag,
  /// "zh_TW" (the default), "en" or "ms" — not just the language code "zh".
  static String get _language => NavigationService.context.locale.toString();

  /// Headers sent with every request. The player's token goes with every one
  /// while they're logged in (there's a token), not only the calls that need
  /// it, so the public ones (products, banners, …) are made as them too.
  static Map<String, String> _headers(String? token) => {
    "Accept": "application/json",
    "Accept-Language": _language,
    "Accept-Timezone": kApiTimezone,
    if (_hasToken(token)) "Authorization": "Bearer $token",
  };

  static bool _hasToken(String? token) => token != null && token.isNotEmpty;

  /// Get method
  static Future<void> httpGet({
    required String? apiUrl,
    required String? endPoint,
    Map<String, dynamic>? params,
    required Function(ApiResponseModel) onSuccess,
    String? customUrl,
    bool withBearer = false,
    String? tempToken,
    bool isRethrowRequired = false,
    Function(String)? onError,
    bool showLoader = false,
  }) async {
    if (showLoader) Loader.show();

    try {
      String? token = tempToken ?? await ApiService.getApiToken();
      final String url = customUrl ?? "$apiUrl$endPoint";

      final queryParams = <String, dynamic>{
        "language": _language,
        "timezone": kApiTimezone,
        if (params != null) ...params,
      };

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: _headers(token),
          validateStatus: (status) {
            return true;
          },
        ),
      );

      HttpServiceCustom.responseHandler(
        response: response,
        onSuccess: onSuccess,
        onError: onError,
        hideLoader: showLoader,
        // sent with the token: a 401 means it's expired, whichever call
        withBearer: withBearer || _hasToken(token),
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.error(
          e.message ??
              NavigationService.context.tr(AppStrings.somethingWentWrong),
        );
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.error("$e");
    }
  }

  /// Post method
  static Future<void> httpPost({
    required String? apiUrl,
    required String? endPoint,
    required Map<String, dynamic> params,
    required Function(ApiResponseModel) onSuccess,
    String? customUrl,
    bool withBearer = false,
    String? tempToken,
    bool isRethrowRequired = false,
    Function(dynamic)? onEmpty,
    Function(String)? onError,
    bool showLoader = false,
  }) async {
    if (showLoader) Loader.show();

    try {
      String? token = tempToken ?? await ApiService.getApiToken();
      final String url = customUrl ?? "$apiUrl$endPoint";

      params["language"] = _language;
      params["timezone"] = kApiTimezone;

      final response = await _dio.post(
        url,
        data: params,
        options: Options(
          headers: _headers(token),
          validateStatus: (status) {
            return true;
          },
        ),
      );

      HttpServiceCustom.responseHandler(
        response: response,
        onSuccess: onSuccess,
        onError: onError,
        hideLoader: showLoader,
        // sent with the token: a 401 means it's expired, whichever call
        withBearer: withBearer || _hasToken(token),
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.error(
          e.message ??
              NavigationService.context.tr(AppStrings.somethingWentWrong),
        );
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.error("$e");
    }
  }

  /// Multipart POST method
  static Future<void> multipartPost({
    required String? apiUrl,
    required String? endPoint,
    required Function(ApiResponseModel) onSuccess,
    Map<String, dynamic>? params,
    Map<String, List<File>?>? files,
    String? customUrl,
    bool withBearer = false,
    String? tempToken,
    bool isRethrowRequired = false,
    Function(dynamic)? onEmpty,
    Function(String)? onError,
    bool showLoader = false,
  }) async {
    if (showLoader) Loader.show();

    try {
      String? token = tempToken ?? await ApiService.getApiToken();
      final String url = customUrl ?? "$apiUrl$endPoint";

      final Map<String, dynamic> formMap = {
        "language": _language,
        "timezone": kApiTimezone,
        ...?params,
      };

      final formData = FormData.fromMap(formMap);

      if (files != null) {
        for (var entry in files.entries) {
          final key = entry.key;
          final fileList = entry.value;
          if (fileList != null) {
            for (int i = 0; i < fileList.length; i++) {
              final file = fileList[i];
              final filePath = file.path;

              if (filePath.startsWith('http://') ||
                  filePath.startsWith('https://')) {
                final response = await _dio.get<List<int>>(
                  filePath,
                  options: Options(responseType: ResponseType.bytes),
                );
                final bytes = response.data!;
                final fileName =
                    "${Uri.parse(filePath).pathSegments.last}_${DateTime.now().microsecondsSinceEpoch}";
                formData.files.add(
                  MapEntry(
                    "$key[$i]",
                    MultipartFile.fromBytes(bytes, filename: fileName),
                  ),
                );
              } else {
                formData.files.add(
                  MapEntry(
                    "$key[$i]",
                    await MultipartFile.fromFile(
                      filePath,
                      filename:
                          "${filePath}_${DateTime.now().microsecondsSinceEpoch}",
                    ),
                  ),
                );
              }
            }
          }
        }
      }

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: _headers(token),
          validateStatus: (status) {
            return true;
          },
        ),
      );

      HttpServiceCustom.responseHandler(
        response: response,
        onSuccess: onSuccess,
        onError: onError,
        hideLoader: showLoader,
        // sent with the token: a 401 means it's expired, whichever call
        withBearer: withBearer || _hasToken(token),
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.error(
          e.message ?? NavigationService.context.tr(AppStrings.uploadFailed),
        );
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.error("$e");
    }
  }
}
