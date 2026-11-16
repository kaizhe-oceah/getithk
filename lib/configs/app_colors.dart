// Project imports:
import '../imports.dart';

class AppColors {
  // AppColors._();
  // static late BuildContext _context;
  // static AppColors of(BuildContext context) {
  //   _context = context;
  //   return AppColors._();
  // }

  /// Dark mode: set by [ThemeController]; the colours below that are
  /// getters follow it.
  static bool isDark = false;

  // brand
  static const Color primaryColor = Color(0xFFCA0000);

  // follow the theme: a page, a card or sheet on it, and text on either
  static Color get backgroundColor =>
      isDark ? darkModeBackgroundColor : whiteColor;
  static Color get surfaceColor => isDark ? darkModeSurfaceColor : whiteColor;
  static Color get textColor => isDark ? whiteColor : blackColor;
  static SystemUiOverlayStyle get pageOverlayStyle =>
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

  // normal colors
  static const Color secondaryColorSoild = Color.fromRGBO(0, 102, 246, 1);
  static const Color primaryNoContextColor = primaryColor;
  static const Color blackColor = Colors.black;
  static Color get blackLightColor => isDark
      ? const Color.fromARGB(255, 160, 160, 160)
      : const Color.fromARGB(255, 112, 112, 112);
  static const Color whiteColor = Colors.white;
  static const Color redColor = Colors.red;
  static const Color greyColor = Colors.grey;
  static const Color blueColor = Colors.blue;
  static const Color greenColor = Colors.green;
  static Color get greyLightColor =>
      isDark ? darkModeBorderColor : const Color.fromARGB(255, 225, 225, 225);
  static Color get greyLight2Color =>
      isDark ? darkModeDividerColor : const Color.fromRGBO(240, 240, 240, 1);
  static const Color toastNormalColor = Color.fromRGBO(57, 57, 57, 1);
  static const Color toastSuccessColor = Color(0xFF16A34A);
  static const Color toastErrorColor = Color(0xFFE5484D);
  static const Color toastWarningColor = Color(0xFFF59E0B);
  static const Color primaryLightColor = Color.fromRGBO(45, 45, 45, 0.6);
  static const Color transparentColor = Colors.transparent;
  static const Color darkRedColor = Color.fromRGBO(213, 45, 31, 1);
  static const Color orangeColor = Colors.orange;
  static const Color purpleColor = Color.fromRGBO(199, 125, 255, 1);
  static Color get textLightColor =>
      isDark ? const Color(0xFFB3B3B3) : const Color.fromARGB(255, 80, 80, 80);
  static Color get greyBackgroundColor =>
      isDark ? darkModeRaisedColor : const Color.fromARGB(255, 244, 244, 244);
  static Color get lightGreyBackgroundColor => isDark
      ? const Color(0xFF242424)
      : const Color.fromARGB(255, 250, 250, 250);
  static Color get greyTextColor => colorFromHex("#808080");
  static const Color successGreen = Color.fromRGBO(0, 175, 26, 1.0);
  static const Color lightBlueCyan = Color.fromARGB(255, 154, 203, 208);
  static Color get labelColor => isDark ? Colors.white38 : Colors.black38;
  static const Color lightPrimaryColor = Color.fromRGBO(225, 238, 254, 1);
  static const Color hintColor = Colors.grey;
  static Color get mainAppBarColor => isDark
      ? darkModeBackgroundColor
      : const Color.fromARGB(255, 245, 245, 245);
  static const Color disabledColor = greyColor;
  static const Color blueHighlightColor = Color.fromRGBO(0, 123, 255, 1);

  // dark mode: charcoal, a step lighter than the always-dark screens below
  static const Color darkModeBackgroundColor = Color(0xFF1E1E1E);
  static const Color darkModeSurfaceColor = Color(0xFF2A2A2A);
  // chips, fields and other fills on a card
  static const Color darkModeRaisedColor = Color(0xFF363636);
  static const Color darkModeDividerColor = Color(0xFF3A3A3A);
  static const Color darkModeBorderColor = Color(0xFF484848);
  static const Color darkModeHintColor = Color(0xFF9E9E9E);

  // always dark: splash, launch screen, language sheet
  static const Color darkBackgroundColor = Color.fromRGBO(14, 14, 14, 1);
  static const Color darkSurfaceColor = Color.fromRGBO(26, 26, 26, 1);
  static const Color darkDividerColor = Color.fromRGBO(42, 42, 42, 1);
  static const Color bottomNavColor = Color(0xFF111111);
  static const Color bottomNavBorderColor = Color(0xFF5C1414);
  static const Color darkBorderColor = Color.fromRGBO(60, 60, 60, 1);
  static const Color darkHintColor = Color.fromRGBO(138, 138, 138, 1);
  static const Color darkAppBarColor = Color(0xFF161616);

  // login page
  static Color get loginTextColor =>
      isDark ? const Color(0xFFF2F4F7) : const Color(0xFF101725);
  static const Color loginHintColor = Color(0xFF8497AE);
  static Color get loginFieldColor =>
      isDark ? darkModeRaisedColor : const Color(0xFFEEF3F8);
  static Color get loginDividerColor =>
      isDark ? darkModeDividerColor : const Color(0xFFDDE5ED);
  static const Color facebookColor = Color(0xFF006DE9);
  static const Color googleColor = Color(0xFFD73836);

  // gradient
  static LinearGradient get greyTransparentGradientColor => LinearGradient(
    colors: [Colors.black26.wOpacity(0.45), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient get whiteGradientColor => LinearGradient(
    colors: [surfaceColor, surfaceColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient get buttonGradientColor {
    final scheme = NavigationService.context.read<ThemeController>().color;
    return LinearGradient(
      colors: [scheme.primary, scheme.secondary],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static LinearGradient get brandGradientColor {
    final scheme = NavigationService.context.read<ThemeController>().color;
    return LinearGradient(
      colors: [scheme.primary, scheme.secondary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  // profile
  static const LinearGradient profileHeaderGradientColor = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF4F8DF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // the level badge and bar: orange, amber in the middle, orange
  static const List<Color> _levelColors = [
    Color(0xFFFF8A2A),
    Color(0xFFF6BE33),
    Color(0xFFFF8A2A),
  ];
  static const LinearGradient levelBadgeGradientColor = LinearGradient(
    colors: _levelColors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient levelBarGradientColor = LinearGradient(
    colors: _levelColors,
  );
  static const Color coinColor = Color(0xFFF6B100);
  static Color get profileMenuIconColor =>
      isDark ? const Color(0xFFCFCFCF) : const Color(0xFF3A3A3A);

  // sub product
  static const Color quantityBadgeColor = Color(0xFF3A3A3A);

  // shadow
  static final List<BoxShadow> shadowDefault = [
    BoxShadow(
      color: Colors.black.wOpacity(0.2),
      spreadRadius: 1,
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> get shadowLight => [
    BoxShadow(
      color: isDark ? Colors.black26 : Colors.grey.shade100,
      spreadRadius: 0.0,
      blurRadius: 2,
      offset: const Offset(0, 1.0),
    ),
    BoxShadow(
      color: isDark ? Colors.black45 : Colors.grey.shade300,
      spreadRadius: 0.0,
      blurRadius: 2,
      offset: const Offset(0, 1.0),
    ),
  ];
}
