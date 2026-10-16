// Project imports:
import '../configs/app_assets.dart';

enum Environment { staging, production }

enum AppTheme { light, dark }

enum ToastType { normal, success, error, warning }

enum AppLanguage { en, zh, ms }

enum ContactType {
  phone(1),
  email(2);

  const ContactType(this.value);
  final int value;
}

enum AuthMethod {
  otp(1),
  password(2);

  const AuthMethod(this.value);
  final int value;
}

enum TncType {
  terms(1),
  privacy(2);

  const TncType(this.value);
  final int value;
}

enum StockStatus {
  active(1),
  inactive(2),
  redeemed(3),
  sold(4),
  shipping(5);

  const StockStatus(this.value);
  final int value;
}

enum ShippingStatus {
  toShip(1), // 待發貨
  toReceive(2), // 待收貨
  completed(3),
  cancelled(4);

  const ShippingStatus(this.value);
  final int value;

  static ShippingStatus? fromValue(int? value) =>
      values.where((element) => element.value == value).firstOrNull;
}

/// How a gateway payment ended: the `status` the gateway sends the player
/// back with (kTopUpReturnPath).
enum PaymentStatus {
  paid,

  /// The gateway hasn't confirmed it yet; probably paid, not a failure.
  pending,
  failed;

  /// The status named [value]; null for anything else (the web view closed
  /// by its back button, say).
  static PaymentStatus? fromValue(Object? value) =>
      values.where((element) => element.name == value).firstOrNull;
}

enum ProductGrade {
  last(1), // 尾賞
  first(2), // 一等獎
  second(3), // 二等獎
  third(4), // 三等獎
  fourth(5), // 四等獎
  fifth(6); // 五等獎

  const ProductGrade(this.value);
  final int value;

  String get image => switch (this) {
    last => AppAssets.gradeLast,
    first => AppAssets.gradeFirst,
    second => AppAssets.gradeSecond,
    third => AppAssets.gradeThird,
    fourth => AppAssets.gradeFourth,
    fifth => AppAssets.gradeFifth,
  };

  static ProductGrade? fromValue(int? value) =>
      values.where((element) => element.value == value).firstOrNull;
}

enum ProductSort {
  recommended('recommended'),
  lowStock('low_stock'),
  newest('newest'),
  priceHighToLow('price_desc'),
  priceLowToHigh('price_asc');

  const ProductSort(this.value);
  final String value;
}
