/// The player, as `data.user` in the login / register response.
class UserModel {
  int? id;
  String? idNumber;
  String? name;
  String? email;
  String? phoneCode;
  String? phoneNo;
  String? lastLoginAt;
  String? referralCode;
  String? topupCommissionRate;
  int? following;
  int? follower;
  String? currencyCode;
  String? currencySymbol;
  int? currencySymbolPosition;
  int? avatarId;
  String? avatarImage;
  int? frameId;
  String? frameImage;

  String get phone => '${phoneCode ?? ''}${phoneNo ?? ''}';

  UserModel({
    this.id,
    this.idNumber,
    this.name,
    this.email,
    this.phoneCode,
    this.phoneNo,
    this.lastLoginAt,
    this.referralCode,
    this.topupCommissionRate,
    this.following,
    this.follower,
    this.currencyCode,
    this.currencySymbol,
    this.currencySymbolPosition,
    this.avatarId,
    this.avatarImage,
    this.frameId,
    this.frameImage,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = _int(json['id']);
    idNumber = _string(json['id_number']);
    name = _string(json['name']);
    email = _string(json['email']);
    phoneCode = _string(json['phone_code']);
    phoneNo = _string(json['phone_no']);
    lastLoginAt = _string(json['last_login_at']);
    referralCode = _string(json['referral_code']);
    topupCommissionRate = _string(json['topup_commission_rate']);
    following = _int(json['following']);
    follower = _int(json['follower']);
    currencyCode = _string(json['currency_code']);
    currencySymbol = _string(json['currency_symbol']);
    currencySymbolPosition = _int(json['currency_symbol_position']);
    avatarId = _int(json['avatar_id']);
    avatarImage = _string(json['avatar_image']);
    frameId = _int(json['frame_id']);
    frameImage = _string(json['frame_image']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_number'] = idNumber;
    data['name'] = name;
    data['email'] = email;
    data['phone_code'] = phoneCode;
    data['phone_no'] = phoneNo;
    data['last_login_at'] = lastLoginAt;
    data['referral_code'] = referralCode;
    data['topup_commission_rate'] = topupCommissionRate;
    data['following'] = following;
    data['follower'] = follower;
    data['currency_code'] = currencyCode;
    data['currency_symbol'] = currencySymbol;
    data['currency_symbol_position'] = currencySymbolPosition;
    data['avatar_id'] = avatarId;
    data['avatar_image'] = avatarImage;
    data['frame_id'] = frameId;
    data['frame_image'] = frameImage;

    return data;
  }

  // Tolerant of ints sent as strings (and the other way round), so an
  // unexpected type, or a user saved by an older build, never throws.
  static int? _int(dynamic value) =>
      value is int ? value : int.tryParse('${value ?? ''}');

  static String? _string(dynamic value) => value?.toString();
}
