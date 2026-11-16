// Dart imports:
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

// Project imports:
import '../imports.dart';

enum UserRole { user }

class ThemeController with ChangeNotifier {
  UserRole _currentRole = UserRole.user;

  ThemeData get theme => roleThemes[_currentRole] ?? roleThemes[UserRole.user]!;

  bool get isDark => AppColors.isDark;

  ThemeMode get themeMode => isDark ? ThemeMode.dark : ThemeMode.light;

  /// Reads the saved mode; before the app is built, so the first frame
  /// already has it.
  static void loadDarkMode() => AppColors.isDark = AppPreferences.getDarkMode();

  /// Round the whole app, so the switch can fade from a picture of it.
  static final GlobalKey snapshotKey = GlobalKey();

  bool _switching = false;

  Future<void> setDarkMode(bool value) async {
    if (value == isDark || _switching) return;
    _switching = true;

    try {
      // the old look stays on top, fading out over the new one
      final OverlayEntry? cover = await _cover();

      AppColors.isDark = value;
      AppPreferences.setDarkMode(value);
      notifyListeners();
      _rebuildAll();

      if (cover != null) NavigationService.overlay?.insert(cover);
    } finally {
      _switching = false;
    }
  }

  Future<OverlayEntry?> _cover() async {
    final BuildContext? context = snapshotKey.currentContext;
    final RenderObject? boundary = context?.findRenderObject();
    if (context == null || boundary is! RenderRepaintBoundary) return null;

    try {
      await WidgetsBinding.instance.endOfFrame;
      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      );

      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _FadingCover(
          image: image,
          onDone: () {
            entry.remove();
            image.dispose();
          },
        ),
      );
      return entry;
    } catch (_) {
      // no picture: it just switches
      return null;
    }
  }

  // the AppColors getters aren't read through an InheritedWidget, so only
  // a widget that rebuilds picks up the new mode: rebuild every one (state,
  // scroll and the pages under the top one are kept)
  void _rebuildAll() {
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
  }

  UserRole get currentRole => _currentRole;

  bool get isUser => _currentRole == UserRole.user;

  Future<void> loadTheme() async {
    final savedRole = AppPreferences.getThemeRole();

    _currentRole = savedRole;

    // the status bar is each page's to set (AppScaffold), not the theme's:
    // set here too, its icons flashed the other colour on a page that
    // wanted its own, as on the splash page for a logged-in user
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

/// Dark mode: black pages with the brand red.
final ThemeData darkTheme =
    ThemeData(
      useMaterial3: true,
      fontFamily: "Poppins",
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        secondary: AppColors.primaryColor,
        onSecondary: Colors.white,
        tertiary: Colors.white,
        onTertiary: Colors.black,
        surface: AppColors.darkModeSurfaceColor,
        onSurface: Colors.white,
        primaryContainer: AppColors.darkModeSurfaceColor,
        onPrimaryContainer: Colors.white,
      ),
    ).copyWith(
      appBarTheme: defaultTheme.appBarTheme,
      cupertinoOverrideTheme: defaultTheme.cupertinoOverrideTheme,
      textSelectionTheme: defaultTheme.textSelectionTheme,
      scaffoldBackgroundColor: AppColors.darkModeBackgroundColor,
      dividerColor: AppColors.darkModeDividerColor,
      disabledColor: AppColors.disabledColor,
      hintColor: AppColors.darkModeHintColor,
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

class _FadingCover extends StatefulWidget {
  final ui.Image image;
  final VoidCallback onDone;

  const _FadingCover({required this.image, required this.onDone});

  @override
  State<_FadingCover> createState() => _FadingCoverState();
}

class _FadingCoverState extends State<_FadingCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward().whenComplete(widget.onDone);

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 1,
          end: 0,
        ).animate(CurvedAnimation(parent: _fade, curve: Curves.easeInOut)),
        child: RawImage(
          image: widget.image,
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
