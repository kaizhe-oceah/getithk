// Project imports:
import '../imports.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
        builder: (BuildContext context, _themeController, _) {
      return const Stack(
        children: [
          // AppImage(
          //   name: _themeController.isTenant
          //       ? AppAssets.backgroundB
          //       : AppAssets.backgroundG,
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
          // Container(
          //   width: double.infinity,
          //   height: double.infinity,
          //   color: AppColors.whiteColor.wOpacity(0.8),
          // )
        ],
      );
    });
  }
}
