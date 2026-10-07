class AppRegex {
  // https://stackoverflow.com/a/32686261/9449426
  static final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Stricter [email] for sign-ups: the name part may only hold letters,
  /// digits, `.`, `_` and `-`. Blocks `+` aliases (abc+67@gmail.com lands in
  /// abc@gmail.com's inbox, so one inbox could sign up and get OTPs over and
  /// over) and the other symbols some providers treat the same way.
  static final registerEmail =
      RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$');
  static final phone = RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
  static final name = RegExp(r'(\w+)\s(\w+)');
  static final icNumber = RegExp(r'^[0-9]{6}-[0-9]{2}-[0-9]{4}$');
  static final postcode = RegExp(r'^[0-9]{5}$');
  static final link = RegExp(
      r"(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])");
  static bool isLink(String input) {
    final matcher = link;
    return matcher.hasMatch(input);
  }
}
