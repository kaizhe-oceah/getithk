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

enum ProductSort {
  recommended('recommended'),
  lowStock('low_stock'),
  newest('newest'),
  priceHighToLow('price_desc'),
  priceLowToHigh('price_asc');

  const ProductSort(this.value);
  final String value;
}
