enum Environment { staging, production }

enum AppTheme { light, dark }

enum ToastType { normal, success, error, warning }

enum AppLanguage { en, zh, ms }

/// Whether the player uses a phone number or an email; [value] is the API's
/// `type` for login, register and send-otp.
enum ContactType {
  phone(1),
  email(2);

  const ContactType(this.value);
  final int value;
}

/// How the player proves the account; [value] is the API's `auth_method`.
enum AuthMethod {
  otp(1),
  password(2);

  const AuthMethod(this.value);
  final int value;
}
