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

  // shipping address lisiting
  Future<void> getShippingAddress({
    required int page,
    required int perPage,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerShippingAddress,
      params: {"page": page, "per_page": perPage},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  // shipping country listing
  Future<void> getShippingCountryList({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerShippingCountryList,
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

  // shipping address form, the fields for a country
  Future<void> getShippingAddressForm({
    required int shippingCountryId,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerShippingAddressForm,
      params: {"shipping_country_id": shippingCountryId},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  // create shipping address; values: the form's fields by key
  Future<void> createShippingAddress({
    required int shippingCountryId,
    required bool isDefault,
    required Map<String, dynamic> values,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerCreateShippingAddress,
      params: {
        "shipping_country_id": shippingCountryId,
        "is_default": isDefault,
        "values": values,
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

  // update shipping address; shipping_country_id and values: the form as
  // create takes it, so no field is lost
  Future<void> updateShippingAddress({
    required int shippingAddressId,
    required String name,
    String? phoneCode,
    String? phoneNo,
    required String address,
    required bool isDefault,
    required int shippingCountryId,
    required Map<String, dynamic> values,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerUpdateShippingAddress,
      params: {
        "shipping_address_id": shippingAddressId,
        "name": name,
        "phone_code": ?phoneCode,
        "phone_no": ?phoneNo,
        "address": address,
        "is_default": isDefault,
        "shipping_country_id": shippingCountryId,
        "values": values,
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

  // shipping setting: the fee and the free-shipping threshold
  Future<void> getShippingSetting({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerShippingSetting,
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

  // create shipping: ship [userStockIds] to the address
  Future<void> createShipping({
    required String name,
    required String phoneCode,
    required String phoneNo,
    required String address,
    required List<int> userStockIds,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerCreateShipping,
      params: {
        "name": name,
        "phone_code": phoneCode,
        "phone_no": phoneNo,
        "address": address,
        // a JSON string, "[50007,50016]", as the API takes it
        "user_stock_ids": jsonEncode(userStockIds),
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

  // shipping listing: the player's shipments, a page at a time; [status]
  // null: all of them
  Future<void> getShippingListing({
    required int page,
    required int perPage,
    ShippingStatus? status,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerShippingListing,
      params: {"page": page, "per_page": perPage, "status": ?status?.value},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  // top up by gateway (form data): data.redirect_url is the gateway's page
  // to pay on; it sends the player back to kTopUpReturnPath
  Future<void> topUpByGateway({
    required double topupAmount,
    required String gateway,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.multipartPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kTopUpByGateway,
      params: {
        // 100, not "100.0"
        "topup_amount": topupAmount % 1 == 0
            ? topupAmount.toInt()
            : topupAmount,
        "fe_redirect_url": kTopUpReturnPath,
        "gateway": gateway,
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

  // sell stock: exchange [stockIds] for PTS
  Future<void> sellStock({
    required List<int> stockIds,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerSellStock,
      // a JSON string, "[9244,9257]", as the API takes it
      params: {"stock_ids": jsonEncode(stockIds)},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  // delete shipping address
  Future<void> deleteShippingAddress({
    required int shippingAddressId,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      withBearer: true,
      endPoint: kPlayerDeleteShippingAddress,
      params: {"shipping_address_id": shippingAddressId},
      onSuccess: (response) => onSuccess(response),
      onError: (error) {
        ToastHelper.showToast(error);
        if (onError != null) {
          onError(error);
        }
      },
    );
  }

  Future<void> getAllDrawVideoListing({
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kAllDrawVideoListing,
      params: {},
      onSuccess: (response) => onSuccess(response),
      onError: (error) => onError?.call(error),
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

  // the player's backpack cards (needs the token), [status] 1, 4 or 5;
  // no [productCategoryId]: every category
  Future<void> getPlayerStockListing({
    required int page,
    required int perPage,
    required StockStatus status,
    int? productCategoryId,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kPlayerStockListing,
      withBearer: true,
      params: {
        "page": page,
        "per_page": perPage,
        "status": status.value,
        "product_category_id": ?productCategoryId,
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

  Future<void> drawProduct({
    required int mainProductId,
    required double drawAmount,
    required int drawCount,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kDrawProduct,
      withBearer: true,
      params: {
        "main_product_id": mainProductId,
        "mode_id": 1, // hardcode
        "draw_amount": drawAmount,
        "draw_count": drawCount,
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

  // a free trial draw of a trial product, [drawCount] 1 or 10: data as
  // drawProduct's. No token: it's for players not logged in (and a 401
  // would otherwise log a player out)
  Future<void> trialDrawProduct({
    required int mainProductId,
    required int drawCount,
    required Function(ApiResponseModel) onSuccess,
    bool showLoader = false,
    Function(String)? onError,
  }) async {
    await HttpClientCustom.httpPost(
      showLoader: showLoader,
      apiUrl: apiUrl,
      endPoint: kProductTrialDraw,
      params: {"main_product_id": mainProductId, "draw_count": drawCount},
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
