// Project imports:
import "package:getithk/services/http_services/http_client_custom.dart";
import "../imports.dart";

class Api {
  String? apiUrl;
  Api({required String this.apiUrl});

  // player login (JSON: as form-data this endpoint rejects `type` as "not an
  // integer"). [email] for ContactType.email; [phoneCode] (e.g. "+60") +
  // [phoneNo] for ContactType.phone. Password only.
  Future<void> login({
    required ContactType type,
    String? email,
    String? phoneCode,
    String? phoneNo,
    required String password,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kLogin,
      params: {
        "type": type.value,
        "email": ?email,
        "phone_code": ?phoneCode,
        "phone_no": ?phoneNo,
        "auth_method": AuthMethod.password.value,
        "password": password,
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

  // player logout: ends the token's session on the server. No error toast:
  // the app logs out locally whatever the server answers.
  Future<void> logout({
    Function(ApiResponseModel)? onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kLogout,
      withBearer: true,
      params: {},
      onSuccess: (response) => onSuccess?.call(response),
      onError: (error) => onError?.call(error),
    );
  }

  Future<void> register({
    required ContactType type,
    String? email,
    String? phoneCode,
    String? phoneNo,
    required AuthMethod authMethod,
    String? password,
    String? otp,
    String? referralCode,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.multipartPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kRegister,
      params: {
        "type": type.value,
        "email": ?email,
        "phone_code": ?phoneCode,
        "phone_no": ?phoneNo,
        "auth_method": authMethod.value,
        "password": ?password,
        "otp": ?otp,
        "referral_code": ?referralCode,
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

  // send otp (form-data)
  // [email] for ContactType.email; [phoneCode] (e.g. "+60") + [phoneNo] for
  // ContactType.phone.
  Future<void> sendOtp({
    required ContactType type,
    String? email,
    String? phoneCode,
    String? phoneNo,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.multipartPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kSendOtp,
      params: {
        "type": type.value,
        "email": ?email,
        "phone_code": ?phoneCode,
        "phone_no": ?phoneNo,
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

  // player profile: data.user + data.level
  Future<void> getProfile({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kProfile,
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
