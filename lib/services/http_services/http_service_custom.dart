// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../imports.dart';

class HttpServiceCustom {
  static BuildContext context = NavigationService.context;
  static bool _isLoggedOutDueToSession = false;

  static void catchErrorHandler({
    required dynamic error,
    Function(String)? onError,
    bool hideLoader = true,
  }) {
    if (hideLoader) Loader.hide();

    String errorMessage = context.tr(AppStrings.somethingWentWrong);

    if (error is SocketException) {
      errorMessage = context.tr(AppStrings.noInternetConnection);
    } else if (error is HttpException) {
      errorMessage = context.tr(AppStrings.httpError);
    } else if (error is FormatException) {
      errorMessage = error.message.toString();
    } else if (error is TimeoutException) {
      errorMessage = context.tr(AppStrings.requestTimedOut);
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = context.tr(AppStrings.requestTimedOut);
          break;
        case DioExceptionType.badResponse:
          errorMessage = _extractErrorMessage(error.response);
          break;
        case DioExceptionType.unknown:
          errorMessage = context.tr(AppStrings.unknownError);
          break;
        default:
          errorMessage = error.message ?? errorMessage;
      }
    }

    if (onError != null) {
      onError(errorMessage);
    } else {
      DialogHelper().showNormalDialog(
        title: context.tr(AppStrings.oops),
        description: errorMessage,
      );
    }
  }

  static void responseHandler({
    required Response response,
    required Function(ApiResponseModel) onSuccess,
    Function(String)? onError,
    bool hideLoader = true,
    bool withBearer = false,
  }) {
    if (hideLoader) Loader.hide();

    try {
      final responseModel = ApiResponseModel.fromJson(response.data);
      final errorMessage = responseModel.message ??
          context.tr(AppStrings.somethingWentWrong);

      switch (response.statusCode) {
        case 200:
        case 201:
        case 204:
          // `"status": false` is a failure even with a 2xx code
          if (responseModel.status == kFail) {
            _handleErrorResponse(errorMessage, onError);
          } else {
            onSuccess(responseModel);
          }
          break;
        case 401:
        case 403:
          // Only a signed-in request means the session expired. Without a
          // token (e.g. login) it's wrong credentials: show the message and
          // stay on the page.
          if (withBearer) {
            _handleSessionExpired();
          } else {
            _handleErrorResponse(errorMessage, onError);
          }
          break;
        default:
          _handleErrorResponse(errorMessage, onError);
      }
    } catch (e) {
      _handleErrorResponse(context.tr(AppStrings.somethingWentWrong), onError);
    }
  }

  static String _extractErrorMessage(Response? response) {
    if (response == null) return context.tr(AppStrings.somethingWentWrong);

    try {
      final rawMessage = response.data["message"];
      if (rawMessage is List) {
        return rawMessage.join(", ");
      } else if (rawMessage is String) {
        return rawMessage;
      }
    } catch (_) {}
    return context.tr(AppStrings.somethingWentWrong);
  }

  static void _handleErrorResponse(
      String errorMessage, Function(String)? onError) {
    if (onError != null) {
      onError(errorMessage);
    } else {
      DialogHelper().showNormalDialog(
        title: context.tr(AppStrings.oops),
        description: errorMessage,
      );
    }
  }

  static void _handleSessionExpired() {
    if (!_isLoggedOutDueToSession) {
      _isLoggedOutDueToSession = true;
      ToastHelper.showToast(context.tr(AppStrings.sessionExpired));
      NavigationService.context.read<AppController>().logout();
    }
  }

  static void resetSessionFlag() {
    _isLoggedOutDueToSession = false;
  }
}
