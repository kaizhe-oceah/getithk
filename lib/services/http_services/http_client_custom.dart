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

  /// Headers sent with every request.
  static Map<String, String> _headers({
    required bool withBearer,
    String? token,
  }) => {
    "Accept": "application/json",
    "Accept-Language": kApiLanguage,
    "Accept-Timezone": kApiTimezone,
    if (withBearer) "Authorization": "Bearer $token",
  };

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
        "language": NavigationService.context.locale.languageCode,
        if (params != null) ...params,
      };

      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: _headers(withBearer: withBearer, token: token),
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
        withBearer: withBearer,
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.showToast(
          e.message ??
              NavigationService.context.tr(AppStrings.somethingWentWrong),
        );
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.showToast("$e");
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

      params["language"] = NavigationService.context.locale.languageCode;

      final response = await _dio.post(
        url,
        data: params,
        options: Options(
          headers: _headers(withBearer: withBearer, token: token),
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
        withBearer: withBearer,
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.showToast(
          e.message ??
              NavigationService.context.tr(AppStrings.somethingWentWrong),
        );
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.showToast("$e");
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

      final Map<String, dynamic> formMap = {};

      if (params != null) {
        params["language"] = NavigationService.context.locale.languageCode;
        formMap.addAll(params);
      }

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
          headers: _headers(withBearer: withBearer, token: token),
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
        withBearer: withBearer,
      );
    } on DioException catch (e) {
      if (isRethrowRequired) {
        rethrow;
      } else {
        Loader.hide();
        ToastHelper.showToast(
          e.message ?? NavigationService.context.tr(AppStrings.uploadFailed),
        );
      }
    } catch (e) {
      Loader.hide();
      ToastHelper.showToast("$e");
    }
  }
}
