// Project imports:
import '../imports.dart';

class AppColors {
  // AppColors._();
  // static late BuildContext _context;
  // static AppColors of(BuildContext context) {
  //   _context = context;
  //   return AppColors._();
  // }

  // brand
  static const Color primaryColor = Color(0xFFCA0000);

  // normal colors
  static const Color secondaryColorSoild = Color.fromRGBO(0, 102, 246, 1);
  static const Color primaryNoContextColor = primaryColor;
  static const Color blackColor = Colors.black;
  static const Color blackLightColor = Color.fromARGB(255, 112, 112, 112);
  static const Color whiteColor = Colors.white;
  static const Color redColor = Colors.red;
  static const Color greyColor = Colors.grey;
  static const Color blueColor = Colors.blue;
  static const Color greenColor = Colors.green;
  static const Color greyLightColor = Color.fromARGB(255, 225, 225, 225);
  static const Color greyLight2Color = Color.fromRGBO(240, 240, 240, 1);
  static const Color toastNormalColor = Color.fromRGBO(57, 57, 57, 1);
  static const Color toastSuccessColor = Colors.green;
  static const Color toastErrorColor = Colors.red;
  static const Color toastWarningColor = Colors.orange;
  static const Color primaryLightColor = Color.fromRGBO(45, 45, 45, 0.6);
  static const Color transparentColor = Colors.transparent;
  static const Color darkRedColor = Color.fromRGBO(213, 45, 31, 1);
  static const Color orangeColor = Colors.orange;
  static const Color purpleColor = Color.fromRGBO(199, 125, 255, 1);
  static const Color textLightColor = Color.fromARGB(255, 80, 80, 80);
  static const Color greyBackgroundColor = Color.fromARGB(255, 244, 244, 244);
  static const Color lightGreyBackgroundColor = Color.fromARGB(
    255,
    250,
    250,
    250,
  );
  static Color get greyTextColor => colorFromHex("#808080");
  static const Color successGreen = Color.fromRGBO(0, 175, 26, 1.0);
  static const Color lightBlueCyan = Color.fromARGB(255, 154, 203, 208);
  static const Color labelColor = Colors.black38;
  static const Color lightPrimaryColor = Color.fromRGBO(225, 238, 254, 1);
  static const Color hintColor = Colors.grey;
  static const Color mainAppBarColor = Color.fromARGB(255, 245, 245, 245);
  static const Color disabledColor = greyColor;
  static const Color blueHighlightColor = Color.fromRGBO(0, 123, 255, 1);

  // dark surfaces
  static const Color darkBackgroundColor = Color.fromRGBO(14, 14, 14, 1);
  static const Color darkSurfaceColor = Color.fromRGBO(26, 26, 26, 1);
  static const Color darkDividerColor = Color.fromRGBO(42, 42, 42, 1);
  static const Color bottomNavColor = Color(0xFF111111);
  static const Color bottomNavBorderColor = Color(0xFF5C1414);
  static const Color darkBorderColor = Color.fromRGBO(60, 60, 60, 1);
  static const Color darkHintColor = Color.fromRGBO(138, 138, 138, 1);
  static const Color darkAppBarColor = Color(0xFF161616);

  // login page
  static const Color loginTextColor = Color(0xFF101725);
  static const Color loginHintColor = Color(0xFF8497AE);
  static const Color loginFieldColor = Color(0xFFEEF3F8);
  static const Color loginDividerColor = Color(0xFFDDE5ED);
  static const Color facebookColor = Color(0xFF006DE9);
  static const Color googleColor = Color(0xFFD73836);

  // gradient
  static LinearGradient get greyTransparentGradientColor => LinearGradient(
    colors: [Colors.black26.wOpacity(0.45), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient get whiteGradientColor => const LinearGradient(
    colors: [Colors.white, Colors.white],
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
  static const Color levelBadgeColor = Color(0xFFF5A623);
  static const Color coinColor = Color(0xFFF6B100);
  static const Color profileMenuIconColor = Color(0xFF3A3A3A);

  // shadow
  static final List<BoxShadow> shadowDefault = [
    BoxShadow(
      color: Colors.black.wOpacity(0.2),
      spreadRadius: 1,
      blurRadius: 2,
    ),
  ];

  static final List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Colors.grey.shade100,
      spreadRadius: 0.0,
      blurRadius: 2,
      offset: const Offset(0, 1.0),
    ),
    BoxShadow(
      color: Colors.grey.shade300,
      spreadRadius: 0.0,
      blurRadius: 2,
      offset: const Offset(0, 1.0),
    ),
  ];
}
