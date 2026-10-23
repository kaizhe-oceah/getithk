// API - Without Auth
const kLogin = "/player/login";
const kLogout = "/player/logout";
const kRegister = "/player/register";
const kPhoneCodes = "/phone-codes";
const kSendOtp = "/send-otp";
const kBanner = "/banner";
const kPageBanner = "/page-banner";
const kProductCategoryListing = "/product/category-listing";
const kTNC = "/term-condition";
const kProductMainProductListing = "/product/main-product-listing";
const kSubMainProductListing = "/product/sub-product-listing";
const kProductTagListing = "/product/tag-listing";
const kAllDrawVideoListing = "/product/all-draw-video-listing";
const kProfile = "/player/profile";
const kWalletBalance = "/player/wallet-balance";
const kPlayerInvitePointListing = "/player/invite-point-listing";
const kPlayerClaimInvitePoint = "/player/claim-invite-point";
const kPlayerAccumulateBoxListing = "/player/accumulate-box-listing";
const kTopupBonusListing = "/topup-bonus-listing";
const kPaymentMethod = "/payment-methods";
const kResetPassword = "/player/reset-password";
const kPlayerStockListing = "/player/stock-listing";
const kDrawProduct = "/player/draw-product";
const kProductTrialDraw = "/product/trial-draw";
const kPlayerSellStock = "/player/sell-stock";
const kPlayerShippingAddress = "/player/shipping-address-listing";
const kPlayerShippingCountryList = "/player/shipping-country-listing";
const kPlayerCreateShipping = "/player/create-shipping";
const kPlayerShippingAddressForm = '/player/shipping-address-form';
const kPlayerCreateShippingAddress = "/player/create-shipping-address";
const kPlayerDeleteShippingAddress = "/player/delete-shipping-address";
const kPlayerUpdateShippingAddress = "/player/update-shipping-address";
const kPlayerShippingSetting = "/player/shipping-setting";
const kPlayerShippingListing = "/player/shipping-listing";
const kTopUpByGateway = "/player/topupByGateway";
const kPlayerCancelShipping = "/player/cancel-shipping";
const kPlayerShippingDetail = "/player/shipping-detail";
const kPlayerRedeemVoucher = "/player/redeem-voucher";
const kPlayerRedeemAccumulateBox = "/player/redeem-accumulate-box";
const kPlayerSellHistory = "/player/sell-history";
const kStockSummary = "/player/stock-summary";
const kPlayerDrawHistory = "/player/draw-history";
const kProductGradeListing = "/product/grade-listing";
const kPlayerTopupCommissionListing = "/player/topup-commission-listing";
const kPlayerInvitedPlayerListing = "/player/invited-member-listing";
const kPlayerAvatarSetting = "/player/avatar-setting";
const kPlayerUpdateAvatarSetting = "/player/update-avatar-setting";
const kPlayerSocialLogin = "/player/social-login";



/// Where the payment gateway sends the player back to (fe_redirect_url),
/// as `…/app-payment-result?reference=TOP-…&status=paid|pending|failed`.
/// It needn't exist on the web: the payment web view stops there and
/// closes with the status.
const kTopUpReturnPath = "/app-payment-result";

// API Timezone
const kApiTimezone = "Asia/Kuala_Lumpur";

// API STATUS
const kSuccess = 1;
const kFail = 0;
const kUnauthenticated = 401;
