// Project imports:
import "package:getithk/services/http_services/http_client_custom.dart";
import "../imports.dart";

class Api {
  String? apiUrl;
  Api({required String this.apiUrl});

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

  Future<void> getPhoneCode({
    Function(ApiResponseModel)? onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpGet(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kPhoneCodes,
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
    await HttpClientCustom.httpPost(
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

  Future<void> resetPassword({
    required String password,
    required String currentPassword,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kResetPassword,
      params: {"current_password": currentPassword, "password": password},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  Future<void> sendOtp({
    required ContactType type,
    String? email,
    String? phoneCode,
    String? phoneNo,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
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

  Future<void> getBanners({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kBanner,
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

  Future<void> getPageBanners({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kPageBanner,
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

  Future<void> getProductCategories({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kProductCategoryListing,
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

  Future<void> getTnc({
    required TncType type,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kTNC,
      params: {"type": type.value},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  Future<void> getProductMainProductListing({
    required int page,
    required int perPage,
    required int productCategoryId,
    required int drawAmountType,
    required ProductSort sort,
    List<int> tags = const [],
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kProductMainProductListing,
      params: {
        "page": page,
        "per_page": perPage,
        "product_category_id": productCategoryId,
        "draw_amount_type": drawAmountType,
        "sort": sort.value,
        if (tags.isNotEmpty) "tags": tags,
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

  Future<void> getSubProductListing({
    required int mainProductId,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kSubMainProductListing,
      params: {"main_product_id": mainProductId},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  Future<void> getProductTagListing({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kProductTagListing,
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

  Future<void> getWalletBalance({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kWalletBalance,
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

  // invite-friends rewards (needs the token): data.successful_invites,
  // data.claimable_point, data.tiers ...
  Future<void> getInvitePointListing({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kPlayerInvitePointListing,
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

  // top-up packages: data = [{id, amount, rate, bonus_amount, credited_amount}]
  Future<void> getTopupBonusListing({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kTopupBonusListing,
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

  // payment methods (GET): data = [{gateway, name, icon}]
  Future<void> getPaymentMethods({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpGet(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kPaymentMethod,
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
