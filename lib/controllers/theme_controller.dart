// Project imports:
import '../imports.dart';

enum UserRole { user }

class ThemeController with ChangeNotifier {
  UserRole _currentRole = UserRole.user;

  ThemeData get theme => roleThemes[_currentRole] ?? roleThemes[UserRole.user]!;

  UserRole get currentRole => _currentRole;

  bool get isUser => _currentRole == UserRole.user;

  Future<void> loadTheme() async {
    final savedRole = AppPreferences.getThemeRole();

    _currentRole = savedRole;

    final themeData = roleThemes[_currentRole] ?? roleThemes[UserRole.user]!;

    final isDark = themeData.colorScheme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    notifyListeners();
  }

  void setRole(UserRole role) {
    _currentRole = role;
    AppPreferences.setThemeRole(role);
    loadTheme();
  }

  void resetTheme() {
    setRole(UserRole.user);
  }

  ColorScheme get color => roleThemes[_currentRole]!.colorScheme;

  LinearGradient get themeGradientColor => LinearGradient(
    colors: [color.primary, color.secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

ThemeData defaultTheme = ThemeData(
  useMaterial3: true,
  fontFamily: "Poppins",
  appBarTheme: const AppBarTheme(elevation: 0),
  cupertinoOverrideTheme: const CupertinoThemeData().copyWith(
    primaryColor: AppColors.primaryColor,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryColor,
    selectionHandleColor: AppColors.primaryColor,
    selectionColor: AppColors.primaryColor.wOpacity(0.3),
  ),
  scaffoldBackgroundColor: Colors.white,
  dividerColor: const Color.fromRGBO(231, 227, 227, 1),
  disabledColor: AppColors.disabledColor,
  hintColor: Colors.grey,
);

final Map<UserRole, ThemeData> roleThemes = {
  // User
  UserRole.user: defaultTheme.copyWith(
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      onPrimary: Colors.white,
      // Single brand colour for now: secondary mirrors primary, so the
      // primary → secondary gradients render as a solid fill.
      secondary: AppColors.primaryColor,
      onSecondary: Colors.white,
      tertiary: AppColors.blackColor, // black orange
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      primaryContainer: Colors.white,
      onPrimaryContainer: Colors.black,
      // outline: const Color(0xFFF5F5F5),
    ),
  ),
};
