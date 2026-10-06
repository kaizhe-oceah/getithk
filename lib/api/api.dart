// Project imports:
import "package:getithk/services/http_services/http_client_custom.dart";
import "../imports.dart";
import "../services/notification_service.dart";

class Api {
  String? apiUrl;
  Api({required String this.apiUrl});

  // login
  Future<void> login({
    required String phoneNo,
    String? countryCode,
    required String password,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    final deviceParams = await getDeviceInfoParams();
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kLogin,
      params: {
        "phone_no": phoneNo,
        "country_code": countryCode,
        "password": password,
        "fcm_token": await NotificationService.getToken(),
        ...deviceParams,
      },
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  // logout
  Future<void> logout({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kLogout,
      withBearer: true,
      params: {"fcm_token": await NotificationService.getToken()},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  // register
  Future<void> register({
    required String name,
    String? countryCode,
    required String phoneNo,
    required String email,
    required String password,
    required String passwordConfirmation,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kRegister,
      params: {
        "name": name,
        "country_code": countryCode,
        "phone_no": phoneNo,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
      },
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  // customer profile
  Future<void> getCustomerProfile({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kCustomerProfile,
      withBearer: true,
      params: {},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }
}
