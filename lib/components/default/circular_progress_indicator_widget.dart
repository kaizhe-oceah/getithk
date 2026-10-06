// Project imports:
import '../../imports.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  // final double? strokeWidth;
  // final Color? color;
  // final double? size;

  const CircularProgressIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double loaderSize = 56.0;

    return RepaintBoundary(
      child: SizedBox(
        width: loaderSize.fh,
        height: loaderSize.fh,
        child: AppImage(
          name: AppAssets.lottiesLoading,
          repeat: true,
        ),

        // CircularProgressIndicator(
        //   strokeWidth: strokeWidth?.fw ?? loaderSize.fw * 0.1,
        //   valueColor: AlwaysStoppedAnimation<Color?>(
        //     color ?? AppColors.of(context).refreshColor(),
        //   ),
        // ),
      ),
    );
  }
}
